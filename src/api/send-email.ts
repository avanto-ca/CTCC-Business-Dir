import { Resend } from 'resend';

const resend = new Resend(import.meta.env.VITE_RESEND_API_KEY);

export async function sendEmail(req: Request) {
    console.log("api");
  try {
    const {
      firstName,
      lastName,
      email,
      phone,
      message,
      recipientName,
      recipientEmail
    } = await req.json();

    const { data, error } = await resend.emails.send({
      from: 'CTCC Directory <no-reply@ctcc.ca>',
      to: recipientEmail,
      subject: `New Contact Form Message from ${firstName} ${lastName}`,
      html: `
        <h2>New Message from CTCC Directory Contact Form</h2>
        <p><strong>From:</strong> ${firstName} ${lastName}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Phone:</strong> ${phone}</p>
        <p><strong>Message:</strong></p>
        <p>${message}</p>
      `,
    });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
      });
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Failed to send email' }), {
      status: 500,
    });
  }
}