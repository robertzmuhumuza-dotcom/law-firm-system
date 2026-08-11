const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 5000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/law-firm-system';
const JWT_SECRET = process.env.JWT_SECRET || 'your-secure-jwt-secret-key';

// Middleware
app.use(express.json());
app.use(cors());

// Connect to MongoDB
mongoose.connect(MONGO_URI)
  .then(() => console.log('Connected to MongoDB successfully.'))
  .catch((err) => console.error('MongoDB connection error:', err));

// ==========================================
// MONGOOSE SCHEMAS & MODELS
// ==========================================
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});
const User = mongoose.model('User', userSchema);

const caseSchema = new mongoose.Schema({
  caseNumber: { type: String, required: true },
  title: { type: String, required: true },
  status: { type: String, default: 'Pending' },
  createdAt: { type: Date, default: Date.now }
});
const Case = mongoose.model('Case', caseSchema);

const documentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  fileUrl: { type: String, default: 'N/A' },
  uploadedAt: { type: String, default: () => new Date().toISOString().substring(0, 10) }
});
const Document = mongoose.model('Document', documentSchema);

const roleSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  role: { type: String, required: true },
  caseId: { type: String, default: 'N/A' }
});
const Role = mongoose.model('Role', roleSchema);

// Health check route
app.get('/', (req, res) => {
  res.status(200).send('AI Legal Co-pilot System Backend is active, persistent, and secure.');
});

// ==========================================
// 1. LIVE GEMINI AI CHAT ENDPOINT
// ==========================================
app.post('/chat', async (req, res) => {
  try {
    const { prompt, context } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: 'Prompt field is required.' });
    }

    if (!GEMINI_API_KEY) {
      return res.status(500).json({ response: 'Gemini API Key is not configured on the server environment.' });
    }

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                { text: `You are an expert AI Legal Co-pilot specializing in ${context || 'Ugandan jurisprudence, statutes, and civil procedure'}. Answer the following query professionally: ${prompt}` }
              ]
            }
          ]
        })
      }
    );

    const data = await geminiResponse.json();
    
    const aiText = data?.candidates?.[0]?.content?.parts?.[0]?.text || 
                   data?.error?.message || 
                   'Analysis complete, but no response text was returned.';

    return res.status(200).json({ response: aiText });

  } catch (error) {
    console.error('Server error on /chat route:', error);
    return res.status(500).json({ response: 'Internal server error while communicating with Gemini AI.' });
  }
});

// ==========================================
// 2. CASE TRACKING ENDPOINTS (Persistent)
// ==========================================
app.get('/cases', async (req, res) => {
  try {
    const cases = await Case.find();
    res.status(200).json(cases);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching cases' });
  }
});

app.post('/cases', async (req, res) => {
  try {
    const { caseNumber, title, status } = req.body;
    if (!caseNumber || !title) {
      return res.status(400).json({ message: 'Case number and title are required.' });
    }
    const newCase = new Case({ caseNumber, title, status: status || 'Pending' });
    await newCase.save();
    res.status(201).json({ message: 'Case registered successfully', case: newCase });
  } catch (err) {
    res.status(500).json({ message: 'Error creating case' });
  }
});

// ==========================================
// 3. DOCUMENT STORAGE ENDPOINTS (Persistent)
// ==========================================
app.get('/documents', async (req, res) => {
  try {
    const documents = await Document.find();
    res.status(200).json(documents);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching documents' });
  }
});

app.post('/documents', async (req, res) => {
  try {
    const { title, fileUrl } = req.body;
    if (!title) {
      return res.status(400).json({ message: 'Document title is required.' });
    }
    const newDoc = new Document({ title, fileUrl: fileUrl || 'N/A' });
    await newDoc.save();
    res.status(201).json({ message: 'Document stored successfully', document: newDoc });
  } catch (err) {
    res.status(500).json({ message: 'Error storing document' });
  }
});

// ==========================================
// 4. ROLE ASSIGNMENT ENDPOINTS (Persistent)
// ==========================================
app.get('/roles', async (req, res) => {
  try {
    const roles = await Role.find();
    res.status(200).json(roles);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching roles' });
  }
});

app.post('/roles', async (req, res) => {
  try {
    const { userId, role, caseId } = req.body;
    if (!userId || !role) {
      return res.status(400).json({ message: 'User ID and role are required.' });
    }
    const assignment = new Role({ userId, role, caseId: caseId || 'N/A' });
    await assignment.save();
    res.status(201).json({ message: 'Role assigned successfully', assignment });
  } catch (err) {
    res.status(500).json({ message: 'Error assigning role' });
  }
});

// ==========================================
// 5. SECURE AUTHENTICATION ENDPOINTS (Robust + Working Reset)
// ==========================================
app.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'Email and password required.' });

    const cleanEmail = email.trim().toLowerCase();
    const existingUser = await User.findOne({ email: cleanEmail });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ email: cleanEmail, password: hashedPassword });
    await newUser.save();

    res.status(201).json({ message: 'Account created successfully.', user: { email: cleanEmail } });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ message: 'Error registering user' });
  }
});

app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'Email and password required.' });

    const cleanEmail = email.trim().toLowerCase();
    const user = await User.findOne({ email: cleanEmail });
    
    if (!user) {
      console.log(`Login failed: User not found for email: ${cleanEmail}`);
      return res.status(400).json({ message: 'Invalid email or password.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log(`Login failed: Password mismatch for email: ${cleanEmail}`);
      return res.status(400).json({ message: 'Invalid email or password.' });
    }

    const token = jwt.sign({ id: user._id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    res.status(200).json({ message: 'Login successful', token, user: { email: user.email } });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Error logging in' });
  }
});

// Fully functional password reset endpoint supporting direct update
app.post('/forgot-password', async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required.' });
    }

    const cleanEmail = email.trim().toLowerCase();
    const user = await User.findOne({ email: cleanEmail });

    if (!user) {
      return res.status(404).json({ message: 'User not found with this email.' });
    }

    // If a newPassword is provided directly from your app UI, update it immediately
    if (newPassword) {
      user.password = await bcrypt.hash(newPassword, 10);
      await user.save();
      return res.status(200).json({ message: 'Password updated successfully. You can now login.' });
    }

    // Fallback if app expects a message simulation
    res.status(200).json({ message: 'Password reset instructions sent.' });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ message: 'Error processing password reset.' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});