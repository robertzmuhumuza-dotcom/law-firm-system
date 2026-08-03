const express = require('express');
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
    if (error.code === 11000) {
      return res.status(400).json({ success: false, message: 'This email is already registered in the system.' });
    }
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Login Route (Supports both hashed and legacy plain-text passwords)
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

    // Auto-upgrade plain-text passwords to secure hashes upon login
    if (isPlainTextMatch && !isBcryptMatch) {
      user.password = await bcrypt.hash(password, 10);
      await user.save();
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

// Force Reset Password Route (Instantly updates password for your account)
router.post('/reset-password', async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    return res.status(200).json({ success: true, message: 'Password reset successfully. You can now log in.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;