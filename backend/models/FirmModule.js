const mongoose = require('mongoose');

const firmModuleSchema = new mongoose.Schema({
  moduleType: { type: String, required: true, enum: ['case', 'role', 'document'] },
  title: { type: String, required: true },
  description: { type: String },
  assignedTo: { type: String }, // For Role Assignments & Case tracking
  status: { type: String, default: 'Active' }, // Active, Pending, Completed
  fileUrl: { type: String }, // For Document Storage
  metadata: { type: mongoose.Schema.Types.Mixed },
}, { timestamps: true });

module.exports = mongoose.model('FirmModule', firmModuleSchema);