const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Serve static frontend test page if needed
app.use(express.static('public'));

// Import Routes
const authRoutes = require('./routes/auth'); // Ensure this points to your auth route file
const caseRoutes = require('./routes/cases'); // Ensure this points to your cases route file

// Mount Routes with /api prefix
app.use('/api/auth', authRoutes);
app.use('/api/cases', caseRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'Online', message: 'Backend is connected and running successfully' });
});

// Database Connection & Server Start
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => {
    console.log('MongoDB Connected Successfully');
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
})
.catch((err) => {
    console.error('Database connection error:', err);
});