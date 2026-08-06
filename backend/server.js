const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Database Connection (Uses Render environment variable or local fallback)
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/lawfirm';
mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB connected successfully'))
  .catch((err) => console.error('MongoDB connection error:', err));

// Mount Authentication Routes under /api/auth
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

// Root test route to verify server status
app.get('/', (req, res) => {
  res.status(200).send('Law Firm Backend Server is live and running!');
});

// Server Port Configuration
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});