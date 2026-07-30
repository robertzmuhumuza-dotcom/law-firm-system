const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Import Routes
const authRoutes = require('./routes/auth');
const caseRoutes = require('./routes/cases');

// Mount Routes
app.use('/api/auth', authRoutes);
app.use('/api/cases', caseRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'Online', message: 'Backend service is active' });
});

// Root fallback
app.get('/', (req, res) => {
    res.status(200).send('Law Firm Management System Backend is Live');
});

// Database & Server Initialization
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI)
.then(() => {
    console.log('MongoDB Connected Successfully');
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
})
.catch((err) => {
    console.error('Database connection error:', err);
});