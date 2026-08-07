const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());
app.use(cors());

// Health check route for browser or Render uptime checks
app.get('/', (req, res) => {
  res.status(200).send('Law Firm Management System Backend is active and running.');
});

// Chat endpoint matching your Flutter application route: /chat
app.post('/chat', async (req, res) => {
  try {
    const { prompt, context } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: 'Prompt field is required.' });
    }

    console.log(`Received query: "${prompt}" with context: "${context}"`);

    // TODO: If you are connecting an external AI API (like OpenAI or Google Gemini), 
    // call it here using your API keys. 

    // Professional legal tech response tailored to your workflow
    const aiReply = `Analysis regarding "${prompt}" under ${context || 'Ugandan jurisprudence and civil procedure'}: Preliminary statutory review indicates proper adherence to procedure. Ensure all pleadings comply with the Civil Procedure Rules.`;

    // Send back the JSON response expected by your Flutter app
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