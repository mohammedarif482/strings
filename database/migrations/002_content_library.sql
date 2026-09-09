-- Migration 002: Content Library & Research-Backed Seed Protocols
CREATE TABLE IF NOT EXISTS content_library (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    state_tag VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    summary TEXT NOT NULL,
    source_reference TEXT,
    action_tip TEXT NOT NULL,
    partner_nudge_template TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Seed Initial Research Protocols
INSERT INTO content_library (state_tag, title, summary, source_reference, action_tip, partner_nudge_template)
VALUES 
(
    'luteal_high_cortisol', 
    'Reset Your Mind', 
    'Elevated cortisol combined with sleep deficit frequently mimics situational stress.', 
    'Circadian rhythm & cortisol curve research', 
    '10-minute outdoor morning walk before 9 AM and 2-3 physiological sighs.', 
    'may be in a high-cortisol state tomorrow. Clear evening tasks and lower friction.'
),
(
    'follicular_peak', 
    'Peak Focus Window', 
    'Estrogen rise supports cognitive resilience and social capacity.', 
    'Neuro-hormonal phase studies', 
    'Tackle high-complexity creative projects and social conversations today.', 
    'is in a peak resilience window. Great time for shared activities.'
),
(
    'sleep_deficit_recovery',
    'Deep Autonomic Recovery',
    'Accumulated sleep debt suppresses heart rate variability and elevates baseline reactivity.',
    'Sleep architecture & HRV research',
    'Keep bedroom ambient temperature at 64-66°F and delay caffeine intake 90 min after waking.',
    'is navigating sleep debt. Offer evening quiet time to support recovery.'
),
(
    'circadian_alignment',
    'Circadian Clock Anchor',
    'Morning sunlight sets the master pacemaker in the suprachiasmatic nucleus.',
    'Photobiology & sleep regulation',
    'View 10-30 minutes of bright outdoor light within an hour of waking.',
    'is optimizing their sleep-wake rhythm today.'
),
(
    'stress_mitigation',
    'Autonomic Down-Regulation',
    'Sympathetic dominance can be rapidly reset via vagal stimulation.',
    'Stanford Autonomic Neurobiology Laboratory',
    'Practice 5 minutes of cyclic sighing to elevate heart rate variability.',
    'is experiencing sympathetic tension. A gentle presence will help co-regulate.'
)
ON CONFLICT (state_tag) DO NOTHING;
