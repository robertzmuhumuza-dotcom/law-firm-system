const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Middleware
app.use(express.json());
app.use(cors());

// Health check route
app.get('/', (req, res) => {
  res.status(200).send('AI Legal Co-pilot System Backend is active and running.');
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

    // Using stable v1beta endpoint with gemini-1.5-flash
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
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
// 2. CASE TRACKING ENDPOINT
// ==========================================
let mockCases = [
  { id: '1', caseNumber: 'HCT-00-CC-CS-0123-2025', title: 'Kampala Distributors v. Nile Breweries', status: 'Active Hearing' }
];

app.get('/cases', (req, res) => {
  res.status(200).json(mockCases);
});

app.post('/cases', (req, res) => {
  const { caseNumber, title, status } = req.body;
  const newCase = { id: Date.now().toString(), caseNumber, title, status: status || 'Pending' };
  mockCases.push(newCase);
  res.status(201).json({ message: 'Case registered successfully', case: newCase });
});

// ==========================================
// 3. DOCUMENT STORAGE ENDPOINT
// ==========================================
let mockDocuments = [
  { id: '1', title: 'Plaint Template - Civil Suit', fileUrl: 'https://example.com/plaint', uploadedAt: '2026-08-07' }
];

app.get('/documents', (req, res) => {
  res.status(200).json(mockDocuments);
});

app.post('/documents', (req, res) => {
  const { title, fileUrl } = req.body;
  const newDoc = { id: Date.now().toString(), title, fileUrl: fileUrl || 'N/A', uploadedAt: new Date().toISOString().substring(0, 10) };
  mockDocuments.push(newDoc);
  res.status(201).json({ message: 'Document stored successfully', document: newDoc });
});

// ==========================================
// 4. ROLE ASSIGNMENT ENDPOINT
// ==========================================
let mockRoles = [
  { id: '1', userId: 'counsel@law.com', role: 'Lead Counsel', caseId: 'HCT-00-CC-CS-0123-2025' }
];

app.get('/roles', (req, res) => {
  res.status(200).json(mockRoles);
});

app.post('/roles', (req, res) => {
  const { userId, role, caseId } = req.body;
  const assignment = { id: Date.now().toString(), userId, role, caseId: caseId || 'N/A' };
  mockRoles.push(assignment);
  res.status(201).json({ message: 'Role assigned successfully', assignment });
});

// ==========================================
// AUTHENTICATION ENDPOINTS
// ==========================================
app.post('/register', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'Email and password required.' });
  res.status(200).json({ message: 'Account created successfully.', user: { email } });
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'Email and password required.' });
  res.status(200).json({ message: 'Login successful', token: 'mock-jwt-token' });
});

app.post('/forgot-password', (req, res) => {
  res.status(200).json({ message: 'Password reset link sent to your email.' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});