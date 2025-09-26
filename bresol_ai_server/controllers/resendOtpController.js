// controllers/resendOtpController.js
const { resendOtpService } = require('../services/resendOtpService');

/**
 * Controller to handle resend OTP API
 */
exports.resendOTP = async (req, res) => {
    const { email } = req.body;

    console.log('[RESEND CONTROLLER] Incoming request:', { email });

    try {
        const result = await resendOtpService(email);
        if (result.success) {
            res.json(result);
        } else {
            res.status(400).json(result);
        }
    } catch (err) {
        console.error('[RESEND CONTROLLER] Error:', err);
        res.status(500).json({ message: 'Server error' });
    }
};
