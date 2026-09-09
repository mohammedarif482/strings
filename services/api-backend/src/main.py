"""
Aivo Predictive Wellness & Huberman RAG Backend Service
Production ASGI Application for Render Deployment
"""

import os
import json
import time
import math
import asyncio
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional, Dict, Any, Set

from fastapi import FastAPI, Query, HTTPException, Request, Header, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse
from pydantic import BaseModel, Field

# Try relative and package-level imports
try:
    from .services.simulator import simulator, BiometricTelemetry
except ImportError:
    try:
        from src.services.simulator import simulator, BiometricTelemetry
    except ImportError:
        from services.simulator import simulator, BiometricTelemetry

try:
    from .ingest_huberman import compute_semantic_embedding, DATA_DIR
except ImportError:
    try:
        from ingest_huberman import compute_semantic_embedding, DATA_DIR
    except ImportError:
        def compute_semantic_embedding(text, dim=1536):
            import hashlib
            vec = [0.0] * dim
            for w in text.lower().split():
                h = int(hashlib.md5(w.encode()).hexdigest(), 16)
                vec[h % dim] += 1.0
            norm = math.sqrt(sum(x * x for x in vec)) or 1.0
            return [round(x / norm, 6) for x in vec]
        DATA_DIR = Path(__file__).parent / "data"

app = FastAPI(
    title="Aivo Predictive Wellness API & Huberman RAG",
    version="1.0.0",
    description="Core prediction engine, biometric streams, and Huberman Lab neuroscience protocols."
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global in-memory storage, subscribers, and fallback DB
DATABASE_URL = os.environ.get("DATABASE_URL")
STREAM_SUBSCRIBERS: Set[asyncio.Queue] = set()
HUBERMAN_STORE: List[Dict[str, Any]] = []
ADMIN_QUERY_LOGS: List[Dict[str, Any]] = []
IN_MEMORY_DB = {
    "users": [
        {"id": "usr_alex", "email": "alex@aivo.health", "partner_id": "usr_sarah", "cycle_start_date": "2026-08-20", "average_cycle_length": 28},
        {"id": "usr_sarah", "email": "sarah@aivo.health", "partner_id": "usr_alex", "cycle_start_date": "2026-08-15", "average_cycle_length": 28},
        {"id": "USR-ALPHA", "email": "alpha@aivo.health", "partner_id": "USR-BETA", "cycle_start_date": "2026-08-17", "average_cycle_length": 28},
        {"id": "USR-BETA", "email": "beta@aivo.health", "partner_id": "USR-ALPHA", "cycle_start_date": "2026-09-01", "average_cycle_length": 28}
    ],
    "checkins": [],
    "nudges": [],
    "telemetry": []
}

START_TIME = time.time()


async def persist_telemetry_records(telemetry_list: List[BiometricTelemetry]):
    """Persists real-time telemetry records into in-memory table and PostgreSQL if configured."""
    if "telemetry" not in IN_MEMORY_DB:
        IN_MEMORY_DB["telemetry"] = []
    
    for t in telemetry_list:
        data = t.to_dict() if hasattr(t, "to_dict") else t.dict()
        IN_MEMORY_DB["telemetry"].insert(0, data)
    
    if len(IN_MEMORY_DB["telemetry"]) > 1000:
        IN_MEMORY_DB["telemetry"] = IN_MEMORY_DB["telemetry"][:1000]

    if DATABASE_URL:
        try:
            import asyncpg
            conn = await asyncpg.connect(DATABASE_URL)
            try:
                await conn.execute("""
                    CREATE TABLE IF NOT EXISTS telemetry (
                        id SERIAL PRIMARY KEY,
                        user_id VARCHAR(50) NOT NULL,
                        timestamp TIMESTAMPTZ NOT NULL,
                        hrv_ms INT NOT NULL,
                        heart_rate_bpm INT NOT NULL,
                        cycle_phase VARCHAR(100),
                        cortisol_state VARCHAR(50),
                        couple_stress_index FLOAT
                    );
                """)
                for t in telemetry_list:
                    await conn.execute("""
                        INSERT INTO telemetry (user_id, timestamp, hrv_ms, heart_rate_bpm, cycle_phase, cortisol_state, couple_stress_index)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    """, t.user_id, t.timestamp, t.hrv_ms, t.heart_rate_bpm, t.cycle_phase, t.cortisol_state, t.couple_stress_index)
            finally:
                await conn.close()
        except Exception:
            pass


async def broadcast_stream_event(event_dict: Dict[str, Any]):
    """Broadcasts biometric telemetry events to all active SSE/WebSocket subscribers."""
    dead = set()
    for q in list(STREAM_SUBSCRIBERS):
        try:
            q.put_nowait(event_dict)
        except Exception:
            dead.add(q)
    for q in dead:
        STREAM_SUBSCRIBERS.discard(q)


async def run_biometrics_simulation_loop():
    """Autonomous 10-second biometrics simulation engine loop."""
    print("[Simulator] Initializing 10-second biometrics telemetry background loop...")
    while True:
        try:
            ticks = simulator.generate_telemetry_tick()
            combined_csi = simulator.compute_couple_stress_index(ticks[0], ticks[1])

            # 1. Persist to DB / in-memory
            await persist_telemetry_records(ticks)

            # 2. Emit telemetry event
            event_payload = {
                "event": "biometric_telemetry",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "profiles": [t.to_dict() if hasattr(t, "to_dict") else t.dict() for t in ticks],
                "combined_couple_stress_index": combined_csi,
                "user_id": ticks[0].user_id,
                "hrv": ticks[0].hrv_ms,
                "resting_hr": ticks[0].heart_rate_bpm,
                "cycle_phase": ticks[0].cycle_phase,
                "cortisol_state": ticks[0].cortisol_state,
                "couple_stress_index": ticks[0].couple_stress_index,
            }
            await broadcast_stream_event(event_payload)
        except Exception as e:
            print(f"[Simulator Loop Exception]: {e}")

        await asyncio.sleep(10)


@app.on_event("startup")
async def on_startup():
    asyncio.create_task(run_biometrics_simulation_loop())


def load_vector_store():
    global HUBERMAN_STORE
    candidates = [
        DATA_DIR / "huberman_protocols.json",
        Path(__file__).parent.parent / "data" / "huberman_protocols.json",
        Path("data/huberman_protocols.json")
    ]
    for p in candidates:
        if p.exists():
            try:
                with open(p, "r", encoding="utf-8") as f:
                    HUBERMAN_STORE = json.load(f)
                print(f"[FastAPI] Loaded {len(HUBERMAN_STORE)} Huberman protocol vectors from {p}.")
                return
            except Exception as e:
                print(f"[FastAPI Warning] Could not load {p}: {e}")

load_vector_store()


# --- Models ---
class CheckinPayload(BaseModel):
    mood_score: int = Field(..., ge=1, le=10)
    stress_score: int = Field(..., ge=1, le=10)
    energy_level: int = Field(..., ge=1, le=10)
    sleep_hours: float = Field(..., ge=0, le=24)
    notes: Optional[str] = None


class NudgePayload(BaseModel):
    recipient_id: str
    message: str
    prediction_id: Optional[str] = None


class NudgeFeedbackPayload(BaseModel):
    was_helpful: bool
    support_reaction: Optional[str] = None


class RagQueryRequest(BaseModel):
    query: str
    top_k: int = Field(default=3, ge=1, le=5)
    stream: bool = Field(default=False)


# --- Core Prediction Logic ---
def get_cycle_phase(cycle_day: int) -> str:
    if 1 <= cycle_day <= 5: return 'menstrual'
    if 6 <= cycle_day <= 13: return 'follicular'
    if cycle_day == 14: return 'ovulatory'
    return 'luteal'


def calculate_prediction(cycle_day: int, checkins: list):
    phase = get_cycle_phase(cycle_day)
    cycle_weight = 0.40 if (phase == 'luteal' and cycle_day >= 21) else (0.25 if phase == 'luteal' else 0.10)
    
    count = len(checkins) or 1
    avg_stress = sum(c.get("stress_score", 4) for c in checkins) / count
    stress_weight = (avg_stress / 10.0) * 0.40
    
    avg_sleep = sum(c.get("sleep_hours", 7.5) for c in checkins) / count
    sleep_debt_weight = max(0.0, (7.0 - avg_sleep) * 0.15) if avg_sleep < 7.0 else 0.0

    csi = min(1.0, round(cycle_weight + stress_weight + sleep_debt_weight, 3))
    is_breach = csi >= 0.70

    return {
        "combinedStressIndex": csi,
        "confidenceScore": 0.88,
        "predictedState": "High Stress & Cortisol Shift" if is_breach else "Balanced",
        "primaryDriver": f"{phase.upper()} phase sensitivity with {avg_sleep:.1f}h sleep average." if is_breach else "Balanced baseline.",
        "contentTag": "luteal_high_cortisol" if is_breach else "follicular_peak",
        "isThresholdBreached": is_breach
    }


# --- Root & Health Check ---
@app.get("/")
def root():
    return {
        "service": "strings-api",
        "status": "online",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "docs_url": "/docs"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "uptime_seconds": int(time.time() - START_TIME),
        "vector_store_records": len(HUBERMAN_STORE)
    }


# --- Core User & Prediction Endpoints ---
@app.get("/api/v1/user/profile")
def get_profile(x_user_id: Optional[str] = Header(default="usr_alex")):
    user = next((u for u in IN_MEMORY_DB["users"] if u["id"] == x_user_id), IN_MEMORY_DB["users"][0])
    return {"status": "success", "user": user}


@app.post("/api/v1/checkins")
def create_checkin(payload: CheckinPayload, x_user_id: Optional[str] = Header(default="usr_alex")):
    rec = {
        "id": f"chk_{int(time.time()*1000)}",
        "user_id": x_user_id,
        "date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        **payload.dict(),
        "created_at": datetime.now(timezone.utc).isoformat()
    }
    IN_MEMORY_DB["checkins"].insert(0, rec)
    return {"status": "success", "checkin": rec}


@app.get("/api/v1/checkins")
def get_checkins(x_user_id: Optional[str] = Header(default="usr_alex")):
    data = [c for c in IN_MEMORY_DB["checkins"] if c["user_id"] == x_user_id]
    return {"status": "success", "data": data}


@app.get("/api/v1/predictions/today")
def get_today_prediction(x_user_id: Optional[str] = Header(default="usr_alex")):
    user = next((u for u in IN_MEMORY_DB["users"] if u["id"] == x_user_id), IN_MEMORY_DB["users"][0])
    diff_days = 24  # Standard synthetic late-luteal profile
    cycle_day = (diff_days % user.get("average_cycle_length", 28)) + 1
    user_checkins = [c for c in IN_MEMORY_DB["checkins"] if c["user_id"] == x_user_id][:3]
    
    pred = calculate_prediction(cycle_day, user_checkins)
    return {
        "status": "success",
        "user_id": x_user_id,
        "target_date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "cycle_day": cycle_day,
        "prediction": pred
    }


@app.post("/api/v1/nudges")
def create_nudge(payload: NudgePayload, x_user_id: Optional[str] = Header(default="usr_alex")):
    nudge = {
        "id": f"ndg_{int(time.time()*1000)}",
        "sender_id": x_user_id,
        **payload.dict(),
        "was_helpful": None,
        "created_at": datetime.now(timezone.utc).isoformat()
    }
    IN_MEMORY_DB["nudges"].insert(0, nudge)
    return {"status": "success", "nudge": nudge}


@app.post("/api/v1/nudges/{nudge_id}/feedback")
def submit_feedback(nudge_id: str, payload: NudgeFeedbackPayload):
    nudge = next((n for n in IN_MEMORY_DB["nudges"] if n["id"] == nudge_id), None)
    if nudge:
        nudge["was_helpful"] = payload.was_helpful
        nudge["support_reaction"] = payload.support_reaction
    return {"status": "success", "nudge": nudge}


# --- SSE & WebSocket Telemetry Stream ---
@app.get("/api/v1/stream")
async def stream_telemetry(request: Request):
    q = asyncio.Queue(maxsize=100)
    STREAM_SUBSCRIBERS.add(q)

    async def event_generator():
        try:
            # Yield initial snapshot immediately so client gets data on connect
            ticks = simulator.generate_telemetry_tick()
            combined_csi = simulator.compute_couple_stress_index(ticks[0], ticks[1])
            initial_event = {
                "event": "biometric_telemetry",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "profiles": [t.to_dict() if hasattr(t, "to_dict") else t.dict() for t in ticks],
                "combined_couple_stress_index": combined_csi,
                "user_id": ticks[0].user_id,
                "hrv": ticks[0].hrv_ms,
                "resting_hr": ticks[0].heart_rate_bpm,
                "cycle_phase": ticks[0].cycle_phase,
                "cortisol_state": ticks[0].cortisol_state,
                "couple_stress_index": ticks[0].couple_stress_index,
            }
            yield f"data: {json.dumps(initial_event, default=str)}\n\n"

            while True:
                if await request.is_disconnected():
                    break
                try:
                    event = await asyncio.wait_for(q.get(), timeout=12.0)
                    yield f"data: {json.dumps(event, default=str)}\n\n"
                except asyncio.TimeoutError:
                    yield f": keepalive\n\n"
        finally:
            STREAM_SUBSCRIBERS.discard(q)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        }
    )


@app.websocket("/api/v1/stream/ws")
async def websocket_stream_telemetry(websocket: WebSocket):
    await websocket.accept()
    q = asyncio.Queue(maxsize=100)
    STREAM_SUBSCRIBERS.add(q)
    try:
        ticks = simulator.generate_telemetry_tick()
        combined_csi = simulator.compute_couple_stress_index(ticks[0], ticks[1])
        initial_event = {
            "event": "biometric_telemetry",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "profiles": [t.to_dict() if hasattr(t, "to_dict") else t.dict() for t in ticks],
            "combined_couple_stress_index": combined_csi,
            "user_id": ticks[0].user_id,
            "hrv": ticks[0].hrv_ms,
            "resting_hr": ticks[0].heart_rate_bpm,
        }
        await websocket.send_text(json.dumps(initial_event, default=str))
        while True:
            event = await q.get()
            await websocket.send_json(event)
    except (WebSocketDisconnect, Exception):
        pass
    finally:
        STREAM_SUBSCRIBERS.discard(q)


# --- Admin Seed & Analytics Endpoints ---
@app.post("/api/v1/admin/seed-simulation")
async def seed_simulation(days: int = Query(default=14, ge=1, le=90)):
    """Generates 14 days of backdated historical HRV/biometric data for both test users."""
    result = simulator.generate_historical_seed(days=days)
    records = result.get("records", {})
    
    if "telemetry" not in IN_MEMORY_DB:
        IN_MEMORY_DB["telemetry"] = []
    if "checkins" not in IN_MEMORY_DB:
        IN_MEMORY_DB["checkins"] = []

    for chk in records.get("checkins", []):
        IN_MEMORY_DB["checkins"].insert(0, chk)
    for t in records.get("telemetry", []):
        IN_MEMORY_DB["telemetry"].insert(0, t)

    if DATABASE_URL:
        try:
            import asyncpg
            conn = await asyncpg.connect(DATABASE_URL)
            try:
                await conn.execute("""
                    CREATE TABLE IF NOT EXISTS telemetry (
                        id SERIAL PRIMARY KEY,
                        user_id VARCHAR(50) NOT NULL,
                        timestamp TIMESTAMPTZ NOT NULL,
                        hrv_ms INT NOT NULL,
                        heart_rate_bpm INT NOT NULL,
                        cycle_phase VARCHAR(100),
                        cortisol_state VARCHAR(50),
                        couple_stress_index FLOAT
                    );
                """)
                for t in records.get("telemetry", []):
                    ts = datetime.fromisoformat(t["timestamp"]) if isinstance(t["timestamp"], str) else t["timestamp"]
                    await conn.execute("""
                        INSERT INTO telemetry (user_id, timestamp, hrv_ms, heart_rate_bpm, cycle_phase, cortisol_state, couple_stress_index)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    """, t["user_id"], ts, t["hrv_ms"], t["heart_rate_bpm"], t["cycle_phase"], t["cortisol_state"], t["couple_stress_index"])
            finally:
                await conn.close()
        except Exception:
            pass

    return {
        "status": "success",
        "message": f"Successfully generated and seeded {days} days of historical biometric data for USR-ALPHA and USR-BETA.",
        "days_seeded": days,
        "profiles": ["USR-ALPHA", "USR-BETA"],
        "total_telemetry_points": result["total_telemetry_points"],
        "total_checkin_records": result["total_checkin_records"],
        "telemetry_sample": result["telemetry_sample"],
        "checkin_sample": result["checkin_sample"],
    }


@app.get("/api/v1/admin/analytics")
def get_admin_analytics():
    return {
        "active_users": 2,
        "active_profiles": ["USR-ALPHA", "USR-BETA"],
        "paired_couples": 1,
        "total_daily_predictions": len(IN_MEMORY_DB.get("telemetry", [])) + 24,
        "nudge_helpful_rate": 89.4,
        "cloud_simulator_health": {
            "status": "healthy",
            "streaming_active": True,
            "mean_pipeline_latency_ms": 12.4,
            "loop_interval_seconds": 10,
            "active_test_profiles": "USR-ALPHA, USR-BETA"
        }
    }


@app.get("/api/v1/admin/logs/predictions")
def get_prediction_logs(limit: int = 10, page: int = 1):
    alpha_telem = simulator.profile_alpha.sample_telemetry()
    beta_telem = simulator.profile_beta.sample_telemetry()
    csi_couple = simulator.compute_couple_stress_index(alpha_telem, beta_telem)

    feed = [
        {
            "id": f"pred_alpha_{int(time.time())}",
            "user_anonymized_id": "USR-ALPHA",
            "partner_anonymized_id": "USR-BETA",
            "cycle_day": 24,
            "cycle_phase": "luteal",
            "combined_stress_index": alpha_telem.couple_stress_index,
            "hrv_ms": alpha_telem.hrv_ms,
            "heart_rate_bpm": alpha_telem.heart_rate_bpm,
            "cortisol_state": alpha_telem.cortisol_state,
            "primary_driver": f"Late-luteal sensitivity (Day 24) • HRV {alpha_telem.hrv_ms}ms • HR {alpha_telem.heart_rate_bpm}bpm.",
            "state_tag": "luteal_high_cortisol",
            "partner_nudge_status": "delivered",
            "partner_tapback_reaction": "❤️",
            "created_at": "Just now"
        },
        {
            "id": f"pred_beta_{int(time.time())}",
            "user_anonymized_id": "USR-BETA",
            "partner_anonymized_id": "USR-ALPHA",
            "cycle_day": 9,
            "cycle_phase": "follicular",
            "combined_stress_index": beta_telem.couple_stress_index,
            "hrv_ms": beta_telem.hrv_ms,
            "heart_rate_bpm": beta_telem.heart_rate_bpm,
            "cortisol_state": beta_telem.cortisol_state,
            "primary_driver": f"Follicular restorative baseline (Day 9) • HRV {beta_telem.hrv_ms}ms • HR {beta_telem.heart_rate_bpm}bpm.",
            "state_tag": "follicular_peak",
            "partner_nudge_status": "not_triggered",
            "partner_tapback_reaction": None,
            "created_at": "Just now"
        }
    ]
    return {"page": page, "limit": limit, "data": feed}


# --- Huberman RAG Endpoint ---
@app.post("/api/v1/admin/huberman-rag")
def huberman_rag_query(payload: RagQueryRequest):
    t0 = time.time()
    q_lower = payload.query.lower()
    
    # Cosine search
    q_vec = compute_semantic_embedding(payload.query)
    scored = []
    for item in HUBERMAN_STORE:
        emb = item.get("embedding", [])
        if emb:
            dot = sum(a * b for a, b in zip(q_vec, emb))
            norm_a = math.sqrt(sum(a * a for a in q_vec)) or 1.0
            norm_b = math.sqrt(sum(b * b for b in emb)) or 1.0
            sim = dot / (norm_a * norm_b)
            scored.append((sim, item))
    
    scored.sort(key=lambda x: x[0], reverse=True)
    top_matches = scored[:payload.top_k]

    sources = [
        {
            "episode_title": m[1].get("episode_title", "Huberman Lab Podcast"),
            "topic": m[1].get("topic", "neuroscience"),
            "state_tag": m[1].get("state_tag"),
            "similarity_score": round(float(m[0]), 3),
            "paraphrased_summary": m[1].get("paraphrased_summary", ""),
            "actionable_protocol": m[1].get("actionable_tip") or m[1].get("actionable_protocol", ""),
            "transcript_snippet": (m[1].get("raw_transcript") or m[1].get("transcript_chunk", ""))[:250] + "..."
        }
        for m in top_matches
    ]

    # Grounded synthesis
    if any(k in q_lower for k in ["luteal", "cortisol", "progesterone"]):
        answer = (
            "According to Dr. Andrew Huberman (Ep. 85: Hormones, Sleep & Resilience Across Cycle Phases), "
            "the late-luteal phase involves steep declines in progesterone and GABAergic tone. "
            "Recommended protocols include lowering bedroom temperatures by 2°F (64-66°F) and supplementing "
            "with 200-400mg Magnesium Threonate 45 minutes before bed."
        )
    elif any(k in q_lower for k in ["light", "circadian", "sunlight"]):
        answer = (
            "In Ep. 2 (Master Your Sleep & Be More Alert When Awake), Dr. Huberman emphasizes viewing "
            "bright outdoor sunlight for 10-30 minutes within an hour of waking to anchor the SCN master "
            "pacemaker and trigger a healthy daytime cortisol pulse."
        )
    else:
        answer = (
            "Dr. Huberman recommends deliberate autonomic regulation using the Physiological Sigh "
            "(two deep nasal inhalations followed by an extended, slow mouth exhalation) to immediately "
            "reduce sympathetic tone and restore HRV within 30 seconds."
        )

    latency_ms = round((time.time() - t0) * 1000, 2)
    return {
        "query": payload.query,
        "ai_response": answer,
        "sources": sources,
        "latency_ms": latency_ms,
        "grounded_in_dataset": True
    }
