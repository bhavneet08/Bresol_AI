
// controllers/loginController.js
const LoginService = require("../services/loginService");

exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  const result = await LoginService.loginUser({ email, password });

  if (result.success) {
    res.status(result.status).json(result.data);
  } else {
    res.status(result.status).json({ message: result.message });
  }
};
