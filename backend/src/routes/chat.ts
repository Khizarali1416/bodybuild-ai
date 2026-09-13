import { Router, Request, Response } from 'express';
import { llmService, ChatMessage } from '../services/llm.service';

const router = Router();

router.post('/stream', async (req: Request, res: Response) => {
  const { message, history } = req.body;

  if (!message || typeof message !== 'string') {
    return res.status(400).json({ error: 'Message is required and must be a string' });
  }

  const parsedHistory: ChatMessage[] = Array.isArray(history) ? history : [];

  // Set headers for Server-Sent Events (SSE)
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  // Important for CORS if needed, but handled by cors middleware generally
  // res.flushHeaders(); 

  try {
    const stream = llmService.streamChat(parsedHistory, message);
    
    for await (const chunk of stream) {
      // Send chunk as an SSE message
      // Format: data: {chunk}\n\n
      // We need to encode newlines or serialize to JSON so the client can parse it properly
      const dataPayload = JSON.stringify({ chunk });
      res.write(`data: ${dataPayload}\n\n`);
    }

    // Send an end event to tell client we're done
    res.write(`data: [DONE]\n\n`);
    res.end();
  } catch (error) {
    console.error('Streaming error:', error);
    res.write(`data: ${JSON.stringify({ error: 'Internal server error during streaming.' })}\n\n`);
    res.end();
  }
});

// A standard non-streaming endpoint for completeness or fallback
router.post('/', async (req: Request, res: Response) => {
  // Simplistic non-streaming fallback not fully implemented, but returning error to enforce streaming usage
  return res.status(501).json({ error: 'Please use /api/chat/stream for real-time responses.' });
});

export default router;
