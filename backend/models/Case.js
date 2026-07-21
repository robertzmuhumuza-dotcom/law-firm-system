const mongoose = require('mongoose');

const CaseSchema = new mongoose.Schema({
    caseNumber: { type: String, required: true },
    clientName: { type: String, required: true },
    caseDescription: { type: String, required: true },
    // Fields for Phase 2
    assignedTo: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        default: null 
    },
    status: { 
        type: String, 
        enum: ['Pending', 'In Progress', 'Closed'], 
        default: 'Pending' 
    },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Case', CaseSchema);