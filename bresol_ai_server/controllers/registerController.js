
const { registerUserService } = require('../services/registerService');

// Normal Register
exports.registerUser = async (req, res) => {
    try {
        const { username, email, password } = req.body;
        const result = await registerUserService(username, email, password);

        if (!result.success) {
            return res.status(400).json(result);
        }
        return res.json(result);
    } catch (error) {
        console.error("[CONTROLLER] Register error:", error);
        return res.status(500).json({ success: false, message: "Server error" });
    }
};

