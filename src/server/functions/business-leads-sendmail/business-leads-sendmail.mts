import { Handler } from '@netlify/functions';
import { Resend } from 'resend';
import { config } from 'dotenv';

config({ path: '.env' });

const resend = new Resend(process.env.VITE_RESEND_API_KEY || '');

export const handler: Handler = async (event) => {
  try {
    if (event.httpMethod !== 'POST') {
      return {
        statusCode: 405,
        body: JSON.stringify({ error: 'Method Not Allowed' }),
      };
    }

    const body = JSON.parse(event.body || '{}');

    const {
        name, email, phone, message,
        businessType,recipientEmail
    } = body;

    // if (!firstName || !lastName || !email || !phone || !message) {
    //   return {
    //     statusCode: 400,
    //     body: JSON.stringify({ error: 'All fields are required' }),
    //   };
    // }

    if (!process.env.VITE_RESEND_API_KEY) {
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'Missing email API key' }),
      };
    }

    // Determine recipients - always include admin, include member if they have an email
    const recipients = ['admin@ctcc.ca'];
    if (recipientEmail) {
      recipients.unshift(recipientEmail);
    }

    const { data, error } = await resend.emails.send({
      from: 'CTCC Directory <no-reply@smtp.ctcc.ca>',
      to: recipientEmail,
      subject: `[CTCC Directory] New Message from ${name}`,
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
                      <td style="padding: 8px 0; color: #6b7280; width: 120px;">Business/Owner Name:</td>
                      <td style="padding: 8px 0; color: #111827; font-weight: 500;">${name}</td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Email:</td>
                      <td style="padding: 8px 0; color: #111827;">
                        <a href="mailto:${email}" style="color: #7c3aed; text-decoration: none;">${email}</a>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Phone:</td>
                      <td style="padding: 8px 0; color: #111827; font-weight: 500;">${phone}</td>
                    </tr>
                    <tr>
                      <td style="padding: 8px 0; color: #6b7280;">Business Type:</td>
                      <td style="padding: 8px 0; color: #111827; font-weight: 500;">${businessType}</td>
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
                Please do not reply to this email.
              </p>
            </div>
          </div>
        </body>
        </html>
      `, // Replace with your full email template
    });

    if (error) {
      throw new Error(error.message);
    }

    return {
      statusCode: 200,
      body: JSON.stringify({ success: true, data }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to send email' }),
    };
  }
};
