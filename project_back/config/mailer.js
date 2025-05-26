const nodemailer = require('nodemailer');

// Transporteur SMTP générique (à adapter pour la prod)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.SMTP_USER || 'kylian.deley@gmail.com',
    pass: process.env.SMTP_PASS || 'layq hpsk qqvz nznh',
  },
});

function sendMail({ to, subject, text, html }) {
  return transporter.sendMail({
    from: process.env.SMTP_USER || 'kylian.deley@gmail.com',
    to,
    subject,
    text,
    html,
  });
}

module.exports = { sendMail };
