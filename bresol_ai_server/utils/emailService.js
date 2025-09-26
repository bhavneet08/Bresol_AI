const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'bhagatbhavneet@gmail.com',
        pass: 'hiyl mnym muwn mwdj'  
    }
});

async function sendOTPEmail(to, otp) {
    const mailOptions = {
        from: 'bhagatbhavneet@gmail.com',
        to,
        subject: 'Your OTP Code',
        text: `Your verification OTP is ${otp}. It expires in 1 minute.`
    };
    await transporter.sendMail(mailOptions);
}

module.exports = sendOTPEmail;