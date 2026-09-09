import React from 'react';
import { Activity, AlertTriangle, CheckCircle2, Zap } from 'lucide-react';

export default function PredictionFeed({ predictions = [] }) {
  return (
    <section className="bg-surface/90 border border-white/10 rounded-3xl p-5 shadow-2xl flex flex-col gap-4">
      <div className="flex items-center justify-between border-b border-white/10 pb-3">
        <div className="flex items-center gap-2">
          <Activity className="w-4 h-4 text-brand" />
          <h2 className="text-sm font-bold text-white tracking-wide">LIVE PREDICTION STREAM</h2>
        </div>
        <span className="text-[11px] text-slate-500 font-mono">1,000 devices simulated</span>
      </div>

      <div className="flex flex-col gap-3 max-h-[600px] overflow-y-auto pr-1">
        {predictions.map((p) => {
          const isHigh = p.combined_stress_index >= 0.70;
          return (
            <div 
              key={p.id}
              className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5 hover:border-white/15 transition-all flex flex-col gap-2"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="font-mono text-xs font-semibold text-slate-300">{p.user_anonymized_id}</span>
                  <span className="text-slate-600 text-xs">→</span>
                  <span className="font-mono text-xs text-slate-400">{p.partner_anonymized_id}</span>
                </div>
                <span className="text-[10px] text-slate-500">{p.created_at}</span>
              </div>

              <div className="flex items-center justify-between">
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-md uppercase bg-purple-500/20 text-purple-300 border border-purple-500/30">
                  Day {p.cycle_day} • {p.cycle_phase}
                </span>

                <div className={`px-2 py-0.5 rounded-full text-xs font-bold font-mono flex items-center gap-1 ${
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
