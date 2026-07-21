const express = require('express');
const router = express.Router();
const authorize = require('../middleware/authMiddleware');
const multer = require('multer');
const fs = require('fs');
const pdf = require('pdf-parse');
const { evaluateEvidence } = require('../services/aiService'); // Corrected path

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage: storage });

router.post('/:id/upload', authorize(['admin', 'lawyer']), upload.single('document'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: "No file uploaded" });

        const filePath = req.file.path;
        
        // Read and extract PDF text
        let dataBuffer = fs.readFileSync(filePath);
        const data = await pdf(dataBuffer);
        
        // Send extracted text to AI service
        const aiAnalysis = await evaluateEvidence(data.text);
        
        res.json({ 
            message: "File analyzed successfully", 
            analysis: aiAnalysis 
        });
    } catch (err) {
        res.status(500).json({ error: "Processing failed: " + err.message });
    }
});

module.exports = router;