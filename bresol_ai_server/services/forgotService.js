const users = require("../models/userModel");

// Check if user exists by email
exports.findUserByEmail = (email) => {
  return users.find((u) => u.email === email);
};

// Dummy email service simulation (in real project use Nodemailer / Firebase)
exports.sendResetLink = (email) => {
  console.log(`📧 Password reset link sent to ${email}`);
  return true;
};
