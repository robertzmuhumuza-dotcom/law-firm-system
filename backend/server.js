const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Base Route for Health Check
app.get('/', (req, res) => {
  res.send('Law Firm Backend Server is live and running!');
});

// Route Mounts
app.use('/api/auth', require('./routes/auth'));
app.use('/api/cases', require('./routes/caseRoutes'));
app.use('/api/ai', require('./routes/aiRoutes'));
// app.use('/api/firm', require('./routes/firmRoutes')); // Uncomment if active

// Database Connection & Server Startup
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('MongoDB connected successfully');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch(err => console.error('Database connection error:', err));