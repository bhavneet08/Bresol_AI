// services/logoutService.js


require("dotenv").config();

class LogoutService {
  static async logoutUser(userId) {
    try {
      if (!userId) {
        return { success: false, status: 400, message: "User ID is required" };
      }

      // 👉 If you’re using JWT, you typically blacklist the token OR let it expire naturally.
      // For simplicity, we just respond success here.

      console.log(`[LOGOUT SERVICE] User logged out: ${userId}`);

      return {
        success: true,
        status: 200,
        message: "User logged out successfully"
      };
    } catch (err) {
      console.error("[LOGOUT SERVICE] Error:", err);
      return { success: false, status: 500, message: "Server error" };
    }
  }
}

module.exports = LogoutService;
