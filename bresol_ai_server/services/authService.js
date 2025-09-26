// services/authService.js
const pool = require("../config/db");
const jwt = require("jsonwebtoken");
const admin = require("../config/firebase");
require("dotenv").config();
const JWT_SECRET = process.env.JWT_SECRET;

class AuthService {
  static async googleLogin(idToken) {
    

    try {
        if (!idToken) {
      return { success: false, status: 400, message: "ID token required" };
    }
      // Verify token with Firebase
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const { uid, email, name, picture } = decodedToken;

      console.log("[GOOGLE LOGIN] Decoded token:", { uid, email, name });

      // Check if user exists
      const [existingUser] = await pool.query(
        "SELECT * FROM users WHERE email = ?",
        [email]
      );

      let user;
      if (existingUser.length > 0) {
        user = existingUser[0];

        if (!user.is_verified) {
          // Mark as verified since Google verified the email
          await pool.query(
            "UPDATE users SET is_verified = true WHERE id = ?",
            [user.id]
          );
          user.is_verified = true;
        }
      } else {
        // Insert new user without password/OTP
        const [result] = await pool.query(
          "INSERT INTO users (username, email, password_hash, is_verified) VALUES (?, ?, ?, ?)",
          [name || "GoogleUser", email, "", true]
        );
        user = {
          id: result.insertId,
          username: name || "GoogleUser",
          email,
          is_verified: true,
        };
      }

      // Generate JWT
      const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: "7d" });

      return {
        success: true,
        status: 200,
        data: {
          token,
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            is_verified: true,
          },
        },
      };
    } catch (err) {
      console.error("[GOOGLE LOGIN] Error:", err);
      return { success: false, status: 500, message: "Invalid Google login" };
    }
  }
}

module.exports = AuthService;
