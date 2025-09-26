
const mysql = require('mysql2/promise'); // ✅ promise wrapper

const pool = mysql.createPool({
  host: 'DB_HOST', // Replace with your DB host
  user: 'DB_USER', // Replace with your DB user
  password: 'DB_PASSWORD', // Replace with your DB password
  database: "DB_NAME", // Replace with your DB name
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;

