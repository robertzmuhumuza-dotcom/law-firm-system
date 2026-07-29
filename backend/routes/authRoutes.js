const express = require('express');
const router = express.Router();

// Register Route
router.post('/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        
        if (!name || !email || !password) {
            return res.status(400).json({ error: 'All fields are required' });
        }

        // Return success response for testing
        return res.status(201).json({
            success: true,
            message: 'Staff account registered successfully!',
            user: { name, email, role: role || 'Associate' }
        });
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
});

// Login Route
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        return res.status(200).json({
            success: true,
            message: 'Login successful!',
            token: 'sample-auth-token'
        });
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
});

module.exports = router;