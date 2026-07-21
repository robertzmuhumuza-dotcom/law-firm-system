const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Serve static frontend files from 'public'
app.use(express.static('public'));

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_key';

// Connect to MongoDB Atlas
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("Connected to MongoDB Atlas!"))
  .catch(err => console.error("Database connection error:", err));

// Configure local storage for firm documents
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, './uploads/'),
    filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage });

// --- Schemas & Models ---
const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['Managing Partner', 'Associate', 'Clerk'], default: 'Associate' }
});

const CaseSchema = new mongoose.Schema({
    caseNumber: { type: String, required: true, unique: true },
    clientName: { type: String, required: true },
    details: { type: String, required: true },
    status: { type: String, enum: ['Investigation', 'Filed', 'Hearing', 'Judgment', 'Closed'], default: 'Investigation' },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdAt: { type: Date, default: Date.now }
});

const DocumentSchema = new mongoose.Schema({
    title: { type: String, required: true },
    fileUrl: { type: String, required: true },
    relatedCase: { type: mongoose.Schema.Types.ObjectId, ref: 'Case' },
    uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    uploadedAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', UserSchema);
const Case = mongoose.model('Case', CaseSchema);
const Document = mongoose.model('Document', DocumentSchema);

// --- Middlewares ---
const authenticate = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(401).json({ error: "Access token missing" });
    
    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: "Invalid or expired token" });
        req.user = user;
        next();
    });
};

const requireManagingPartner = (req, res, next) => {
    if (req.user.role !== 'Managing Partner') {
        return res.status(403).json({ error: "Access denied: Managing Partner privileges required." });
    }
    next();
};

// --- Authentication Routes ---
app.post('/api/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).json({ error: "User already exists" });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = new User({ name, email, password: hashedPassword, role });
        await newUser.save();
        res.status(201).json({ message: "Staff member registered successfully!" });
    } catch (err) {
        res.status(500).json({ error: "Registration failed", details: err.message });
    }
});

app.post('/api/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ error: "Invalid credentials" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ error: "Invalid credentials" });

        const token = jwt.sign({ userId: user._id, role: user.role, name: user.name }, JWT_SECRET, { expiresIn: '8h' });
        res.json({ token, user: { name: user.name, email: user.email, role: user.role } });
    } catch (err) {
        res.status(500).json({ error: "Login failed", details: err.message });
    }
});

// --- Case Management Routes ---

app.patch('/api/cases/:id/assign', authenticate, requireManagingPartner, async (req, res) => {
    try {
        const { lawyerEmail, status } = req.body;
        const targetUser = await User.findOne({ email: lawyerEmail });
        if (!targetUser) return res.status(404).json({ error: "Lawyer with this email not found in firm records." });

        const updatedCase = await Case.findByIdAndUpdate(
            req.params.id,
            { assignedTo: targetUser._id, ...(status && { status }) },
            { new: true }
        ).populate('assignedTo', 'name email role');
        
        res.json({ message: "Case assignment updated successfully", updatedCase });
    } catch (err) {
        res.status(500).json({ error: "Failed to update case assignment", details: err.message });
    }
});

app.post('/api/cases', authenticate, async (req, res) => {
    try {
        const { caseNumber, clientName, details, status, assignedTo } = req.body;
        const newCase = new Case({
            caseNumber,
            clientName,
            details,
            status,
            assignedTo: assignedTo || req.user.userId,
            createdBy: req.user.userId
        });
        await newCase.save();
        res.status(201).json(newCase);
    } catch (err) {
        res.status(500).json({ error: "Failed to create case", details: err.message });
    }
});

app.get('/api/cases', authenticate, async (req, res) => {
    try {
        let query = {};
        if (req.user.role !== 'Managing Partner') {
            query = { assignedTo: req.user.userId };
        }
        const cases = await Case.find(query)
            .populate('assignedTo', 'name email role')
            .populate('createdBy', 'name');
        res.json(cases);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch cases", details: err.message });
    }
});

// --- Firm Document Storing ---
app.post('/api/documents', authenticate, upload.single('file'), async (req, res) => {
    try {
        const { title, relatedCase } = req.body;
        if (!req.file) return res.status(400).json({ error: "No file uploaded" });

        const newDoc = new Document({
            title,
            fileUrl: req.file.path,
            relatedCase,
            uploadedBy: req.user.userId
        });
        await newDoc.save();
        res.status(201).json({ message: "Document stored successfully", newDoc });
    } catch (err) {
        res.status(500).json({ error: "Document upload failed", details: err.message });
    }
});

// --- AI Evidence & Static Evaluation Module ---
app.post('/api/evaluate-evidence', authenticate, async (req, res) => {
    try {
        const { evidenceDetails, legalContext } = req.body;
        const model = genAI.getGenerativeModel({ 
            model: "gemini-2.0-flash",
            tools: [{ googleSearch: {} }] 
        });
        
        const prompt = `You are an elite Senior Legal Counsel and expert advocate specializing in Ugandan jurisprudence, East African Court of Justice precedents, and international comparative law.
        Analyze the following piece of evidence, contract clause, or testimony for our law firm matter.
        Jurisdiction/Context: ${legalContext || 'Ugandan Civil/Commercial Law and Practice'}
        Evidence Details: ${evidenceDetails}
        Provide a rigorous, professional legal evaluation structured strictly as follows:
        1. Statutory & Evidentiary Admissibility (Evaluate under the Ugandan Evidence Act, relevance, materiality, and hearsay rules)
        2. Probative Value & Case Strength (Assess how strongly this supports our client's position)
        3. Cross-Examination & Defense Vulnerabilities (Anticipate arguments opposing counsel may raise under local court rules)
        4. Strategic Recommendations & Precedents (Recommend specific corroborating evidence, procedures, or local case law applications)`;

        const result = await model.generateContent(prompt);
        res.json({ evaluation: result.response.text() });
    } catch (err) {
        res.status(500).json({ error: "AI evidence evaluation failed", details: err.message });
    }
});

// --- LIVE INTERACTIVE CHAT CO-COUNSEL ENDPOINT ---
app.post('/api/chat-counsel', authenticate, async (req, res) => {
    try {
        const { message } = req.body;
        const model = genAI.getGenerativeModel({ 
            model: "gemini-2.0-flash",
            tools: [{ googleSearch: {} }],
            systemInstruction: "You are an expert live AI legal co-counsel for a law firm in Uganda. You possess deep knowledge of Ugandan legislation (Civil Procedure Act, Evidence Act, Income Tax Act, IP laws, etc.), case law, and international jurisprudence. Answer questions precisely, professionally, and cite relevant sections or principles when appropriate."
        });

        const result = await model.generateContent(message);
        const responseText = result.response.text();
        res.json({ reply: responseText });
    } catch (err) {
        console.error("Chat Error:", err);
        res.status(500).json({ error: "Interactive chat failed: " + err.message });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Firm Backend Server running on port ${PORT}`));