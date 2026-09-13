import { GoogleGenAI } from '@google/genai';
import { BODYBUILDING_SYSTEM_PROMPT } from '../system_prompt';
import { ragService } from './rag.service';

export interface ChatMessage {
  role: 'user' | 'model';
  parts: { text: string }[];
}

export class LlmService {
  private ai: GoogleGenAI | null = null;
  private modelName: string;

  constructor() {
    // Model loaded dynamically in streamChat
  }

  /**
   * Generates a streaming response for the chat.
   * @param history The conversation history
   * @param latestMessage The latest user message
   * @returns Async generator yielding chunks of text
   */
  async *streamChat(history: ChatMessage[], latestMessage: string): AsyncGenerator<string, void, unknown> {
    const apiKey = process.env.LLM_API_KEY;
    if (!apiKey) {
      yield "Error: LLM API key not configured on the backend. Please check the environment variables.";
      return;
    }

    if (!this.ai) {
      this.ai = new GoogleGenAI({ apiKey });
    }

    try {
      // Retrieve optional knowledge base context
      const context = await ragService.retrieveContext(latestMessage);
      
      let finalPrompt = latestMessage;
      if (context) {
        finalPrompt = `Context information is below.\n---------------------\n${context}\n---------------------\nGiven the context information and not prior knowledge, answer the following question: ${latestMessage}`;
      }

      // Prepare contents for Gemini API format
      const contents = history.map(msg => ({
        role: msg.role,
        parts: msg.parts
      }));

      // Add the latest message
      contents.push({
        role: 'user',
        parts: [{ text: finalPrompt }]
      });

      const modelToUse = process.env.LLM_MODEL || 'gemini-3.6-flash';

      const responseStream = await this.ai.models.generateContentStream({
        model: modelToUse,
        contents: contents,
        config: {
          systemInstruction: BODYBUILDING_SYSTEM_PROMPT,
          temperature: 0.7,
        }
      });

      for await (const chunk of responseStream) {
        if (chunk.text) {
          yield chunk.text;
        }
      }
    } catch (error: any) {
      console.error("LLM Generation Error:", error);
      yield `\n\n[Error communicating with AI service. Please try again later.]`;
    }
  }
}

export const llmService = new LlmService();
