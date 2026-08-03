const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Import Routes
const aiRoutes = require('./routes/aiRoutes');
const firmRoutes = require('./routes/firmRoutes');

// Mount Routes
app.use('/api/ai', aiRoutes);
app.use('/api/firm', firmRoutes);

// Root Endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'online',
    message: 'Law Firm Management System Backend is running smoothly.'
  });
});

// MongoDB Connection & Server Start
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB successfully.');
    app.listen(PORT, () => {
      console.log(`Server is running live on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Database connection error:', error.message);
  });