const express = require("express");
const { forgotPassword } = require("../controllers/forgotController");

const router = express.Router();

router.post("/forgot", forgotPassword);

module.exports = router;
