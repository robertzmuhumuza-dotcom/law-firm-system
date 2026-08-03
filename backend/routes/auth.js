// Login Route (Supports legacy plain-text and upgrades to bcrypt)
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

    // If it matched via plain text, upgrade it to a secure bcrypt hash automatically
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