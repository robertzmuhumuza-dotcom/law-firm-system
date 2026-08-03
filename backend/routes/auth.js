Lconst express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');

// Register Route
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'This email is already registered.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ 
      email: email.toLowerCase().trim(), 
      password: hashedPassword, 
      name: name || 'User' 
    });
    
    await newUser.save();

    return res.status(201).json({ success: true, message: 'User registered successfully.' });
  } catch (error) {
    // Catch duplicate key error code from MongoDB explicitly
    if (error.code === 11000) {
      return res.status(400).json({ success: false, message: 'This email is already registered in the system.' });
    }
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Login Route (Supports both hashed and plain-text passwords)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(400).json({ success: false, message: 'Invalid email or password.' });
    }

    const isBcryptMatch = await bcrypt.compare(password, user.password).catch(() => false);
    const isPlainTextMatch = (password === user.password);

    if (!isBcryptMatch && !isPlainTextMatch) {
      return res.status(400).json({ success: false, message: 'Invalid email or password.' });
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful.',
      user: {
        id: user._id,
        email: user.email,
        name: user.name || 'User'
      }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;