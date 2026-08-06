const express = require('express');
const router = express.Router();
const Case = require('../models/Case'); // Matches Case.js exactly

// Get all cases -> /api/cases
router.get('/', async (req, res) => {
  try {
    const caseList = await Case.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: caseList });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Create a new case -> /api/cases
router.post('/', async (req, res) => {
  try {
    const newCase = new Case(req.body);
    const savedCase = await newCase.save();
    res.status(201).json({ success: true, data: savedCase, message: 'Case created successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;