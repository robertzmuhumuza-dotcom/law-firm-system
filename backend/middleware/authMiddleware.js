const jwt = require('jsonwebtoken');

const authorize = (roles = []) => {
    return (req, res, next) => {
        // Get token from header
        const authHeader = req.headers.authorization;
        if (!authHeader) return res.status(401).json({ message: "No token provided" });

        const token = authHeader.split(' ')[1];

        try {
            // Verify token
            const decoded = jwt.verify(token, 'secret_key');
            req.user = decoded; // This will hold the user ID and role

            // Check if user's role is in the allowed list
            if (roles.length && !roles.includes(req.user.role)) {
                return res.status(403).json({ message: "Forbidden: Access denied" });
            }
            
            next(); // User is authorized, proceed
        } catch (err) {
            res.status(401).json({ message: "Invalid token" });
        }
    };
};

module.exports = authorize;