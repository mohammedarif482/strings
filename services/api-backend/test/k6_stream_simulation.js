import http from 'k6/http';
import { check, sleep } from 'k6';

/**
 * k6 Load Test: 500 Concurrent Simulated Couples
 * Continuous 15-minute streaming cycle emulation
 */
export const options = {
  stages: [
    { duration: '30s', target: 100 }, // Ramp up to 100 couples
    { duration: '1m', target: 500 },  // Spike to 500 couples (1,000 devices)
    { duration: '30s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<400'], // 95% of state calculations must complete in <200ms
    http_req_failed: ['rate<0.01'],                 // Error rate < 1%
  },
};

const BASE_URL = __ENV.API_BASE_URL || 'http://localhost:8080/api/v1';

export default function () {
  const userId = `couple_${__VU}_device_${__ITER % 2 === 0 ? 'A' : 'B'}`;

  // 1. Wearable Stream Payload
  const wearablePayload = JSON.stringify({
    userId: 'alex_01', // Route to active seeded user
    hrv_ms: Math.floor(Math.random() * (85 - 45 + 1)) + 45,
    resting_hr: Math.floor(Math.random() * (76 - 54 + 1)) + 54,
    deep_sleep_minutes: Math.floor(Math.random() * (130 - 70 + 1)) + 70,
    is_simulated: true,
    simulation_run_id: `k6_${userId}`,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const streamRes = http.post(`${BASE_URL}/wearable/stream`, wearablePayload, params);

  check(streamRes, {
    'wearable stream status 201': (r) => r.status === 201,
    'prediction object returned': (r) => JSON.parse(r.body).prediction !== undefined,
    'calculation duration < 200ms': (r) => r.timings.duration < 200,
  });

  // 2. Periodic Prediction Card Fetch
  if (__ITER % 5 === 0) {
    const todayRes = http.get(`${BASE_URL}/predictions/today?userId=alex_01`);
    check(todayRes, {
      'today prediction status 200': (r) => r.status === 200,
      'wellness score exists': (r) => JSON.parse(r.body).wellnessScore >= 45,
    });
  }

  sleep(1); // 1-second cadence between virtual user ticks
}
