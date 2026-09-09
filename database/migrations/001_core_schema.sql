-- Migration 001: Core Schema for Aivo Platform
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    partner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    cycle_start_date DATE,
    average_cycle_length INT DEFAULT 28,
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. DAILY CHECKINS TABLE
CREATE TABLE IF NOT EXISTS daily_checkins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    mood_score INT CHECK (mood_score BETWEEN 1 AND 10),
    stress_score INT CHECK (stress_score BETWEEN 1 AND 10),
    energy_level INT CHECK (energy_level BETWEEN 1 AND 10),
    sleep_hours DECIMAL(4,2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);
CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON daily_checkins(user_id, date DESC);

-- 3. WEARABLE PULLS (Time-Series)
CREATE TABLE IF NOT EXISTS wearable_pulls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hrv_ms INT NOT NULL,
    resting_hr INT NOT NULL,
    deep_sleep_minutes INT NOT NULL,
    is_simulated BOOLEAN DEFAULT false,
    simulation_run_id VARCHAR(100)
);
CREATE INDEX IF NOT EXISTS idx_wearable_user_time ON wearable_pulls(user_id, timestamp DESC);

-- 4. PREDICTIONS TABLE
CREATE TABLE IF NOT EXISTS predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_date DATE NOT NULL,
    predicted_state VARCHAR(100) NOT NULL,
    combined_stress_index DECIMAL(4,3) NOT NULL,
    confidence_score DECIMAL(4,3) NOT NULL,
    primary_driver TEXT NOT NULL,
    content_tag VARCHAR(100),
    actual_state VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_date)
);
CREATE INDEX IF NOT EXISTS idx_predictions_user_target ON predictions(user_id, target_date DESC);

-- 5. NUDGES TABLE
CREATE TABLE IF NOT EXISTS nudges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    prediction_id UUID REFERENCES predictions(id) ON DELETE SET NULL,
    message TEXT NOT NULL,
    was_helpful BOOLEAN,
    support_reaction VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_nudges_recipient ON nudges(recipient_id, created_at DESC);
