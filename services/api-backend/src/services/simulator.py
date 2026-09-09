"""
Aivo Lean User Biometrics Simulation Engine
Generates live streaming telemetry and historical seeds for test profiles:
- Profile A: Arif (female) -> High Stress / Infradian Luteal Phase (Day 24)
- Profile B: Arya (male) -> Restorative / Diurnal Circadian Recovery (No menstrual cycle phase)
"""

import math
import random
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field


class BiometricTelemetry(BaseModel):
    user_id: str
    display_name: Optional[str] = None
    gender: Optional[str] = None
    timestamp: datetime
    hrv_ms: int
    heart_rate_bpm: int
    cycle_phase: Optional[str] = None
    cortisol_state: str
    couple_stress_index: float

    def to_dict(self) -> Dict[str, Any]:
        return {
            "user_id": self.user_id,
            "display_name": self.display_name,
            "gender": self.gender,
            "timestamp": self.timestamp.isoformat() if hasattr(self.timestamp, "isoformat") else str(self.timestamp),
            "hrv_ms": self.hrv_ms,
            "heart_rate_bpm": self.heart_rate_bpm,
            "cycle_phase": self.cycle_phase,
            "cortisol_state": self.cortisol_state,
            "couple_stress_index": self.couple_stress_index,
        }


class UserSimulationProfile:
    def __init__(
        self,
        user_id: str,
        display_name: str,
        gender: str,
        partner_id: str,
        display_label: str,
        cycle_day: Optional[int],
        cycle_phase: Optional[str],
        hrv_min: int,
        hrv_max: int,
        hr_min: int,
        hr_max: int,
        cortisol_state: str,
        csi_base: float,
    ):
        self.user_id = user_id
        self.display_name = display_name
        self.gender = gender
        self.partner_id = partner_id
        self.display_label = display_label
        self.cycle_day = cycle_day
        self.cycle_phase = cycle_phase
        self.hrv_min = hrv_min
        self.hrv_max = hrv_max
        self.hrv_mean = (hrv_min + hrv_max) / 2.0
        self.hrv_std = (hrv_max - hrv_min) / 4.0
        self.hr_min = hr_min
        self.hr_max = hr_max
        self.hr_mean = (hr_min + hr_max) / 2.0
        self.hr_std = (hr_max - hr_min) / 4.0
        self.cortisol_state = cortisol_state
        self.csi_base = csi_base

    def sample_telemetry(self, timestamp: Optional[datetime] = None) -> BiometricTelemetry:
        ts = timestamp or datetime.now(timezone.utc)
        
        # Sample HRV using normal distribution clamped to baseline bounds
        raw_hrv = random.gauss(self.hrv_mean, self.hrv_std)
        hrv = int(round(max(self.hrv_min, min(self.hrv_max, raw_hrv))))
        
        # Sample HR using normal distribution clamped to baseline bounds
        raw_hr = random.gauss(self.hr_mean, self.hr_std)
        hr = int(round(max(self.hr_min, min(self.hr_max, raw_hr))))
        
        # Sample CSI with physiological micro-fluctuation
        csi_jitter = random.gauss(0.0, 0.02)
        csi = round(max(0.05, min(0.98, self.csi_base + csi_jitter)), 3)
        
        cortisol = self.cortisol_state

        # Male profiles do not have menstrual cycle phase logic (cycle_phase is None)
        phase_label = f"{self.cycle_phase} Day {self.cycle_day}" if self.cycle_phase and self.cycle_day else self.cycle_phase

        return BiometricTelemetry(
            user_id=self.user_id,
            display_name=self.display_name,
            gender=self.gender,
            timestamp=ts,
            hrv_ms=hrv,
            heart_rate_bpm=hr,
            cycle_phase=phase_label,
            cortisol_state=cortisol,
            couple_stress_index=csi,
        )


class BiometricsSimulator:
    def __init__(self):
        # Profile A: Arya (female) -> High Stress / Luteal Phase Day 24
        self.profile_arya = UserSimulationProfile(
            user_id="arya_female",
            display_name="Arya",
            gender="female",
            partner_id="arif_male",
            display_label="High Stress / Infradian Luteal Phase",
            cycle_day=24,
            cycle_phase="Luteal",
            hrv_min=35,
            hrv_max=50,
            hr_min=75,
            hr_max=95,
            cortisol_state="High",
            csi_base=0.82,
        )

        # Profile B: Arif (male) -> Restorative / Diurnal Circadian Baseline (No menstrual cycle phase)
        self.profile_arif = UserSimulationProfile(
            user_id="arif_male",
            display_name="Arif",
            gender="male",
            partner_id="arya_female",
            display_label="Restorative / Diurnal Circadian Baseline",
            cycle_day=None,
            cycle_phase=None,
            hrv_min=65,
            hrv_max=85,
            hr_min=58,
            hr_max=68,
            cortisol_state="Normal",
            csi_base=0.24,
        )

        self.profiles = [self.profile_arya, self.profile_arif]

    def generate_telemetry_tick(self, timestamp: Optional[datetime] = None) -> List[BiometricTelemetry]:
        """Generates a synchronous telemetry tick for both active profiles."""
        ts = timestamp or datetime.now(timezone.utc)
        return [p.sample_telemetry(ts) for p in self.profiles]

    def compute_couple_stress_index(self, telem_a: BiometricTelemetry, telem_b: BiometricTelemetry) -> float:
        """
        Dyadic Couple Stress Index (CSI %):
        CSI_couple = round((0.60 * CSI_arya) + (0.40 * CSI_arif), 3)
        """
        # Ensure correct mapping regardless of argument ordering
        csi_arya = telem_a.couple_stress_index if telem_a.user_id in ("arya_female", "arya", "Arya") else telem_b.couple_stress_index
        csi_arif = telem_b.couple_stress_index if telem_b.user_id in ("arif_male", "arif", "Arif") else telem_a.couple_stress_index
        
        combined = (0.60 * csi_arya) + (0.40 * csi_arif)
        return round(min(1.0, max(0.0, combined)), 3)

    def generate_historical_seed(self, days: int = 14) -> Dict[str, Any]:
        """
        Generates 14 days of backdated historical HRV/biometric data specifically for
        Arya (female) and Arif (male) to support predictive wellness trend graphs.
        """
        now = datetime.now(timezone.utc)
        telemetry_records: List[Dict[str, Any]] = []
        checkin_records: List[Dict[str, Any]] = []

        for d in range(days, 0, -1):
            day_ts = now - timedelta(days=d)
            date_str = day_ts.strftime("%Y-%m-%d")

            # --- Backdate Arya (female) ---
            # Progressive infradian cycle progression ending at Day 24 (late luteal)
            # Days d=14 to d=1: cycle_day progresses from 11 (follicular/ovulatory) to 24 (late luteal)
            arya_cycle_day = max(1, 24 - d + 1)
            arya_is_luteal = arya_cycle_day >= 15
            
            # HRV declines toward luteal baseline (58ms -> 42ms)
            arya_hrv_mean = 58 - ((arya_cycle_day - 10) * 1.2) if arya_is_luteal else 60
            arya_hrv = int(round(random.gauss(arya_hrv_mean, 3.5)))
            
            # HR elevates in luteal phase (72bpm -> 86bpm)
            arya_hr_mean = 74 + ((arya_cycle_day - 10) * 0.9) if arya_is_luteal else 72
            arya_hr = int(round(random.gauss(arya_hr_mean, 3.0)))
            
            # CSI increases as progesterone drops in late luteal
            arya_csi = round(min(0.95, max(0.35, 0.45 + ((arya_cycle_day - 10) * 0.028) + random.gauss(0, 0.02))), 3)
            arya_cortisol = "High" if arya_csi >= 0.70 else "Moderate"
            arya_phase_label = f"Luteal Day {arya_cycle_day}" if arya_is_luteal else f"Follicular Day {arya_cycle_day}"

            arya_telem = BiometricTelemetry(
                user_id="arya_female",
                display_name="Arya",
                gender="female",
                timestamp=day_ts,
                hrv_ms=max(32, min(68, arya_hrv)),
                heart_rate_bpm=max(68, min(98, arya_hr)),
                cycle_phase=arya_phase_label,
                cortisol_state=arya_cortisol,
                couple_stress_index=arya_csi,
            )
            telemetry_records.append(arya_telem.to_dict())

            checkin_records.append({
                "id": f"chk_arya_{date_str}",
                "user_id": "arya_female",
                "date": date_str,
                "mood_score": 4 if arya_is_luteal else 7,
                "stress_score": 8 if arya_is_luteal else 4,
                "energy_level": 4 if arya_is_luteal else 8,
                "sleep_hours": round(max(4.5, min(8.5, 5.4 + random.gauss(0, 0.4))), 1),
                "notes": f"Historical seed: {arya_phase_label}",
                "created_at": day_ts.isoformat()
            })

            # --- Backdate Arif (male) ---
            # Diurnal circadian baseline: stable restorative metrics, no menstrual cycle days
            arif_hrv = int(round(random.gauss(75.0, 4.0)))
            arif_hr = int(round(random.gauss(63.0, 2.5)))
            arif_csi = round(min(0.38, max(0.16, 0.24 + random.gauss(0, 0.02))), 3)

            arif_telem = BiometricTelemetry(
                user_id="arif_male",
                display_name="Arif",
                gender="male",
                timestamp=day_ts,
                hrv_ms=max(60, min(90, arif_hrv)),
                heart_rate_bpm=max(55, min(72, arif_hr)),
                cycle_phase=None,  # No menstrual cycle phase logic for male profiles
                cortisol_state="Normal",
                couple_stress_index=arif_csi,
            )
            telemetry_records.append(arif_telem.to_dict())

            checkin_records.append({
                "id": f"chk_arif_{date_str}",
                "user_id": "arif_male",
                "date": date_str,
                "mood_score": 8,
                "stress_score": 3,
                "energy_level": 8,
                "sleep_hours": round(max(7.0, min(9.2, 7.8 + random.gauss(0, 0.3))), 1),
                "notes": "Historical seed: Circadian restorative baseline",
                "created_at": day_ts.isoformat()
            })

        return {
            "status": "success",
            "message": f"Successfully generated {days} days of historical biometric seeds for Arya (female) and Arif (male).",
            "days_seeded": days,
            "profiles": ["arya_female", "arif_male"],
            "display_names": ["Arya", "Arif"],
            "total_telemetry_points": len(telemetry_records),
            "total_checkin_records": len(checkin_records),
            "telemetry_sample": telemetry_records[:4],
            "checkin_sample": checkin_records[:4],
            "records": {
                "telemetry": telemetry_records,
                "checkins": checkin_records
            }
        }


# Global singleton instance
simulator = BiometricsSimulator()
