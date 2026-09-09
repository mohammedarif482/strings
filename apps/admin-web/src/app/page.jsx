'use client';

import React, { useState } from 'react';
import { Users, HeartHandshake, ShieldCheck, Radio } from 'lucide-react';
import MetricsCard from '../components/MetricsCard';
import PredictionFeed from '../components/PredictionFeed';
import HubermanChat from '../components/HubermanChat';

export default function AdminPage() {
  const [analytics] = useState({
    activeUsers: '1,420',
    pairedCouples: '680',
    helpfulRate: '89.4%',
    simulatorStatus: 'Healthy (15.7ms p95)'
  });

  const [predictions] = useState([
    {
      id: 'p1',
      user_anonymized_id: 'USR-8192',
      partner_anonymized_id: 'USR-4011',
      cycle_day: 24,
      cycle_phase: 'luteal',
      combined_stress_index: 0.88,
      primary_driver: 'Late-luteal sensitivity + 5.2h sleep debt.',
      partner_nudge_status: 'delivered',
      partner_tapback_reaction: '❤️',
      created_at: 'Just now'
    },
    {
      id: 'p2',
      user_anonymized_id: 'USR-3104',
      partner_anonymized_id: 'USR-9921',
      cycle_day: 9,
      cycle_phase: 'follicular',
      combined_stress_index: 0.24,
      primary_driver: 'Balanced baseline, steady HRV (72ms).',
      partner_nudge_status: 'not_triggered',
      partner_tapback_reaction: null,
      created_at: '2m ago'
    }
  ]);

  return (
    <div className="max-w-7xl mx-auto p-6 flex flex-col gap-6">
      <header className="flex items-center justify-between pb-4 border-b border-white/10">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-brand to-brandLight flex items-center justify-center">
            <Radio className="w-5 h-5 text-white animate-pulse" />
          </div>
          <div>
            <h1 className="text-base font-bold text-white tracking-wide">AIVO ADMIN CONSOLE</h1>
            <p className="text-[11px] text-slate-400">Biometrics Telemetry & Neuroscience Vector System</p>
          </div>
        </div>
      </header>

      {/* Vitals Bar */}
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <MetricsCard title="Active Monitored Users" value={analytics.activeUsers} subtitle="↗ +8.2% simulated" icon={Users} />
        <MetricsCard title="Paired Couple Links" value={analytics.pairedCouples} subtitle="680 active pairs" icon={HeartHandshake} />
        <MetricsCard title="Nudge Helpful Rate" value={analytics.helpfulRate} subtitle="512 positive feedback" icon={ShieldCheck} />
        <MetricsCard title="Simulator Engine" value={analytics.simulatorStatus} subtitle="15-min autonomous loop" icon={Radio} />
      </section>

      {/* Workbench Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        <div className="lg:col-span-5">
          <PredictionFeed predictions={predictions} />
        </div>
        <div className="lg:col-span-7">
          <HubermanChat />
        </div>
      </div>
    </div>
  );
}
