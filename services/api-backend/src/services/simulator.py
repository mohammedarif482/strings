"""
Aivo Lean User Biometrics Simulation Engine
Generates live streaming telemetry and historical seeds for test profiles:
- Profile A (USR-ALPHA): High Stress / Luteal Phase (Day 24)
- Profile B (USR-BETA): Restorative / Follicular Phase (Day 9)
"""

import math
import random
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field


class BiometricTelemetry(BaseModel):
    user_id: str
    timestamp: datetime
    hrv_ms: int
    heart_rate_bpm: int
    cycle_phase: str
    cortisol_state: str
    couple_stress_index: float

    def to_dict(self) -> Dict[str, Any]:
        return {
            "user_id": self.user_id,
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
        partner_id: str,
        display_label: str,
        cycle_day: int,
        cycle_phase: str,
        hrv_min: int,
        hrv_max: int,
        hr_min: int,
        hr_max: int,
        cortisol_state: str,
        csi_base: float,
    ):
        self.user_id = user_id
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
        
        # Sample HRV using normal distribution around baseline
        raw_hrv = random.gauss(self.hrv_mean, self.hrv_std)
        hrv = int(round(max(self.hrv_min - 2, min(self.hrv_max + 2, raw_hrv))))
        
        # Sample HR using normal distribution around baseline
        raw_hr = random.gauss(self.hr_mean, self.hr_std)
        hr = int(round(max(self.hr_min - 2, min(self.hr_max + 2, raw_hr))))
        
        # Sample CSI with physiological micro-fluctuation
        csi_jitter = random.gauss(0.0, 0.025)
        csi = round(max(0.05, min(0.98, self.csi_base + csi_jitter)), 3)
        
        # Dynamic cortisol state based on threshold / profile
        cortisol = self.cortisol_state
        if self.user_id == "USR-ALPHA" and hrv > 48 and csi < 0.72:
            cortisol = "Moderate"
        elif self.user_id == "USR-BETA" and hrv < 66 and csi > 0.35:
            cortisol = "Elevated"

        return BiometricTelemetry(
            user_id=self.user_id,
            timestamp=ts,
            hrv_ms=hrv,
            heart_rate_bpm=hr,
            cycle_phase=f"{self.cycle_phase.capitalize()} Day {self.cycle_day}",
            cortisol_state=cortisol,
            couple_stress_index=csi,
        )


class BiometricsSimulator:
    def __init__(self):
        # Profile A: High Stress / Luteal Phase Day 24
        self.profile_alpha = UserSimulationProfile(
            user_id="USR-ALPHA",
            partner_id="USR-BETA",
            display_label="High Stress / Luteal Phase",
            cycle_day=24,
            cycle_phase="luteal",
            hrv_min=35,
            hrv_max=50,
            hr_min=75,
            hr_max=95,
            cortisol_state="High",
            csi_base=0.82,
        )

        # Profile B: Restorative / Follicular Phase Day 9
        self.profile_beta = UserSimulationProfile(
            user_id="USR-BETA",
            partner_id="USR-ALPHA",
            display_label="Restorative / Follicular Phase",
            cycle_day=9,
            cycle_phase="follicular",
            hrv_min=65,
            hrv_max=85,
            hr_min=58,
            hr_max=68,
            cortisol_state="Normal",
            csi_base=0.24,
        )

        self.profiles = [self.profile_alpha, self.profile_beta]

    def generate_telemetry_tick(self, timestamp: Optional[datetime] = None) -> List[BiometricTelemetry]:
        """Generates a synchronous telemetry tick for both active profiles."""
        ts = timestamp or datetime.now(timezone.utc)
        return [p.sample_telemetry(ts) for p in self.profiles]

    def compute_couple_stress_index(self, alpha_telem: BiometricTelemetry, beta_telem: BiometricTelemetry) -> float:
        """Weighted dyadic stress index (60% luteal sensitivity + 40% partner baseline)."""
        combined = (alpha_telem.couple_stress_index * 0.60) + (beta_telem.couple_stress_index * 0.40)
        return round(min(1.0, max(0.0, combined)), 3)

    def generate_historical_seed(self, days: int = 14) -> Dict[str, Any]:
        """
        Generates 14 days of backdated historical HRV/biometric data for both test users
        to support predictive wellness trend graphs and historical analytics.
        """
        now = datetime.now(timezone.utc)
        telemetry_records: List[Dict[str, Any]] = []
        checkin_records: List[Dict[str, Any]] = []

        for d in range(days, 0, -1):
            day_ts = now - timedelta(days=d)
            date_str = day_ts.strftime("%Y-%m-%d")

            # --- Backdate USR-ALPHA ---
            # Progression from Day 10 (ovulatory) to Day 24 (late luteal)
            alpha_cycle_day = max(1, (24 - d) % 28 + 1)
            alpha_is_luteal = alpha_cycle_day > 14
            alpha_hrv = int(round(random.gauss(42 if alpha_is_luteal else 58, 4.0)))
            alpha_hr = int(round(random.gauss(84 if alpha_is_luteal else 72, 3.5)))
            alpha_csi = round(min(0.95, max(0.35, 0.82 - (d * 0.03) + random.gauss(0, 0.02))), 3)
            alpha_cortisol = "High" if alpha_csi > 0.70 else "Moderate"
            alpha_phase = "luteal" if alpha_is_luteal else "follicular"

            alpha_telem = BiometricTelemetry(
                user_id="USR-ALPHA",
                timestamp=day_ts,
                hrv_ms=max(30, min(70, alpha_hrv)),
                heart_rate_bpm=max(65, min(100, alpha_hr)),
                cycle_phase=f"{alpha_phase.capitalize()} Day {alpha_cycle_day}",
                cortisol_state=alpha_cortisol,
                couple_stress_index=alpha_csi,
            )
            telemetry_records.append(alpha_telem.to_dict())

            checkin_records.append({
                "id": f"chk_alpha_{date_str}",
                "user_id": "USR-ALPHA",
                "date": date_str,
                "mood_score": 4 if alpha_is_luteal else 7,
                "stress_score": 8 if alpha_is_luteal else 4,
                "energy_level": 4 if alpha_is_luteal else 8,
                "sleep_hours": round(max(4.5, min(9.0, 5.5 + random.gauss(0, 0.4))), 1),
                "notes": f"Historical seed: {alpha_phase} Day {alpha_cycle_day}",
                "created_at": day_ts.isoformat()
            })

            # --- Backdate USR-BETA ---
            # Progression to Follicular Day 9
            beta_cycle_day = max(1, (9 - d) % 28 + 1)
            beta_hrv = int(round(random.gauss(75, 4.0)))
            beta_hr = int(round(random.gauss(63, 2.5)))
            beta_csi = round(min(0.40, max(0.15, 0.24 + random.gauss(0, 0.02))), 3)
            beta_phase = "follicular" if beta_cycle_day <= 13 else "luteal"

            beta_telem = BiometricTelemetry(
                user_id="USR-BETA",
                timestamp=day_ts,
                hrv_ms=max(55, min(90, beta_hrv)),
                heart_rate_bpm=max(55, min(75, beta_hr)),
                cycle_phase=f"{beta_phase.capitalize()} Day {beta_cycle_day}",
                cortisol_state="Normal",
                couple_stress_index=beta_csi,
            )
            telemetry_records.append(beta_telem.to_dict())

            checkin_records.append({
                "id": f"chk_beta_{date_str}",
                "user_id": "USR-BETA",
                "date": date_str,
                "mood_score": 8,
                "stress_score": 2,
                "energy_level": 8,
                "sleep_hours": round(max(7.0, min(9.5, 7.8 + random.gauss(0, 0.3))), 1),
                "notes": f"Historical seed: {beta_phase} Day {beta_cycle_day}",
                "created_at": day_ts.isoformat()
            })

        return {
            "status": "success",
            "message": f"Successfully generated {days} days of historical biometric seeds for USR-ALPHA and USR-BETA.",
            "days_seeded": days,
            "profiles": ["USR-ALPHA", "USR-BETA"],
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
