const express = require('express');
const router = express.Router();
const axios = require('axios');

// Endpoint for live legal reasoning, evidence evaluation, and law referencing
router.post('/reason', async (req, res) => {
  try {
    const { prompt, contextType, caseDetails } = req.body;

    // Construct a robust system prompt tailored to Ugandan and International Law
    const systemPrompt = `
      You are an expert legal AI co-pilot integrated into a Ugandan Law Firm Management System.
      Your expertise covers:
      1. Ugandan Jurisprudence (Statutes, Acts, Constitution of Uganda, and precedents from ULII/Courts of Record like the Supreme Court, Court of Appeal, and High Court).
      2. Comparative International Law and multi-jurisdictional frameworks.
      3. Evidence evaluation, logical consistency checks, and identifying legal risks.

      Always maintain analytical precision, cite relevant legal principles or hypothetical/real statutory context accurately, and evaluate evidence objectively.
    `;

    // Call the Gemini API model
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
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
    console.error('AI Reasoning Error:', error.response?.data || error.message);
    res.status(500).json({ success: false, message: 'Failed to generate legal analysis.' });
  }
});

module.exports = router;