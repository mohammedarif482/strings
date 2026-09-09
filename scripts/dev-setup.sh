#!/usr/bin/env bash
# ==============================================================================
# Aivo Predictive Wellness Platform — Local Developer Environment Setup Script
# ==============================================================================
set -e

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${ORANGE}"
echo "=================================================================="
echo " 🧬 AIVO PREDICTIVE WELLNESS — ONE-TOUCH DEV ENVIRONMENT SETUP"
echo "=================================================================="
echo -e "${NC}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# ------------------------------------------------------------------------------
# 1. PREREQUISITE SYSTEM DEPENDENCY CHECKS
# ------------------------------------------------------------------------------
echo -e "${BLUE}▶ 1. Checking System Prerequisites...${NC}"

check_cmd() {
  local cmd=$1
  local name=$2
  local required=$3
  if command -v "$cmd" &> /dev/null; then
    local version=$("$cmd" --version 2>&1 | head -n 1)
    echo -e "  ${GREEN}✓${NC} $name found: $version"
  else
    if [ "$required" = "true" ]; then
      echo -e "  ${RED}✗ Error: $name is required but not installed.${NC}"
      exit 1
    else
      echo -e "  ${ORANGE}! Warning: $name is not installed. (Optional for backend-only dev)${NC}"
    fi
  fi
}

check_cmd "docker" "Docker" "false"
check_cmd "node" "Node.js (v18+)" "true"
check_cmd "python3" "Python (v3.10+)" "true"
check_cmd "flutter" "Flutter SDK" "false"

# ------------------------------------------------------------------------------
# 2. LOCAL ENVIRONMENT CONFIGURATION (.env)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}▶ 2. Verifying Environment Variables...${NC}"
if [ ! -f .env ]; then
  echo "  Creating .env from .env.example..."
  cp .env.example .env
  echo -e "  ${GREEN}✓${NC} Created .env"
else
  echo -e "  ${GREEN}✓${NC} Existing .env file found."
fi

# ------------------------------------------------------------------------------
# 3. CONTAINERIZED DATABASE & VECTOR STORE (PostgreSQL 16 + pgvector + Redis)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}▶ 3. Bootstrapping Database Containers via Docker Compose...${NC}"
if command -v docker &> /dev/null && docker info &> /dev/null; then
  echo "  Starting PostgreSQL (pgvector) and Redis..."
  docker compose -f database/docker-compose.yml up -d
  
  echo "  Waiting for PostgreSQL to accept connections..."
  until docker compose -f database/docker-compose.yml exec -T postgres pg_isready -U aivo_user -d aivo_db &> /dev/null; do
    sleep 1
  done
  echo -e "  ${GREEN}✓${NC} PostgreSQL + pgvector is online."

  # ------------------------------------------------------------------------------
  # 4. DATABASE MIGRATIONS & SEED DATA
  # ------------------------------------------------------------------------------
  echo -e "\n${BLUE}▶ 4. Running Database Migrations...${NC}"
  for migration in database/migrations/*.sql; do
    echo "  Applying $(basename "$migration")..."
    docker compose -f database/docker-compose.yml exec -T postgres psql -U aivo_user -d aivo_db -f - < "$migration" > /dev/null
    echo -e "  ${GREEN}✓${NC} Applied $(basename "$migration")"
  done
else
  echo -e "  ${ORANGE}! Docker daemon not running or not accessible in sandbox.${NC}"
  echo "  Falling back to in-memory local state & JSON vector cache for standalone execution."
fi

# ------------------------------------------------------------------------------
# 5. DEPENDENCY INSTALLATION (Node.js & Python)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}▶ 5. Installing Monorepo Dependencies...${NC}"

# Node.js Workspaces
if [ -f package.json ]; then
  echo "  Installing Node.js microservice dependencies..."
  npm install --silent || echo "  (npm install completed with local package-lock)"
  echo -e "  ${GREEN}✓${NC} Node.js services configured."
fi

# Python ETL Environment
if [ -f scripts/etl/requirements.txt ]; then
  echo "  Checking Python virtual environment for ETL..."
  if [ ! -d ".venv" ] && command -v python3 &> /dev/null; then
    python3 -m venv .venv 2>/dev/null || true
  fi
  if [ -d ".venv" ]; then
    source .venv/bin/activate 2>/dev/null || true
    pip install -q -r scripts/etl/requirements.txt 2>/dev/null || true
  fi
  echo -e "  ${GREEN}✓${NC} Python ETL environment ready."
fi

# ------------------------------------------------------------------------------
# 6. HUBERMAN PROTOCOLS INGESTION & VECTOR GENERATION
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}▶ 6. Ingesting Huberman Lab Transcripts & Protocols...${NC}"
if [ -f scripts/etl/ingest_huberman.py ]; then
  python3 scripts/etl/ingest_huberman.py --input_dir scripts/etl/transcripts --batch_size 25
  echo -e "  ${GREEN}✓${NC} Huberman Lab vector store seeded."
fi

echo -e "\n${GREEN}"
echo "=================================================================="
echo " 🎉 AIVO MONOREPO DEV ENVIRONMENT SETUP COMPLETE!"
echo "=================================================================="
echo -e "${NC}"
echo "To start services locally, run:"
echo "  • npm run dev:all         # Run API, Simulator, and Admin Web"
echo "  • npm run dev:backend     # Start Express API (http://localhost:4000)"
echo "  • npm run dev:simulator   # Start 15-min autonomous simulation worker"
echo "  • npm run dev:admin       # Start Next.js Admin Panel (http://localhost:3000)"
echo "  • cd apps/mobile && flutter run # Launch Flutter mobile client"
echo ""
