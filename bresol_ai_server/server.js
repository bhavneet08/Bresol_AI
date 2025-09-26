// const express = require("express");
// const bodyParser = require("body-parser");
// const cors = require("cors");

// const registerRoutes = require("./routes/registerRoutes");
// const loginRoutes = require("./routes/loginRoutes");
// const forgotRoutes = require("./routes/forgotRoutes");
// const resendOtpRoutes = require("./routes/resendotpRoutes"); // ✅ New route
// const otpRoutes = require("./routes/otpRoutes"); // ✅ Import OTP verification route
// const googleAuthRoutes = require('./routes/googleauth');
// const logoutRoutes = require("./routes/logoutRouter");
// const chatHistoryRoutes = require('./routes/chatHistory');







// const app = express();
// const PORT = 5000;

// // Middleware
// app.use(cors());
// app.use(bodyParser.json());

// // Routes
// app.use("/api", registerRoutes);
// app.use("/api", loginRoutes);
// app.use("/api", resendOtpRoutes); // ✅ Mount resend OTP route
// app.use("/api/otp", otpRoutes);          // ✅ /api/otp/verify-email
// app.use('/api', googleAuthRoutes);
// app.use("/api", logoutRoutes);
// app.use("/api", forgotRoutes);
// app.use('/api/chat-history', chatHistoryRoutes);








// app.listen(PORT, () => {
//   console.log(`🚀 Server running on http://localhost:${PORT}`);
// });


const express = require("express");
const cors = require("cors");

// ✅ Route imports
const registerRoutes = require("./routes/registerRoutes");
const loginRoutes = require("./routes/loginRoutes");
const forgotRoutes = require("./routes/forgotRoutes");
const resendOtpRoutes = require("./routes/resendotpRoutes");
const otpRoutes = require("./routes/otpRoutes");
const googleAuthRoutes = require("./routes/googleauth");
const logoutRoutes = require("./routes/logoutRouter");
const chatHistory = require("./routes/chatHistory"); // ✅ Make sure file name matches

const app = express();
const PORT = process.env.PORT || 5000;

// ✅ Middleware
app.use(cors());
app.use(express.json()); // modern way instead of body-parser

// ✅ Health check endpoint (optional but good practice)
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Server is running",
    timestamp: new Date().toISOString(),
  });
});

// ✅ Routes
app.use("/api", registerRoutes);
app.use("/api", loginRoutes);
app.use("/api", resendOtpRoutes);
app.use("/api/otp", otpRoutes);          
app.use("/api", googleAuthRoutes);
app.use("/api", logoutRoutes);
app.use("/api", forgotRoutes);
app.use("/api/chat-history", chatHistory);

// ✅ 404 Handler (for undefined routes)
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  });
});

// ✅ Global error handler (optional but recommended)
app.use((err, req, res, next) => {
  console.error("Global Error:", err);
  res.status(500).json({
    success: false,
    message: "Internal server error",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
});

// ✅ Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
