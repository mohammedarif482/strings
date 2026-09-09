import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pytest
from datetime import datetime
from fastapi.testclient import TestClient
from src.services.simulator import simulator, BiometricTelemetry
from src.main import app

def test_biometric_telemetry_schema():
    telem = BiometricTelemetry(
        user_id="USR-ALPHA",
        timestamp=datetime.now(),
        hrv_ms=42,
        heart_rate_bpm=82,
        cycle_phase="Luteal Day 24",
        cortisol_state="High",
        couple_stress_index=0.81
    )
    assert telem.user_id == "USR-ALPHA"
    assert telem.hrv_ms == 42
    assert telem.cortisol_state == "High"
    assert telem.couple_stress_index == 0.81

def test_simulator_profiles_and_ticks():
    ticks = simulator.generate_telemetry_tick()
    assert len(ticks) == 2
    
    alpha = next(t for t in ticks if t.user_id == "USR-ALPHA")
    beta = next(t for t in ticks if t.user_id == "USR-BETA")

    # Alpha: High Stress / Luteal Day 24
    assert 30 <= alpha.hrv_ms <= 55
    assert 70 <= alpha.heart_rate_bpm <= 100
    assert "Luteal" in alpha.cycle_phase
    assert 0.65 <= alpha.couple_stress_index <= 1.0

    # Beta: Restorative / Follicular Day 9
    assert 60 <= beta.hrv_ms <= 90
    assert 55 <= beta.heart_rate_bpm <= 72
    assert "Follicular" in beta.cycle_phase
    assert 0.15 <= beta.couple_stress_index <= 0.40

    # Couple Stress Index
    csi_couple = simulator.compute_couple_stress_index(alpha, beta)
    assert 0.0 <= csi_couple <= 1.0

def test_historical_seed():
    seed = simulator.generate_historical_seed(days=14)
    assert seed["status"] == "success"
    assert seed["days_seeded"] == 14
    assert seed["total_telemetry_points"] == 28
    assert seed["total_checkin_records"] == 28
    assert len(seed["records"]["telemetry"]) == 28
    assert len(seed["records"]["checkins"]) == 28

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
    assert "USR-ALPHA" in analytics["active_profiles"]
    assert analytics["cloud_simulator_health"]["status"] == "healthy"
    assert analytics["cloud_simulator_health"]["loop_interval_seconds"] == 10

    res_preds = client.get("/api/v1/admin/logs/predictions")
    assert res_preds.status_code == 200
    preds = res_preds.json()["data"]
    assert any(p["user_anonymized_id"] == "USR-ALPHA" for p in preds)
    assert any(p["user_anonymized_id"] == "USR-BETA" for p in preds)

if __name__ == "__main__":
    test_biometric_telemetry_schema()
    test_simulator_profiles_and_ticks()
    test_historical_seed()
    test_fastapi_seed_endpoint()
    test_fastapi_admin_analytics_and_predictions()
    print("ALL TESTS PASSED SUCCESSFULLY!")
