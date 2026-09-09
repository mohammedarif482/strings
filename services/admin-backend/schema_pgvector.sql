-- PostgreSQL + pgvector Schema for Huberman Lab Vector Store & Admin Telemetry
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS huberman_protocols (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    episode_title VARCHAR(255) NOT NULL,
    topic VARCHAR(100) NOT NULL,
    state_tag VARCHAR(100),
    transcript_chunk TEXT NOT NULL,
    paraphrased_summary TEXT NOT NULL,
    actionable_protocol TEXT NOT NULL,
    embedding VECTOR(1536),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_huberman_protocols_embedding_hnsw 
ON huberman_protocols USING hnsw (embedding vector_cosine_ops);

CREATE TABLE IF NOT EXISTS admin_query_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    query TEXT NOT NULL,
    retrieved_chunks JSONB,
    ai_response TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
