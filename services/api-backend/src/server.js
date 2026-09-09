import http from 'http';
import express from 'express';
import cors from 'cors';
import { WebSocketServer } from 'ws';

import * as auth from './controllers/authController.js';
import * as checkins from './controllers/checkinsController.js';
import * as predictions from './controllers/predictionsController.js';
import * as nudges from './controllers/nudgesController.js';

const app = express();
app.use(cors());
app.use(express.json());

// Routes
app.post('/api/v1/auth/register', auth.register);
app.get('/api/v1/user/profile', auth.getProfile);

app.post('/api/v1/checkins', checkins.createCheckin);
app.get('/api/v1/checkins', checkins.getCheckins);

app.get('/api/v1/predictions/today', predictions.getTodayPrediction);

app.post('/api/v1/nudges', nudges.createNudge);
app.post('/api/v1/nudges/:id/feedback', nudges.submitFeedback);

// SSE Realtime Biometric Telemetry Stream
app.get('/api/v1/stream', (req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  });

  const interval = setInterval(() => {
    const payload = {
      timestamp: new Date().toISOString(),
      event: 'biometric_heartbeat',
      hrv: Math.round(55 + (Math.random() * 10 - 5)),
      resting_hr: Math.round(62 + (Math.random() * 6 - 3))
    };
    res.write(`data: ${JSON.stringify(payload)}\n\n`);
  }, 10000);

  req.on('close', () => clearInterval(interval));
});

// Health check
app.get('/health', (req, res) => {
  res.json({ service: 'api-backend', status: 'healthy', timestamp: new Date().toISOString() });
});

const server = http.createServer(app);

// WebSocket Gateway
const wss = new WebSocketServer({ server, path: '/ws' });
wss.on('connection', (ws) => {
  ws.send(JSON.stringify({ type: 'connected', message: 'Aivo WebSocket Gateway Active' }));
  ws.on('message', (msg) => {
    try {
      const data = JSON.parse(msg.toString());
      ws.send(JSON.stringify({ type: 'ack', echo: data }));
    } catch {
      ws.send(JSON.stringify({ type: 'error', message: 'Invalid JSON' }));
    }
  });
});

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`[API Gateway] Listening on http://localhost:${PORT}`);
  console.log(`[WebSocket] ws://localhost:${PORT}/ws`);
});
