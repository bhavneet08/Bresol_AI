
// routes/registerRoutes.js
const express = require("express");
const router = express.Router();

const { registerUser } = require("../controllers/registerController");

// POST /api/register
router.post("/register", registerUser);

module.exports = router;
