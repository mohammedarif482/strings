-- Migration 003: Huberman Protocols Vector Store (pgvector)
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS huberman_protocols (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    episode_title VARCHAR(255) NOT NULL,
    topic VARCHAR(100),
    state_tag VARCHAR(100),
    raw_transcript TEXT NOT NULL,
    paraphrased_summary TEXT,
    actionable_tip TEXT,
    transcript_chunk TEXT,
    actionable_protocol TEXT,
    embedding VECTOR(1536),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- HNSW Cosine Vector Index
CREATE INDEX IF NOT EXISTS idx_huberman_protocols_embedding_hnsw 
ON huberman_protocols USING hnsw (embedding vector_cosine_ops);

-- Topic and State Tag Indexing
CREATE INDEX IF NOT EXISTS idx_huberman_protocols_topic ON huberman_protocols(topic);
CREATE INDEX IF NOT EXISTS idx_huberman_protocols_state_tag ON huberman_protocols(state_tag);

-- Admin Query Telemetry Logs
CREATE TABLE IF NOT EXISTS admin_query_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query TEXT NOT NULL,
    retrieved_chunks JSONB,
    ai_response TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_admin_query_logs_created ON admin_query_logs(created_at DESC);
