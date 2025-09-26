// controllers/logoutController.js
const LogoutService = require("../services/logoutService");

exports.logoutUser = async (req, res) => {
  try {
    // If using JWT: userId can be extracted from token middleware
    const { userId } = req.body; // Or from req.user if middleware is used

    const result = await LogoutService.logoutUser(userId);

    return res.status(result.status).json(result);
  } catch (error) {
    console.error("[LOGOUT CONTROLLER] Error:", error);
    return res.status(500).json({ success: false, message: "Server error" });
  }
};
