const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Initialize Express app
const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Import Authentication Routes
const authRoutes = require('./routes/auth');

// Mount routes so they match '/api/auth/login', '/api/auth/register', and '/api/auth/forgot-password'
app.use('/api/auth', authRoutes);

// Root route test
app.get('/', (req, res) => {
  res.send('Law Firm System Backend is running live!');
});

// Database Connection & Server Startup
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'YOUR_MONGODB_CONNECTION_STRING';

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB successfully');
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Database connection error:', err);
  });