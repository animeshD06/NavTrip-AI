import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { env } from './config/env.js';
import achievementsRoutes from './routes/achievements.routes.js';
import adminRoutes from './routes/admin.routes.js';
import aiRoutes from './routes/ai.routes.js';
import analyticsRoutes from './routes/analytics.routes.js';
import assistantRoutes from './routes/assistant.routes.js';
import authRoutes from './routes/auth.routes.js';
import communityRoutes from './routes/community-routes.routes.js';
import guidePacksRoutes from './routes/guide-packs.routes.js';
import healthRoutes from './routes/health.routes.js';
import itinerariesRoutes from './routes/itineraries.routes.js';
import narrationsRoutes from './routes/narrations.routes.js';
import placesRoutes from './routes/places.routes.js';
import recommendationsRoutes from './routes/recommendations.routes.js';
import socialRoutes from './routes/social.routes.js';
import storiesRoutes from './routes/stories.routes.js';
import tripsRoutes from './routes/trips.routes.js';
import weatherCrowdRoutes from './routes/weather-crowd.routes.js';
import { httpError, sendError } from './utils/http.js';

const app = express();

app.use(helmet());
app.use(
  cors({
    origin(origin, callback) {
      if (!origin || env.corsOrigins.length === 0 || env.corsOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(httpError(403, 'Forbidden', 'Not allowed by CORS'));
    },
  }),
);
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: true,
    legacyHeaders: false,
  }),
);
app.use(express.json());
app.use(morgan('dev'));

app.get('/', (req, res) => {
  res.json({
    service: 'navtrip-ai-backend',
    status: 'ok',
    message: 'NavTrip AI backend is running. Use the Flutter frontend or the /api endpoints.',
    endpoints: {
      health: '/api/health',
      places: '/api/places',
      itineraries: '/api/itineraries',
      trips: '/api/trips',
      auth: '/api/auth',
      guidePacks: '/api/guide-packs',
      narrations: '/api/narrations',
      communityRoutes: '/api/routes',
      recommendations: '/api/recommendations',
      assistant: '/api/assistant',
      achievements: '/api/achievements',
      social: '/api/social',
      weatherCrowd: '/api/weather-crowd',
      analytics: '/api/analytics',
    },
  });
});

app.use('/api/achievements', achievementsRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/assistant', assistantRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/guide-packs', guidePacksRoutes);
app.use('/api/places', placesRoutes);
app.use('/api/narrations', narrationsRoutes);
app.use('/api/recommendations', recommendationsRoutes);
app.use('/api/routes', communityRoutes);
app.use('/api/social', socialRoutes);
app.use('/api/stories', storiesRoutes);
app.use('/api/trips', tripsRoutes);
app.use('/api/itineraries', itinerariesRoutes);
app.use('/api/weather-crowd', weatherCrowdRoutes);

app.use((req, res) => {
  sendError(res, 404, 'NotFound', `No route found for ${req.method} ${req.originalUrl}`);
});

app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;

  sendError(
    res,
    statusCode,
    err.name || 'InternalServerError',
    err.message || 'Something went wrong',
  );
});

export default app;
