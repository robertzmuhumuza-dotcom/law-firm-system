const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');

// Instant Browser Password Fixer (Visit this URL in your browser to reset password to 12345678)
router.get('/fix-password', async (req, res) => {
  try {
    const user = await User.findOne({ email: 'robertzmuhumuza@gmail.com' });
    if (!user) {
      return res.status(404).send('User not found in database.');
    }

    user.password = await bcrypt.hash('12345678', 10);
    await user.save();

    return res.status(200).send('<h1>Success! Password has been reset to: 12345678</h1><p>You can now go back to your phone app and log in.</p>');
  } catch (error) {
    return res.status(500).send('Error: ' + error.message);
  }
});

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

// Login Route
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

module.exports = router;