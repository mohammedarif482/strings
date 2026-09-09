'use client';

import React, { useState, useEffect } from 'react';
import { Activity, AlertTriangle, CheckCircle2, Zap, Heart, Flame } from 'lucide-react';

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'https://strings-api.onrender.com';

export default function PredictionFeed({ predictions: initialPredictions = [] }) {
  const [feedItems, setFeedItems] = useState(initialPredictions);
  const [isLiveConnected, setIsLiveConnected] = useState(false);

  useEffect(() => {
    if (initialPredictions.length > 0 && feedItems.length === 0) {
      setFeedItems(initialPredictions);
    }
  }, [initialPredictions]);

  useEffect(() => {
    let eventSource = null;
    try {
      eventSource = new EventSource(`${API_BASE}/api/v1/stream`);
      
      eventSource.onopen = () => {
        setIsLiveConnected(true);
      };

      eventSource.onmessage = (e) => {
        try {
          const payload = JSON.parse(e.data);
          if (payload.profiles && Array.isArray(payload.profiles)) {
            const liveRecords = payload.profiles.map((prof) => {
              const isAlpha = prof.user_id === 'USR-ALPHA';
              const partnerId = isAlpha ? 'USR-BETA' : 'USR-ALPHA';
              const csi = prof.couple_stress_index ?? (isAlpha ? 0.82 : 0.24);
              const isLuteal = prof.cycle_phase.toLowerCase().includes('luteal');

              return {
                id: `live_${prof.user_id}_${Date.now()}`,
                user_anonymized_id: prof.user_id,
                partner_anonymized_id: partnerId,
                cycle_day: isAlpha ? 24 : 9,
                cycle_phase: isLuteal ? 'luteal' : 'follicular',
                combined_stress_index: csi,
                hrv_ms: prof.hrv_ms,
                heart_rate_bpm: prof.heart_rate_bpm,
                cortisol_state: prof.cortisol_state,
                predicted_state: isAlpha ? 'High Stress / Cortisol Elevation' : 'Restorative Baseline',
                primary_driver: isAlpha
                  ? `Late-luteal sensitivity (Day 24) • HRV ${prof.hrv_ms}ms • HR ${prof.heart_rate_bpm}bpm • Cortisol ${prof.cortisol_state}.`
                  : `Follicular restorative baseline (Day 9) • HRV ${prof.hrv_ms}ms • HR ${prof.heart_rate_bpm}bpm • Cortisol ${prof.cortisol_state}.`,
                partner_nudge_status: isAlpha ? 'delivered' : 'not_triggered',
                partner_tapback_reaction: isAlpha ? '❤️' : null,
                created_at: 'Live Stream'
              };
            });
            setFeedItems(liveRecords);
            setIsLiveConnected(true);
          }
        } catch {
          // ignore keepalive
        }
      };

      eventSource.onerror = () => {
        setIsLiveConnected(false);
      };
    } catch {
      setIsLiveConnected(false);
    }

    return () => {
      if (eventSource) eventSource.close();
    };
  }, []);

  const displayedList = feedItems.length > 0 ? feedItems : initialPredictions;

  return (
    <section className="bg-surface/90 border border-white/10 rounded-3xl p-5 shadow-2xl flex flex-col gap-4">
      <div className="flex items-center justify-between border-b border-white/10 pb-3">
        <div className="flex items-center gap-2">
          <Activity className="w-4 h-4 text-brand animate-pulse" />
          <h2 className="text-sm font-bold text-white tracking-wide">LIVE PREDICTION STREAM</h2>
        </div>
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[11px] font-mono">
          <span className={`w-1.5 h-1.5 rounded-full ${isLiveConnected ? 'bg-emerald-400 animate-ping' : 'bg-amber-400'}`} />
          <span>2 Active Test Profiles (USR-ALPHA, USR-BETA)</span>
        </div>
      </div>

      <div className="flex flex-col gap-3 max-h-[600px] overflow-y-auto pr-1">
        {displayedList.map((p) => {
          const isHigh = p.combined_stress_index >= 0.70;
          return (
            <div 
              key={p.id}
              className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5 hover:border-white/15 transition-all flex flex-col gap-2.5"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="font-mono text-xs font-semibold text-slate-200">{p.user_anonymized_id}</span>
                  <span className="text-slate-600 text-xs">→</span>
                  <span className="font-mono text-xs text-slate-400">{p.partner_anonymized_id}</span>
                </div>
                <span className="text-[10px] text-slate-400 font-mono">{p.created_at}</span>
              </div>

              {/* Biometrics row: HRV, HR, Cortisol */}
              <div className="grid grid-cols-3 gap-2 bg-white/[0.02] p-2 rounded-xl border border-white/5 text-[11px] font-mono">
                <div className="flex flex-col">
                  <span className="text-[9px] text-slate-500 uppercase">Live HRV</span>
                  <span className={`font-bold ${isHigh ? 'text-rose-300' : 'text-emerald-300'}`}>
                    {p.hrv_ms ? `${p.hrv_ms} ms` : '42 ms'}
                  </span>
                </div>
                <div className="flex flex-col">
                  <span className="text-[9px] text-slate-500 uppercase">Heart Rate</span>
                  <span className="font-bold text-slate-300">
                    {p.heart_rate_bpm ? `${p.heart_rate_bpm} bpm` : '82 bpm'}
                  </span>
                </div>
                <div className="flex flex-col">
                  <span className="text-[9px] text-slate-500 uppercase">Cortisol</span>
                  <span className={`font-bold ${p.cortisol_state === 'High' ? 'text-rose-400' : 'text-emerald-400'}`}>
                    {p.cortisol_state || (isHigh ? 'High' : 'Normal')}
                  </span>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-md uppercase border ${
                  p.cycle_phase === 'luteal'
                    ? 'bg-purple-500/20 text-purple-300 border-purple-500/30'
                    : 'bg-cyan-500/20 text-cyan-300 border-cyan-500/30'
                }`}>
                  Day {p.cycle_day} • {p.cycle_phase}
                </span>

                <div className={`px-2.5 py-0.5 rounded-full text-xs font-bold font-mono flex items-center gap-1 ${
                  isHigh 
                    ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30' 
                    : 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                }`}>
                  {isHigh ? <AlertTriangle className="w-3 h-3" /> : <CheckCircle2 className="w-3 h-3" />}
                  <span>CSI {(p.combined_stress_index * 100).toFixed(0)}%</span>
                </div>
              </div>

              <p className="text-xs text-slate-300 leading-snug">{p.primary_driver}</p>

              <div className="flex items-center justify-between pt-1 border-t border-white/5 text-[11px]">
                <span className="text-slate-400 flex items-center gap-1">
                  <Zap className="w-3 h-3 text-brand" />
                  <span>Nudge: <strong className="text-slate-300 capitalize">{p.partner_nudge_status}</strong></span>
                </span>
                {p.partner_tapback_reaction && (
                  <span className="px-1.5 py-0.5 rounded-md bg-white/5 text-[10px] text-slate-300">
                    Partner reacted {p.partner_tapback_reaction}
                  </span>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
