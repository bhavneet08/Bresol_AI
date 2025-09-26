
const { verifyOTPService } = require('../services/otpService');

// Controller: Verify OTP
exports.verifyOTP = async (req, res) => {
    try {
        const { temp_user_id, otp } = req.body;
        console.log("[CONTROLLER] Verify OTP request:", { temp_user_id, otp });

        const result = await verifyOTPService(temp_user_id, otp);

        if (!result.success) {
            return res.status(400).json(result);
        }

        return res.status(200).json(result);
    } catch (error) {
        console.error("[CONTROLLER] Verify OTP error:", error);
        return res.status(500).json({ success: false, message: "Server error" });
    }
};
