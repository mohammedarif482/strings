import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pytest
from datetime import datetime
from fastapi.testclient import TestClient
from src.services.simulator import simulator, BiometricTelemetry
from src.main import app

def test_biometric_telemetry_schema():
    telem_arya = BiometricTelemetry(
        user_id="arya_female",
        display_name="Arya",
        gender="female",
        timestamp=datetime.now(),
        hrv_ms=42,
        heart_rate_bpm=82,
        cycle_phase="Luteal Day 24",
        cortisol_state="High",
        couple_stress_index=0.81
    )
    assert telem_arya.user_id == "arya_female"
    assert telem_arya.display_name == "Arya"
    assert telem_arya.gender == "female"
    assert telem_arya.hrv_ms == 42
    assert telem_arya.cortisol_state == "High"
    assert telem_arya.cycle_phase == "Luteal Day 24"
    assert telem_arya.couple_stress_index == 0.81

    # Male profile: cycle_phase must be None
    telem_arif = BiometricTelemetry(
        user_id="arif_male",
        display_name="Arif",
        gender="male",
        timestamp=datetime.now(),
        hrv_ms=75,
        heart_rate_bpm=62,
        cycle_phase=None,
        cortisol_state="Normal",
        couple_stress_index=0.22
    )
    assert telem_arif.user_id == "arif_male"
    assert telem_arif.display_name == "Arif"
    assert telem_arif.gender == "male"
    assert telem_arif.cycle_phase is None
    assert telem_arif.cortisol_state == "Normal"

def test_simulator_profiles_and_ticks():
    ticks = simulator.generate_telemetry_tick()
    assert len(ticks) == 2
    
    arya = next(t for t in ticks if t.user_id == "arya_female")
    arif = next(t for t in ticks if t.user_id == "arif_male")

    # Arya: High Stress / Luteal Day 24 (female)
    assert 35 <= arya.hrv_ms <= 50
    assert 75 <= arya.heart_rate_bpm <= 95
    assert arya.cycle_phase == "Luteal Day 24"
    assert arya.cortisol_state == "High"
    assert 0.65 <= arya.couple_stress_index <= 1.0

    # Arif: Restorative Circadian Baseline (male) - NO menstrual phase
    assert 65 <= arif.hrv_ms <= 85
    assert 58 <= arif.heart_rate_bpm <= 68
    assert arif.cycle_phase is None
    assert arif.cortisol_state == "Normal"
    assert 0.15 <= arif.couple_stress_index <= 0.40

    # Dyadic Couple Stress Index (0.60 * Arya + 0.40 * Arif)
    csi_couple = simulator.compute_couple_stress_index(arya, arif)
    expected_csi = round((0.60 * arya.couple_stress_index) + (0.40 * arif.couple_stress_index), 3)
    assert csi_couple == expected_csi
    assert 0.0 <= csi_couple <= 1.0

def test_historical_seed():
    seed = simulator.generate_historical_seed(days=14)
    assert seed["status"] == "success"
    assert seed["days_seeded"] == 14
    assert seed["total_telemetry_points"] == 28
    assert seed["total_checkin_records"] == 28
    assert len(seed["records"]["telemetry"]) == 28
    assert len(seed["records"]["checkins"]) == 28

    # Verify seed data contains Arya and Arif
    user_ids = {t["user_id"] for t in seed["records"]["telemetry"]}
    assert "arya_female" in user_ids
    assert "arif_male" in user_ids

def test_fastapi_seed_endpoint():
    client = TestClient(app)
    response = client.post("/api/v1/admin/seed-simulation?days=14")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["days_seeded"] == 14
    assert data["total_telemetry_points"] == 28

def test_fastapi_admin_analytics_and_predictions():
    client = TestClient(app)
    
    res_analytics = client.get("/api/v1/admin/analytics")
    assert res_analytics.status_code == 200
    analytics = res_analytics.json()
    assert "arya_female" in analytics["active_profiles"]
    assert "arif_male" in analytics["active_profiles"]
    assert analytics["active_users"] == 2
    assert analytics["paired_couples"] == 1
    assert analytics["cloud_simulator_health"]["status"] == "healthy"
    assert analytics["cloud_simulator_health"]["loop_interval_seconds"] == 10

    res_preds = client.get("/api/v1/admin/logs/predictions")
    assert res_preds.status_code == 200
    preds = res_preds.json()["data"]
    assert any(p["user_anonymized_id"] in ("arya_female", "Arya") for p in preds)
    assert any(p["user_anonymized_id"] in ("arif_male", "Arif") for p in preds)

if __name__ == "__main__":
    test_biometric_telemetry_schema()
    test_simulator_profiles_and_ticks()
    test_historical_seed()
    test_fastapi_seed_endpoint()
    test_fastapi_admin_analytics_and_predictions()
    print("ALL TESTS PASSED SUCCESSFULLY!")
