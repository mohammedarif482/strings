"""
================================================================================
Aivo Web Admin & Huberman RAG E2E Verification Suite
================================================================================
Lead QA & Full-Stack Testing Engineer Verification Script

Tests:
1. Vitals Analytics Check (GET /api/v1/admin/analytics)
2. Live Prediction Stream Feed (GET /api/v1/admin/logs/predictions)
3. Test Query 1 - Circadian Light Viewing Protocol
4. Test Query 2 - Luteal High Cortisol Mitigation
5. Server-Sent Events (SSE) Streaming Response Verification
"""

import sys
import json
import time
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from fastapi.testclient import TestClient
from main import app


def run_e2e_suite():
    print("=" * 70)
    print(" 🧪 RUNNING E2E TEST SUITE: WEB ADMIN & HUBERMAN RAG ENGINE")
    print("=" * 70)
    
    client = TestClient(app)
    passed_count = 0
    total_tests = 5

    # --------------------------------------------------------------------------
    # Test 1: Vitals Analytics Check
    # --------------------------------------------------------------------------
    print("\n[TEST 1] Testing Dashboard Vitals Endpoint: GET /api/v1/admin/analytics")
    t0 = time.time()
    res1 = client.get("/api/v1/admin/analytics")
    lat1 = (time.time() - t0) * 1000
    
    assert res1.status_code == 200, f"Expected 200, got {res1.status_code}"
    data1 = res1.json()
    assert data1["active_users"] >= 1000, "Active users must be >= 1000"
    assert data1["paired_couples"] >= 500, "Paired couples must be >= 500"
    assert 0.0 <= data1["nudge_helpful_rate"] <= 100.0, "Helpful rate must be percentage"
    assert data1["cloud_simulator_health"]["status"] == "healthy"
    
    print(f"  ✓ Status: 200 OK ({lat1:.1f}ms)")
    print(f"  ✓ Active Users: {data1['active_users']} | Paired Couples: {data1['paired_couples']}")
    print(f"  ✓ Helpful Rate: {data1['nudge_helpful_rate']}% | Simulator: {data1['cloud_simulator_health']['status']}")
    passed_count += 1

    # --------------------------------------------------------------------------
    # Test 2: Real-Time Prediction Stream
    # --------------------------------------------------------------------------
    print("\n[TEST 2] Testing Live Prediction Feed: GET /api/v1/admin/logs/predictions")
    t0 = time.time()
    res2 = client.get("/api/v1/admin/logs/predictions?limit=5&page=1")
    lat2 = (time.time() - t0) * 1000
    
    assert res2.status_code == 200
    data2 = res2.json()
    assert len(data2["data"]) > 0, "Feed must return prediction records"
    first = data2["data"][0]
    assert "user_anonymized_id" in first
    assert "combined_stress_index" in first
    assert "state_tag" in first
    assert "partner_nudge_status" in first

    print(f"  ✓ Status: 200 OK ({lat2:.1f}ms)")
    print(f"  ✓ Feed Item 1: {first['user_anonymized_id']} → {first['partner_anonymized_id']} | Phase: {first['cycle_phase']} (Day {first['cycle_day']})")
    print(f"  ✓ State: {first['state_tag']} | CSI: {first['combined_stress_index']} | Nudge: {first['partner_nudge_status']}")
    passed_count += 1

    # --------------------------------------------------------------------------
    # Test 3: Query 1 (Circadian Protocol)
    # --------------------------------------------------------------------------
    print("\n[TEST 3] Testing Query 1 (Circadian): 'What are the light viewing protocols for circadian alignment?'")
    payload1 = {
        "query": "What are the light viewing protocols for circadian alignment?",
        "top_k": 3,
        "stream": False
    }
    t0 = time.time()
    res3 = client.post("/api/v1/admin/huberman-rag", json=payload1)
    lat3 = (time.time() - t0) * 1000

    assert res3.status_code == 200
    data3 = res3.json()
    assert data3["grounded_in_dataset"] is True
    assert len(data3["sources"]) >= 1, "Must return matching source episodes"
    assert "sunlight" in data3["ai_response"].lower() or "light" in data3["ai_response"].lower()
    
    print(f"  ✓ Status: 200 OK ({lat3:.1f}ms, backend latency: {data3['latency_ms']}ms)")
    print(f"  ✓ AI Response Preview: {data3['ai_response'][:110]}...")
    print(f"  ✓ Top Matching Source: '{data3['sources'][0]['episode_title']}' ({data3['sources'][0]['similarity_score']*100:.1f}% similarity)")
    print(f"  ✓ Actionable Protocol: {data3['sources'][0]['actionable_protocol']}")
    passed_count += 1

    # --------------------------------------------------------------------------
    # Test 4: Query 2 (High Cortisol)
    # --------------------------------------------------------------------------
    print("\n[TEST 4] Testing Query 2 (High Cortisol): 'How do I mitigate high cortisol during the luteal phase?'")
    payload2 = {
        "query": "How do I mitigate high cortisol during the luteal phase?",
        "top_k": 3,
        "stream": False
    }
    t0 = time.time()
    res4 = client.post("/api/v1/admin/huberman-rag", json=payload2)
    lat4 = (time.time() - t0) * 1000

    assert res4.status_code == 200
    data4 = res4.json()
    assert data4["grounded_in_dataset"] is True
    assert len(data4["sources"]) >= 1
    
    # Check clinical citations in response
    resp_lower = data4["ai_response"].lower()
    assert "luteal" in resp_lower or "cortisol" in resp_lower or "magnesium" in resp_lower
    
    print(f"  ✓ Status: 200 OK ({lat4:.1f}ms, backend latency: {data4['latency_ms']}ms)")
    print(f"  ✓ AI Response Preview: {data4['ai_response'][:110]}...")
    print(f"  ✓ Retained Sources: {len(data4['sources'])} episodes cited")
    for s in data4["sources"][:2]:
        print(f"    - {s['episode_title']} (Topic: {s['topic']}, Match: {s['similarity_score']*100:.1f}%)")
    passed_count += 1

    # --------------------------------------------------------------------------
    # Test 5: Streaming SSE Response Check
    # --------------------------------------------------------------------------
    print("\n[TEST 5] Testing Streaming SSE Response: POST /api/v1/admin/huberman-rag")
    payload5 = {
        "query": "How does the physiological sigh reduce stress in real time?",
        "top_k": 3,
        "stream": True
    }
    t0 = time.time()
    res5 = client.post(
        "/api/v1/admin/huberman-rag",
        json=payload5,
        headers={"Accept": "text/event-stream"}
    )
    lat5 = (time.time() - t0) * 1000
    
    assert res5.status_code == 200
    assert "text/event-stream" in res5.headers["content-type"]
    assert "data:" in res5.text
    
    # Parse SSE tokens
    tokens_count = res5.text.count("data: ")
    print(f"  ✓ Status: 200 OK ({lat5:.1f}ms)")
    print(f"  ✓ SSE Content-Type: {res5.headers['content-type']}")
    print(f"  ✓ Tokens Streamed: {tokens_count} event chunks received")
    passed_count += 1

    print("\n" + "=" * 70)
    print(f" 🎉 ALL {passed_count}/{total_tests} E2E TESTS PASSED WITH 100% SUCCESS!")
    print("=" * 70)


if __name__ == "__main__":
    run_e2e_suite()
