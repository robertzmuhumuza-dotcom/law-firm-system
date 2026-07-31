const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Root route so visiting the Render URL doesn't show an error
app.get('/', (req, res) => {
  res.send('Law Firm System Backend is Live!');
});

// Import Auth Routes
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 5000;

// Database Connection & Server Start
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB Connected Successfully');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch((err) => console.log('Database connection error: ', err));