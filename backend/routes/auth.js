const express = require('express');
const router = express.Router();
const User = require('../models/User'); // Make sure your User model is imported

// Forgot / Reset Password Route
router.post('/forgot-password', async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found with this email.' });
    }

    // Update password (Note: Make sure to hash this if your app uses bcrypt)
    user.password = newPassword; 
    await user.save();

    res.status(200).json({ success: true, message: 'Password updated successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
});

module.exports = router;