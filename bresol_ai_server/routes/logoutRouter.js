// routes/logoutRouter.js
const express = require("express");
const router = express.Router();
const logoutController = require("../controllers/logoutController");

// ✅ Logout route
router.post("/logout", logoutController.logoutUser);

module.exports = router;
