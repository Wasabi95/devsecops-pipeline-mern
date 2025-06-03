// // // server/server.js
import express from 'express';
import dotenv from 'dotenv';
import connectDB from './config/db.js';
import userRoutes from './routes/userRoutes.js';
import taskRoutes from './routes/taskRoutes.js';
import { errorHandler } from './middleware/errorMiddleware.js';
import logger from './utils/logger.js';
import cors from 'cors';
import path from 'path';
import helmet from 'helmet';
import morgan from 'morgan';
import { fileURLToPath } from 'url';

// Fix for __dirname in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ✅ Correct staticDir definition (only once!)
const staticDir = path.join(__dirname, '../client/dist');

// Load environment variables
dotenv.config();
const app = express();

// ✅ Serve static files in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(staticDir));
  logger.info(`Serving static files from: ${staticDir}`);
}

// ✅ Validate required environment variables
const requiredEnvVars = ['PORT', 'MONGO_URI', 'JWT_SECRET'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    logger.error(`Missing required environment variable: ${envVar}`);
    process.exit(1);
  }
}

// ✅ Connect to MongoDB
connectDB();

// ====================== SECURITY MIDDLEWARE ======================
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        connectSrc: [
          "'self'",
          "https://task-mngmt-infoempleados.onrender.com",
          "ws://localhost:5173",
          "http://3.84.216.152",
          "ws://3.84.216.152", // if using websockets
          "https://task-mngmt-infoempleados.onrender.com",
          "ws://localhost:5173" // for dev

        ],
        scriptSrc: ["'self'", "'unsafe-eval'", "'unsafe-inline'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        fontSrc: ["'self'", "data:"],
        imgSrc: ["'self'", "data:", "blob:"],
        objectSrc: ["'none'"],
        upgradeInsecureRequests: [],
        frameAncestors: ["'none'"],
        formAction: ["'self'"]
      }
    },
    crossOriginEmbedderPolicy: false,
    crossOriginResourcePolicy: { policy: "same-site" }
  })
);

app.use(helmet.permittedCrossDomainPolicies());
app.use(helmet.referrerPolicy({ policy: 'same-origin' }));
app.use(helmet.xssFilter());

// ====================== CORS ======================
const allowedOrigins = [
  'http://localhost:5173',
  'http://localhost:3000',
  "http://3.84.216.152", // add this
  "https://3.84.216.152", // if using HTTPS
  'https://task-mngmt-infoempleados.onrender.com',
  'https://your-production-domain.com' // ✅ Replace with actual production domain
];
const corsOptions = {
  origin: function (origin, callback) {
    console.log("🌍 Incoming request from origin:", origin);
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true, // important if using cookies or auth headers
};


app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.indexOf(origin) !== -1) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
  })
);

// ====================== MIDDLEWARE ======================
app.use(
  morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev', {
    stream: {
      write: (message) => logger.http(message.trim())
    }
  })
);

app.use(express.json({ limit: '10kb' }));

app.use(cors(corsOptions));

// ====================== ROUTES ======================
app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date() });
});

// ====================== FRONTEND SERVING ======================
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(staticDir));

  // ✅ Handle SPA routing for non-API paths
  app.get(/^(?!\/api).*/, (req, res) => {
    res.sendFile(path.join(staticDir, 'index.html'));
  });
}

// ====================== ERROR HANDLING ======================
app.all('*', (req, res) => {
  if (req.path.startsWith('/api')) {
    res.status(404).json({
      status: 'fail',
      message: `Can't find ${req.originalUrl} on this server!`
    });
  } else {
    res.sendFile(path.join(staticDir, 'index.html'));
  }
});

// ====================== START SERVER ======================
const PORT = process.env.PORT || 7000;
const server = app.listen(PORT, () =>
  logger.info(`🚀 Server running in ${process.env.NODE_ENV} mode on port ${PORT}`)
);

// ====================== GRACEFUL SHUTDOWN ======================
const exitHandler = () => {
  if (server) {
    server.close(() => {
      logger.info('Server closed');
      process.exit(1);
    });
  } else {
    process.exit(1);
  }
};

const unexpectedErrorHandler = (error) => {
  logger.error(`Unhandled error: ${error}`);
  exitHandler();
};

process.on('uncaughtException', unexpectedErrorHandler);
process.on('unhandledRejection', unexpectedErrorHandler);

process.on('SIGTERM', () => {
  logger.warn('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Server closed.');
    process.exit(0);
  });
});
