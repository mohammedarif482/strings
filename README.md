# strings

# 🧬 Aivo — Predictive Biological Wellness Platform (Monorepo)

A production-grade monorepo containing mobile applications, web admin portals, backend microservices, real-time simulation engines, and Huberman Lab vector retrieval pipelines.

---

## 🏛️ Monorepo Architecture

```
aivo-monorepo/
├── apps/
│   ├── mobile/                    # Flutter App (iOS / Android)
│   │   ├── lib/
│   │   │   ├── main.dart          # Entry point & theme setup
│   │   │   ├── models/            # DailyCheckin, Prediction, PartnerNudge
│   │   │   ├── screens/           # TodayTab, SessionTab, InsightsTab
│   │   │   └── services/          # API Client & WebSocket listener
│   │   └── pubspec.yaml
│   │
│   └── admin-web/                 # Next.js / React Admin Panel
│       ├── src/
│       │   ├── components/        # MetricsCard, PredictionFeed, HubermanChat
│       │   ├── app/               # Dashboard layout & pages
│       │   └── styles/            # Tailwind CSS globals
│       ├── package.json
│       └── tailwind.config.js
│
├── services/
│   ├── api-backend/               # Node.js/Express API Gateway & WebSockets
│   │   ├── src/
│   │   │   ├── controllers/       # Auth, Checkins, Predictions, Nudges
│   │   │   ├── engine/            # Rules-based prediction scoring logic
│   │   │   ├── models/            # Database queries & connection pools
│   │   │   └── server.js          # API & WebSocket gateway
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   └── cloud-simulator/           # Background Biometric Simulation Engine
│       ├── src/
│       │   ├── worker.js          # 15-min synthetic wearable stream generator
│       │   └── physiological.js   # Luteal/HRV noise curve models
│       ├── Dockerfile
│       └── package.json
│
├── scripts/
│   ├── etl/
│   │   ├── ingest_huberman.py     # Python transcript chunker & vector embedder
│   │   └── requirements.txt
│   └── dev-setup.sh               # One-touch local initialization script
│
├── database/
│   ├── migrations/
│   │   ├── 001_core_schema.sql    # Users, Checkins, Wearables, Predictions, Nudges
│   │   ├── 002_content_library.sql# Seed data & state tags
│   │   └── 003_pgvector_rag.sql   # Huberman RAG table & vector indices
│   └── docker-compose.yml         # Local Postgres + pgvector + Redis
│
├── .env.example
├── README.md
└── package.json                   # Root workspace config
```

---

## ⚡ Quick Start

### 1. Run Automated Local Setup
```bash
# Execute the one-touch setup script
bash scripts/dev-setup.sh
```
This script will:
1. Verify system prerequisites (`docker`, `node`, `python3`, `flutter`).
2. Start PostgreSQL with `pgvector` and `Redis` via Docker Compose.
3. Apply SQL migrations (`001` through `003`).
4. Install all npm and Python dependencies.
5. Ingest Huberman transcript vectors into pgvector.

### 2. Launch Local Microservices
```bash
# Run API backend & cloud simulator concurrently
npm run dev:all

# Or run individual services:
npm run dev:backend       # Express API on http://localhost:4000
npm run dev:simulator     # 15-min autonomous simulation worker
npm run dev:admin         # Next.js Admin Console on http://localhost:3000
```

### 3. Run Flutter Mobile Client
```bash
cd apps/mobile
flutter run
```
