import fs from "fs";
import path from "path";
import { Handler } from "@netlify/functions";

export const handler: Handler = async (event) => {
  if (event.httpMethod !== "POST") {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: "Method Not Allowed" }),
    };
  }

  try {
    const contentType = event.headers["content-type"];
    if (!contentType || !contentType.includes("multipart/form-data")) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Invalid Content-Type" }),
      };
    }

    const boundary = contentType.split("boundary=")[1];
    if (!boundary) {
      return { statusCode: 400, body: JSON.stringify({ error: "Missing boundary" }) };
    }

    // Decode Base64 body and split into parts
    const bodyBuffer = Buffer.from(event.body as string, "base64");
    const parts = bodyBuffer.toString().split(`--${boundary}`);

    const filePart = parts.find((part) => part.includes("filename="));
    if (!filePart) {
      return { statusCode: 400, body: JSON.stringify({ error: "No file found" }) };
    }

    // Extract file name
    const match = filePart.match(/filename="(.+?)"/);
    if (!match) return { statusCode: 400, body: JSON.stringify({ error: "Invalid file" }) };

    const fileName = match[1];
    const filePath = path.join(__dirname, "../../public/logos", fileName);

    // Extract file content
    const fileContent = filePart.split("\r\n\r\n")[1].split("\r\n--")[0];
    fs.writeFileSync(filePath, fileContent, "binary");

    return {
      statusCode: 200,
      body: JSON.stringify({ filePath: `/logos/${fileName}` }),
    };
  } catch (error) {
    console.error("Upload error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to upload file" }),
    };
  }
};
