import '../models/prediction_models.dart';
import '../models/content_entry.dart';
import '../data/content_seed_data.dart';

class ContentMatcher {
  /// Pure deterministic matcher function.
  /// Maps a PredictionResult to a research-backed ContentEntry micro-protocol.
  static ContentEntry getProtocolForState(PredictionResult prediction) {
    final String targetTag = _resolveStateTag(prediction);

    // 1. Exact tag match
    for (final entry in contentSeedLibrary) {
      if (entry.stateTag == targetTag) {
        return entry;
      }
    }

    // 2. Phase-based fallback match
    final phaseStr = prediction.cyclePhase.name.toLowerCase();
    for (final entry in contentSeedLibrary) {
      if (entry.phaseApplicability.contains(phaseStr)) {
        return entry;
      }
    }

    // 3. Ultimate deterministic fallback
    return contentSeedLibrary.firstWhere(
      (entry) => entry.stateTag == 'default_generic_recovery',
      orElse: () => contentSeedLibrary.first,
    );
  }

  static String _resolveStateTag(PredictionResult p) {
    // A. Luteal Phase (Days 15-28)
    if (p.cyclePhase == CyclePhase.luteal) {
      if (p.cycleDay >= 21) {
        if (p.rollingSleepAvg < 7.0 && p.combinedStressIndex > 0.60) {
          return 'late_luteal_sleep_deficit';
        }
        if (p.combinedStressIndex > 0.65) {
          return 'luteal_high_cortisol';
        }
        if (p.rollingMoodAvg < 5.0) {
          return 'luteal_emotional_vulnerability';
        }
      } else {
        // Early Luteal (Days 15-20)
        if (p.combinedStressIndex > 0.50) {
          return 'early_luteal_stress_buffer';
        }
        return 'early_luteal_metabolic_shift';
      }
    }

    // B. Menstrual Phase (Days 1-5)
    if (p.cyclePhase == CyclePhase.menstrual) {
      if (p.combinedStressIndex > 0.55) {
        return 'menstrual_cramp_tension';
      }
      if (p.rollingMoodAvg < 6.0) {
        return 'menstrual_low_energy_recovery';
      }
      return 'menstrual_reflective_calm';
    }

    // C. Ovulatory Phase (Day 14)
    if (p.cyclePhase == CyclePhase.ovulatory) {
      if (p.rollingMoodAvg >= 8.0) {
        return 'ovulatory_peak_social_energy';
      }
      return 'ovulatory_high_stamina';
    }

    // D. Follicular Phase (Days 6-13)
    if (p.cyclePhase == CyclePhase.follicular) {
      if (p.rollingStressAvg <= 3.0 && p.rollingMoodAvg >= 8.0) {
        return 'follicular_rising_momentum';
      }
      if (p.combinedStressIndex <= 0.35) {
        return 'follicular_balanced_vitality';
      }
      return 'follicular_high_focus';
    }

    // E. Global Biometric Overrides
    if (p.rollingSleepAvg < 6.5) {
      return 'chronic_sleep_debt_restoration';
    }
    if (p.combinedStressIndex > 0.65) {
      return 'high_stress_general';
    }

    return 'default_generic_recovery';
  }

  /// Formats partner nudge template with dynamic name substitution
  static String formatPartnerNudge(String template, String partnerName) {
    return template.replaceAll('{name}', partnerName);
  }
}
