const express = require('express');
const router = express.Router();
const FirmModule = require('../models/FirmModule');

// Get all items by module type (case, role, document)
router.get('/:moduleType', async (req, res) => {
  try {
    const { moduleType } = req.params;
    const items = await FirmModule.find({ moduleType }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: items });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Create a new item for any module
router.post('/', async (req, res) => {
  try {
    const { moduleType, title, description, assignedTo, status, fileUrl } = req.body;
    const newItem = new FirmModule({ moduleType, title, description, assignedTo, status, fileUrl });
    await newItem.save();
    res.status(201).json({ success: true, data: newItem });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Delete an item
router.delete('/:id', async (req, res) => {
  try {
    await FirmModule.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true, message: 'Deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;