const express = require('express');
const router = express.Router();
const axios = require('axios');

router.post('/reason', async (req, res) => {
  try {
    const { prompt, contextType, caseDetails } = req.body;
    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      console.error('CRITICAL: GEMINI_API_KEY is missing from environment variables.');
      return res.status(500).json({ success: false, message: 'Server configuration error: API key missing.' });
    }

    const systemPrompt = `
      You are an expert legal AI co-pilot integrated into a Ugandan Law Firm Management System.
      Your expertise covers Ugandan Jurisprudence, statutory frameworks, and evidence evaluation.
    `;

    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
      {
        contents: [
          { 
            role: "user", 
            parts: [
              { text: systemPrompt }, 
              { text: `Context Type: ${contextType}\nCase Details: ${JSON.stringify(caseDetails)}\nQuery: ${prompt}` }
            ] 
          }
        ]
      },
      { headers: { 'Content-Type': 'application/json' } }
    );

    const aiReply = response.data.candidates[0].content.parts[0].text;
    res.status(200).json({ success: true, analysis: aiReply });

  } catch (error) {
    // This will print the full error details in your Render server logs
    console.error('AI Reasoning Detailed Error:', error.response?.data || error.message);
    res.status(500).json({ 
      success: false, 
      message: error.response?.data?.error?.message || 'Failed to generate legal analysis.' 
    });
  }
});

module.exports = router;