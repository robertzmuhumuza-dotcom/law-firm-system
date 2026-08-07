const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());
app.use(cors());

// Health check route
app.get('/', (req, res) => {
  res.status(200).send('Law Firm Management System Backend is active and running.');
});

// Login endpoint matching your Flutter application route: /login
app.post('/login', (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }

    console.log(`Login attempt for email: ${email}`);

    // Authentication check logic (add database validation here if needed)
    return res.status(200).json({
      message: 'Login successful',
      token: 'mock-jwt-token-12345',
      user: { email }
    });

  } catch (error) {
    console.error('Server error on /login route:', error);
    return res.status(500).json({ message: 'Internal server error during login.' });
  }
});

// Chat endpoint matching your Flutter application route: /chat
app.post('/chat', async (req, res) => {
  try {
    const { prompt, context } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: 'Prompt field is required.' });
    }

    const aiReply = `Analysis regarding "${prompt}" under ${context || 'Ugandan jurisprudence and civil procedure'}: Preliminary statutory review indicates proper adherence to procedure.`;

    return res.status(200).json({
      response: aiReply
    });

  } catch (error) {
    console.error('Server error on /chat route:', error);
    return res.status(500).json({ 
      response: 'Internal server error while processing your legal query.' 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});