// services/resendOtpService.js
const pool = require('../config/db');
const generateOTP = require('../utils/generateOTP');
const sendOTPEmail = require('../utils/emailService');

/**
 * Service to resend OTP for a user
 * @param {string} email
 * @returns {Promise<Object>}
 */
exports.resendOtpService = async (email) => {
    

    try {
        if (!email) {
        return { success: false, message: 'Email is required' };
    }
        const [userResult] = await pool.query(
            'SELECT * FROM users WHERE email = ? AND is_verified = false',
            [email]
        );

        if (userResult.length === 0) {
            return { success: false, message: 'User not found or already verified' };
        }

        const user = userResult[0];

        // Generate new OTP & expiry
        const otp = generateOTP();
        const otpExpiresAt = new Date(Date.now() + 60 * 1000); // 1 minute
        const mysqlOtpExpiresAt = otpExpiresAt.toISOString().slice(0, 19).replace('T', ' ');

        await pool.query(
            'UPDATE users SET otp = ?, otp_expires_at = ? WHERE id = ?',
            [otp, mysqlOtpExpiresAt, user.id]
        );

        // Send OTP email asynchronously
        sendOTPEmail(email, otp)
            .then(() => console.log(`[RESEND SERVICE] OTP email sent to ${email}`))
            .catch((err) => console.error(`[RESEND SERVICE] Email send error:`, err));

        return {
            success: true,
            temp_user_id: user.id,
            message: 'New OTP sent to your email. Expires in 1 minute.'
        };

    } catch (err) {
        console.error('[RESEND SERVICE] Error:', err);
        return { success: false, message: 'Server error' };
    }
};
