
const { CollectionGroup } = require('firebase-admin/firestore');
const pool = require('../config/db');
const jwt = require('jsonwebtoken');
require("dotenv").config();
const JWT_SECRET = process.env.JWT_SECRET;

// Verify OTP Service
exports.verifyOTPService = async (temp_user_id, otp) => {
    if (!temp_user_id || !otp) {
        return { success: false, message: 'All fields are required' };
    }


    try {
        // Fetch unverified user
        const [userResult] = await pool.query(
            'SELECT * FROM users WHERE id = ? AND is_verified = false',
            [temp_user_id]
        );
            console.log(userResult)


        if (userResult.length === 0) {
            return { success: false, message: 'User not found or already verified' };
        }


        const user = userResult[0];

        const nowUTC = new Date().toISOString().slice(0, 19).replace('T', ' ');

        if (!user.otp || new Date(nowUTC) > new Date(user.otp_expires_at)) {
            return { success: false, message: 'OTP expired' };
        }

        if (user.otp !== otp) {
            return { success: false, message: 'Invalid OTP' };
        }

        // Mark user as verified
        await pool.query(
            'UPDATE users SET is_verified = true, otp = NULL, otp_expires_at = NULL WHERE id = ?',
            [temp_user_id]
        );

        console.log(JWT_SECRET)

        // Generate JWT
        const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
        

        return {
            success: true,
            message: "OTP verified successfully",
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                is_verified: true
            }
        };
    } catch (error) {
        console.error("[SERVICE] OTP verify error:", error);
        return { success: false, message: 'Server error' };
    }
};

