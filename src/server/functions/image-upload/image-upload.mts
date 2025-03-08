import { Handler, HandlerEvent, HandlerResponse } from "@netlify/functions";
import fs from "fs";
import path from "path";
import os from "os";

// Import Busboy dynamically
const Busboy = require("busboy");

export const handler: Handler = async (event: HandlerEvent): Promise<HandlerResponse> => {
  if (event.httpMethod !== "POST") {
    return { statusCode: 405, body: JSON.stringify({ error: "Method Not Allowed" }) };
  }

  try {
    const busboy = new Busboy({ headers: event.headers });
    const tempDir = os.tmpdir(); // Netlify allows writing only to `/tmp`
    let filePath = "";

    return new Promise((resolve, reject) => {
      busboy.on("file", (fieldname, file, filename) => {
        filePath = path.join(tempDir, filename);
        const writeStream = fs.createWriteStream(filePath);
        file.pipe(writeStream);

        writeStream.on("finish", () => {
          resolve({
            statusCode: 200,
            body: JSON.stringify({ filePath: `/tmp/${filename}` }),
          });
        });

        writeStream.on("error", (err) => {
          reject({
            statusCode: 500,
            body: JSON.stringify({ error: "Failed to write file", details: err.message }),
          });
        });
      });

      busboy.on("error", (err) => {
        reject({
          statusCode: 500,
          body: JSON.stringify({ error: "Upload failed", details: err.message }),
        });
      });

      busboy.end(Buffer.from(event.body as string, "base64"));
    });
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to upload file", details: (error as Error).message }),
    };
  }
};
