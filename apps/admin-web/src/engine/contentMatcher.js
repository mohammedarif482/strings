import { contentSeedLibrary } from './contentSeedData.js';

export function getProtocolForState(prediction) {
  const targetTag = resolveStateTag(prediction);

  // 1. Exact tag match
  const exact = contentSeedLibrary.find((e) => e.stateTag === targetTag);
  if (exact) return exact;

  // 2. Phase-based fallback
  const phaseStr = (prediction.cyclePhase || '').toLowerCase();
  const phaseMatch = contentSeedLibrary.find((e) => e.phaseApplicability.includes(phaseStr));
  if (phaseMatch) return phaseMatch;

  // 3. Deterministic generic fallback
  return contentSeedLibrary.find((e) => e.stateTag === 'default_generic_recovery') || contentSeedLibrary[0];
}

function resolveStateTag(p) {
  if (p.cyclePhase === 'luteal') {
    if (p.cycleDay >= 21) {
      if (p.rollingSleepAvg < 7.0 && p.combinedStressIndex > 0.60) return 'late_luteal_sleep_deficit';
      if (p.combinedStressIndex > 0.65) return 'luteal_high_cortisol';
      if (p.rollingMoodAvg < 5.0) return 'luteal_emotional_vulnerability';
    } else {
      if (p.combinedStressIndex > 0.50) return 'early_luteal_stress_buffer';
      return 'early_luteal_metabolic_shift';
    }
  }

  if (p.cyclePhase === 'menstrual') {
    if (p.combinedStressIndex > 0.55) return 'menstrual_cramp_tension';
    if (p.rollingMoodAvg < 6.0) return 'menstrual_low_energy_recovery';
    return 'menstrual_reflective_calm';
  }

  if (p.cyclePhase === 'ovulatory') {
    if (p.rollingMoodAvg >= 8.0) return 'ovulatory_peak_social_energy';
    return 'ovulatory_high_stamina';
  }

  if (p.cyclePhase === 'follicular') {
    if (p.rollingStressAvg <= 3.0 && p.rollingMoodAvg >= 8.0) return 'follicular_rising_momentum';
    if (p.combinedStressIndex <= 0.35) return 'follicular_balanced_vitality';
    return 'follicular_high_focus';
  }

  if (p.rollingSleepAvg < 6.5) return 'chronic_sleep_debt_restoration';
  if (p.combinedStressIndex > 0.65) return 'high_stress_general';

  return 'default_generic_recovery';
}

export function formatPartnerNudge(template, partnerName = 'Sarah') {
  return template.replace('{name}', partnerName);
}
