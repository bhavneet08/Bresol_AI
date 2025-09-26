// services/loginService.js
const pool = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
require("dotenv").config();
const JWT_SECRET = process.env.JWT_SECRET;

class LoginService {
  static async loginUser({ email, password }) {
    
    try {
      if (!email || !password) {
      return { success: false, status: 400, message: "Email and password are required" };
    }

      console.log("[LOGIN SERVICE] Looking up user:", email);
      const [userResult] = await pool.query(
        "SELECT * FROM users WHERE email = ?",
        [email]
      );

      if (userResult.length === 0) {
        return { success: false, status: 400, message: "Invalid email or password" };
      }

      const user = userResult[0];

      if (!user.is_verified) {
        return { success: false, status: 400, message: "Please verify your email before logging in" };
      }

      const passwordMatch = await bcrypt.compare(password, user.password_hash);
      if (!passwordMatch) {
        return { success: false, status: 400, message: "Invalid email or password" };
      }

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
            is_verified: !!user.is_verified,
          },
        },
      };
    } catch (err) {
      console.error("[LOGIN SERVICE] Error:", err);
      return { success: false, status: 500, message: "Server error" };
    }
  }
}

module.exports = LoginService;


// services/loginService.js
// const pool = require("../config/db");
// const bcrypt = require("bcrypt");
// const jwt = require("jsonwebtoken");
// require("dotenv").config();

// const JWT_SECRET = process.env.JWT_SECRET;

// class LoginService {
//   static async loginUser({ email, password }) {
//     try {
//       if (!email || !password) {
//         return {
//           success: false,
//           status: 400,
//           message: "Email and password are required",
//         };
//       }

//       console.log("[LOGIN SERVICE] Looking up user:", email);

//       // ✅ Use a dedicated connection to ensure proper release
//       const connection = await pool.getConnection();
//       try {
//         const [userResult] = await connection.query(
//           "SELECT * FROM users WHERE email = ?",
//           [email]
//         );

//         if (userResult.length === 0) {
//           return {
//             success: false,
//             status: 400,
//             message: "Invalid email or password",
//           };
//         }

//         const user = userResult[0];

//         if (!user.is_verified) {
//           return {
//             success: false,
//             status: 400,
//             message: "Please verify your email before logging in",
//           };
//         }

//         const passwordMatch = await bcrypt.compare(password, user.password_hash);
//         if (!passwordMatch) {
//           return {
//             success: false,
//             status: 400,
//             message: "Invalid email or password",
//           };
//         }

//         const token = jwt.sign({ userId: user.id }, JWT_SECRET, {
//           expiresIn: "7d",
//         });

//         return {
//           success: true,
//           status: 200,
//           data: {
//             token,
//             user: {
//               id: user.id,
//               username: user.username,
//               email: user.email,
//               is_verified: !!user.is_verified,
//             },
//           },
//         };
//       } finally {
//         // ✅ Always release connection
//         connection.release();
//       }
//     } catch (err) {
//       console.error("[LOGIN SERVICE] Error:", err);
//       return {
//         success: false,
//         status: 500,
//         message: "Server error",
//         error: process.env.NODE_ENV === "development" ? err.message : undefined,
//       };
//     }
//   }
// }

// module.exports = LoginService;
