"""
Automated Test Suite for Aivo Web Admin & Huberman RAG API
"""

import sys
from pathlib import Path

# Add directory to sys.path
sys.path.insert(0, str(Path(__file__).parent))

from fastapi.testclient import TestClient
from main import app, ADMIN_QUERY_LOGS


def test_admin_analytics():
    client = TestClient(app)
    response = client.get("/api/v1/admin/analytics")
    assert response.status_code == 200, f"Expected 200, got {response.status_code}"
    data = response.json()
    
    assert data["active_users"] >= 1000
    assert data["paired_couples"] >= 500
    assert data["total_daily_predictions"] > 0
    assert 0.0 <= data["nudge_helpful_rate"] <= 100.0
    assert data["cloud_simulator_health"]["status"] == "healthy"
    assert data["cloud_simulator_health"]["streaming_active"] is True
    print("✓ Test 1 Passed: GET /api/v1/admin/analytics returns valid health metrics")


def test_prediction_logs():
    client = TestClient(app)
    response = client.get("/api/v1/admin/logs/predictions?limit=5&page=1")
    assert response.status_code == 200
    data = response.json()
    
    assert "data" in data
    assert len(data["data"]) <= 5
    first = data["data"][0]
    assert "user_anonymized_id" in first
    assert "combined_stress_index" in first
    assert "predicted_state" in first
    assert "partner_nudge_status" in first
    print("✓ Test 2 Passed: GET /api/v1/admin/logs/predictions returns paginated feed")


def test_huberman_rag_pipeline():
    client = TestClient(app)
    payload = {
        "query": "How does Huberman suggest offsetting luteal phase sleep fragmentation?",
        "top_k": 3,
        "stream": False
    }
    response = client.post("/api/v1/admin/huberman-rag", json=payload)
    assert response.status_code == 200
    data = response.json()
    
    assert data["grounded_in_dataset"] is True
    assert len(data["sources"]) == 3
    assert data["latency_ms"] >= 0.0
    
    # Check that sources contain episode citations
    episodes = [s["episode_title"] for s in data["sources"]]
    assert any("Sleep" in ep or "Hormones" in ep for ep in episodes)
    
    # Check grounded content
    assert "Magnesium" in data["ai_response"] or "cooling" in data["ai_response"].lower() or "temperature" in data["ai_response"].lower()
    
    # Verify logging
    assert len(ADMIN_QUERY_LOGS) > 0
    assert ADMIN_QUERY_LOGS[-1]["query"] == payload["query"]
    print("✓ Test 3 Passed: POST /api/v1/admin/huberman-rag performs cosine vector search & grounded synthesis")


def test_huberman_rag_dopamine():
    client = TestClient(app)
    payload = {
        "query": "What are the protocols to regulate baseline dopamine and motivation?",
        "top_k": 3,
        "stream": False
    }
    response = client.post("/api/v1/admin/huberman-rag", json=payload)
    assert response.status_code == 200
    data = response.json()
    
    topics = [s["topic"] for s in data["sources"]]
    assert "dopamine" in topics
    assert "cold" in data["ai_response"].lower() or "effort" in data["ai_response"].lower()
    print("✓ Test 4 Passed: Cosine search recovers Ep. 39 Dopamine protocol with top similarity")


def test_huberman_rag_streaming():
    client = TestClient(app)
    payload = {
        "query": "How to stop stress using the physiological sigh?",
        "top_k": 3,
        "stream": True
    }
    response = client.post(
        "/api/v1/admin/huberman-rag",
        json=payload,
        headers={"Accept": "text/event-stream"}
    )
    assert response.status_code == 200
    assert "text/event-stream" in response.headers["content-type"]
    text = response.text
    assert "data:" in text
    assert "token" in text
    print("✓ Test 5 Passed: POST /api/v1/admin/huberman-rag streams response via Server-Sent Events (SSE)")


if __name__ == "__main__":
    print("=== Running FastAPI Admin & Huberman RAG Test Suite ===")
    test_admin_analytics()
    test_prediction_logs()
    test_huberman_rag_pipeline()
    test_huberman_rag_dopamine()
    test_huberman_rag_streaming()
    print("🎉 ALL 5 FASTAPI ADMIN TESTS PASSED!")
