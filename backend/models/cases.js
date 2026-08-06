const mongoose = require('mongoose');

const caseSchema = new mongoose.Schema({
  title: { type: String, required: true },
  clientName: { type: String, required: true },
  description: { type: String },
  status: { type: String, default: 'Active' }
}, { timestamps: true });

// Prevent OverwriteModelError if model is compiled elsewhere
module.exports = mongoose.models.Case || mongoose.model('Case', caseSchema);