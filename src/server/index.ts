
import express from 'express';
import cors from 'cors';
import { Resend } from 'resend';
import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import fs from 'node:fs';

config({ path: '.env' });

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('dist'));

const resend = new Resend(process.env.VITE_RESEND_API_KEY || '');

app.post('/send-email', async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      email,
      phone,
      message,
      recipientName,
      recipientEmail,
      category,
      businessUrl,
      currentPath,
      businessName
    } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !email || !phone || !message) {
      return res.status(400).json({
        error: 'All fields are required'
      });
    }

    if (!process.env.VITE_RESEND_API_KEY) {
      return res.status(500).json({ 
        error: 'Email service not configured. Please set VITE_RESEND_API_KEY in your .env file.'
      });
    }

    // Determine recipients - always include admin, include member if they have an email
    const recipients = ['admin@ctcc.ca'];
    if (recipientEmail) {
      recipients.unshift(recipientEmail);
    }

    const { data, error } = await resend.emails.send({
      from: 'CTCC Directory <no-reply@smtp.ctcc.ca>',
      to: recipients,
      subject: `[CTCC Directory] New Message from ${firstName} ${lastName} - ${category} - ${recipientName}`,
      html: `<!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        </head>
        <body style="background-color: #f6f9fc; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'; padding: 20px;">
          <div style="max-width: 600px; margin: 0 auto; background-color: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
            <!-- Header -->
            <div style="background: linear-gradient(to right, #7c3aed, #6366f1); padding: 40px 20px; text-align: center;">
              <h1 style="color: white; margin: 0; font-size: 24px; font-weight: 600;">New Message Received</h1>
              <p style="color: rgba(255, 255, 255, 0.9); margin: 10px 0 0; font-size: 16px;">
                via CTCC Business Directory<br>
                <span style="font-size: 14px; opacity: 0.9;">${category ? category.replace(/([A-Z])/g, ' $1').trim() : 'General'} Category</span>
              </p>
            </div>
            
            <!-- Content -->
            <div style="padding: 32px 24px;">
              <!-- Business Profile Info -->
              <div style="margin-bottom: 32px;">
                <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 16px;">Business Profile Information</h2>
                <div style="background-color: #f9fafb; border-radius: 12px; padding: 20px;">
                  <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280; width: 120px;">Business:</td>
                      <td style="padding: 8px 0; color: #111827; font-weight: 500;">${recipientName}</td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Category:</td>
                      <td style="padding: 8px 0; color: #111827; font-weight: 500;">${category.replace(/([A-Z])/g, ' $1').trim()}</td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Email:</td>
                      <td style="padding: 8px 0; color: #111827;">
                        <a href="mailto:${recipientEmail}" style="color: #7c3aed; text-decoration: none;">${recipientEmail}</a>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Profile URL:</td>
                      <td style="padding: 8px 0;">
                        <a href="${businessUrl}" style="color: #7c3aed; text-decoration: none; word-break: break-all;" target="_blank">
                          ${businessUrl}
                        </a>
                      </td>
                    </tr>
                  </table>
                </div>
              </div>

              <!-- Sender Info -->
              <div style="margin-bottom: 32px;">
                <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 16px;">Sender Information</h2>
                <div style="background-color: #f9fafb; border-radius: 12px; padding: 20px;">
                  <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280; width: 120px;">Name:</td>
                      <td style="padding: 8px 0; color: #111827; font-weight: 500;">${firstName} ${lastName}</td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Email:</td>
                      <td style="padding: 8px 0;">
                        <a href="mailto:${email}" style="color: #7c3aed; text-decoration: none;">${email}</a>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Phone:</td>
                      <td style="padding: 8px 0;">
                        <a href="tel:${phone}" style="color: #7c3aed; text-decoration: none;">${phone}</a>
                      </td>
                    </tr>
                  </table>
                </div>
              </div>
              
              <!-- Message -->
              <div>
                <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 16px;">Message</h2>
                <div style="background-color: #f9fafb; border-radius: 12px; padding: 20px;">
                  <p style="color: #374151; line-height: 1.6; margin: 0; white-space: pre-wrap;">${message}</p>
                </div>
              </div>
            </div>
            
            <!-- Footer -->
            <div style="background-color: #f9fafb; padding: 24px; text-align: center; border-top: 1px solid #e5e7eb;">
              <p style="color: #6b7280; font-size: 14px; margin: 0;">
                This is an automated message from the CTCC Business Directory - ${category} Category.
                <br>Please do not reply to this email.
              </p>
            </div>
          </div>
        </body>
        </html>
      `,
    });

    if (error) {
      throw new Error(error.message);
    }

    return res.status(200).json({ success: true });
  } catch (error) {
    console.error('Email sending error:', error);
    return res.status(500).json({ error: 'Failed to send email' });
  }
});

// Handle React Router routes
app.get('*', (req, res) => {
  const indexPath = path.join(process.cwd(), 'dist', 'index.html');
  if (!fs.existsSync(indexPath)) { 
    return res.status(404).send('Application not built. Please run npm run build first.');
  }
  res.sendFile(indexPath);
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});