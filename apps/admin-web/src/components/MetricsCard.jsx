import React from 'react';

export default function MetricsCard({ title, value, subtitle, icon: Icon, color = 'brand' }) {
  return (
    <div className="bg-surface/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-brand/40 transition-all">
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium text-slate-400">{title}</span>
        {Icon && (
          <div className="p-2 rounded-xl bg-orange-500/10 text-brand">
            <Icon className="w-4 h-4" />
          </div>
        )}
      </div>
      <div className="mt-3">
        <div className="text-2xl font-bold tracking-tight text-white">{value}</div>
        {subtitle && <div className="mt-1 text-[11px] text-slate-400">{subtitle}</div>}
      </div>
    </div>
  );
}
