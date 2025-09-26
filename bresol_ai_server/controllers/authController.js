// controllers/authController.js
const AuthService = require("../services/authService");

exports.googleLogin = async (req, res) => {
  const { idToken } = req.body;

  const result = await AuthService.googleLogin(idToken);

  if (result.success) {
    res.status(result.status).json(result.data);
  } else {
    res.status(result.status).json({ message: result.message });
  }
};
