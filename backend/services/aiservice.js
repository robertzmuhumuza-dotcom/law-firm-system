const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function evaluateEvidence(documentText) {
    try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        // This prompt ensures the output is always a clean, readable summary
        const prompt = `
            You are a professional legal assistant. Analyze the following document text and 
            provide a structured summary in this exact format:
            
            SUMMARY: [A 3-4 sentence overview of the document]
            KEY FACTS: [List the most important facts found]
            LEGAL RISKS: [Identify any potential legal issues or risks]

            Document text: ${documentText}
        `;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        return response.text();
    } catch (error) {
        console.error("AI Service Error:", error);
        return "Could not analyze document at this time.";
    }
}

module.exports = { evaluateEvidence };