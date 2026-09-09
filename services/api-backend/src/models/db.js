import pg from 'pg';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://aivo_user:aivo_pass@localhost:5432/aivo_db',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Fallback in-memory state for offline local development
export const inMemoryDB = {
  users: [
    { id: 'usr_alex', email: 'alex@aivo.health', partner_id: 'usr_sarah', cycle_start_date: '2026-08-20', average_cycle_length: 28 },
    { id: 'usr_sarah', email: 'sarah@aivo.health', partner_id: 'usr_alex', cycle_start_date: '2026-08-15', average_cycle_length: 28 }
  ],
  checkins: [],
  wearables: [],
  predictions: [],
  nudges: []
};
