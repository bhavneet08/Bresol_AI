const forgotService = require("../services/forgotService");

// ✅ Forgot Password
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await forgotService.findUserByEmail(email); // ✅ await here
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Simulate sending reset link
    await forgotService.sendResetLink(email);

    return res.json({
      success: true,
      message: "Password reset link sent to email",
    });
  } catch (error) {
    console.error("❌ Forgot password error:", error);
    return res.status(500).json({ success: false, message: "Server error" });
  }
};
