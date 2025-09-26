
const pool = require('../config/db');
const bcrypt = require('bcrypt');
const generateOTP = require('../utils/generateOTP');
const sendOTPEmail = require('../utils/emailService');

exports.registerUserService = async (username, email, password) => {
    
    try {
        if (!username || !email || !password) {
        return { success: false, message: 'All fields are required' };
    }
// Check if user already exists
        const [existingUser] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);

        if (existingUser.length > 0) {
            const user = existingUser[0];
            if (user.is_verified) {
                return { success: false, message: 'Email already exists' };
            } else {
                // User exists but not verified → update OTP
                const otp = generateOTP();
                const otpExpiresAt = new Date(Date.now() + 60 * 1000).toISOString().slice(0, 19).replace('T', ' ');

                await pool.query('UPDATE users SET otp = ?, otp_expires_at = ? WHERE email = ?', [otp, otpExpiresAt, email]);

                // Send OTP in background
                sendOTPEmail(email, otp).catch(err => console.error("[SERVICE] OTP email error:", err));

                return {
                    success: true,
                    temp_user_id: user.id,
                    message: 'New OTP sent to your email. Expires in 1 minute.'
                };
            }
        }

        // New user → hash password & insert
        const hashedPassword = await bcrypt.hash(password, 10);
        const otp = generateOTP();
        const otpExpiresAt = new Date(Date.now() + 60 * 1000).toISOString().slice(0, 19).replace('T', ' ');

        const [result] = await pool.query(
            'INSERT INTO users (username, email, password_hash, otp, otp_expires_at) VALUES (?, ?, ?, ?, ?)',
            [username, email, hashedPassword, otp, otpExpiresAt]
        );

        const userId = result.insertId;

        // Send OTP email
        sendOTPEmail(email, otp).catch(err => console.error("[SERVICE] OTP email error:", err));

        return {
            success: true,
            temp_user_id: userId,
            message: 'OTP sent to your email. Expires in 1 minute.'
        };

    } catch (err) {
        console.error("[SERVICE] Registration error:", err);
        return { success: false, message: 'Error registering user' };
    }
};

