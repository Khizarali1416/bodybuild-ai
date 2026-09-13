import { GoogleGenAI } from '@google/genai';
import dotenv from 'dotenv';
dotenv.config();

async function test() {
  const ai = new GoogleGenAI({ apiKey: process.env.LLM_API_KEY });
  try {
    const responseStream = await ai.models.generateContentStream({
      model: process.env.LLM_MODEL || 'gemini-2.5-flash',
      contents: [{ role: 'user', parts: [{ text: 'Hello' }] }],
    });
    for await (const chunk of responseStream) {
      console.log(chunk.text);
    }
  } catch (e: any) {
    console.error("ERROR CAUGHT:");
    console.error(e.message);
  }
}

test();
