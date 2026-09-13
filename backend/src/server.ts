import 'dotenv/config'; // Load env vars before other imports
import express from 'express';
import cors from 'cors';
import chatRoutes from './routes/chat';

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/chat', chatRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(port, () => {
  console.log(`BodyBuild AI Backend running on port ${port}`);
});
