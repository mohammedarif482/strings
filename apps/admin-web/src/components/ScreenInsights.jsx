import React, { useState } from 'react';
import { MapPin, TrendingUp, ChevronDown, Activity, Heart, Send, Check } from 'lucide-react';
import { playHapticChime } from '../utils/sound';

export default function ScreenInsights({ appState, onUpdateScore }) {
  const [nudgeSent, setNudgeSent] = useState(false);
  const [currentHR, setCurrentHR] = useState(89);

  const handleSendNudge = () => {
    playHapticChime('nudge');
    setNudgeSent(true);
    setTimeout(() => {
      setNudgeSent(false);
    }, 4000);
  };

  // Capsule matrix data (4 rows x 7 days)
  // Types: 'reached' (filled cream), 'partial' (dashed), 'none' (dark)
  const activityMatrix = [
    ['reached', 'partial', 'none', 'reached', 'none', 'none', 'reached'],
    ['reached', 'reached', 'none', 'partial', 'reached', 'reached', 'reached'],
    ['none', 'reached', 'reached', 'none', 'reached', 'reached', 'partial'],
    ['none', 'none', 'reached', 'reached', 'none', 'partial', 'none'],
  ];

  return (
    <div className="relative w-full h-full flex flex-col justify-between overflow-y-auto no-scrollbar pb-28 text-white select-none">
      {/* Radiant Ambient Background Glow */}
      <div 
        className="pointer-events-none absolute -top-10 left-1/2 -translate-x-1/2 w-[380px] h-[340px] rounded-full blur-[70px] opacity-40"
        style={{
          background: 'radial-gradient(circle, rgba(255, 107, 44, 0.45) 0%, rgba(184, 93, 50, 0.15) 50%, transparent 80%)'
        }}
      />

      <div className="relative z-10 px-5 pt-3">
        {/* Top Header */}
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-xl font-bold tracking-tight text-white">AI Insights</h1>

          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/10 border border-white/15 backdrop-blur-md text-xs text-white/90 shadow-sm">
            <MapPin className="w-3 h-3 text-[#FFA05C]" />
            <span className="font-medium tracking-tight">Toronto, Ontario</span>
          </div>
        </div>

        {/* Master Readiness / Wellness Gauge */}
        <div className="relative flex flex-col items-center justify-center my-2">
          {/* Gauge SVG Arc */}
          <div className="relative w-72 h-44 flex items-center justify-center">
            <svg viewBox="0 0 240 140" className="w-full h-full drop-shadow-[0_0_20px_rgba(255,107,44,0.3)]">
              <defs>
                <linearGradient id="arcGradient" x1="0%" y1="100%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#7E3A1A" stopOpacity="0.8" />
                  <stop offset="40%" stopColor="#C85924" stopOpacity="0.9" />
                  <stop offset="75%" stopColor="#FF7A34" stopOpacity="1" />
                  <stop offset="100%" stopColor="#FFA66C" stopOpacity="1" />
                </linearGradient>
                {/* Glow filter */}
                <filter id="arcGlow" x="-20%" y="-20%" width="140%" height="140%">
                  <feGaussianBlur stdDeviation="4" result="blur" />
                  <feComposite in="SourceGraphic" in2="blur" operator="over" />
                </filter>
              </defs>

              {/* Background guide arc */}
              <path
                d="M 30 130 A 90 90 0 0 1 210 130"
                fill="none"
                stroke="rgba(255,255,255,0.06)"
                strokeWidth="16"
                strokeLinecap="round"
              />

              {/* Active illuminated gradient arc */}
              <path
                d="M 30 130 A 90 90 0 0 1 190 60"
                fill="none"
                stroke="url(#arcGradient)"
                strokeWidth="18"
                strokeLinecap="round"
                filter="url(#arcGlow)"
              />

              {/* Glowing Indicator Knob at the end of arc */}
              <circle cx="190" cy="60" r="10" fill="#FFFFFF" className="drop-shadow-[0_0_12px_rgba(255,255,255,0.9)]" />
              <circle cx="190" cy="60" r="4" fill="#FF6B2C" />

              {/* Small arrow marker on arc */}
              <g transform="translate(135, 34)">
                <circle cx="0" cy="0" r="8" fill="#1C1822" stroke="rgba(255,255,255,0.3)" strokeWidth="1" />
                <path d="M-2 -2 L2 0 L-2 2" fill="none" stroke="#FFFFFF" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </g>
            </svg>

            {/* Centered Score */}
            <div className="absolute top-16 left-1/2 -translate-x-1/2 flex flex-col items-center">
              <div className="flex items-baseline">
                <span className="text-4xl font-extrabold text-white tracking-tight leading-none">
                  {appState.wellnessScore}
                </span>
                <span className="text-sm font-semibold text-[#9E9EA7] ml-1">/100</span>
              </div>

              {/* Trend Badge */}
              <div className="mt-2 flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-white/5 border border-white/10 text-[10px] text-white/90">
                <TrendingUp className="w-3 h-3 text-[#FFA05C]" />
                <span>12% from last week</span>
              </div>
            </div>
          </div>

          {/* Subheading & Description */}
          <div className="text-center mt-1 mb-4">
            <h3 className="text-sm font-semibold text-white tracking-tight mb-1">
              Your wellness score
            </h3>
            <p className="text-[11px] leading-relaxed text-[#A0A0AA] max-w-[280px]">
              Your mindfulness habits improved, creating greater balance and emotional stability this week.
            </p>
          </div>
        </div>

        {/* Card 2: Mindfulness Activity Matrix Heatmap */}
        <div className="rounded-[24px] bg-[#16141B]/85 border border-white/10 p-4 mb-3 shadow-lg backdrop-blur-md">
          <div className="flex items-center justify-between mb-3.5">
            <div className="flex items-center gap-2 text-xs text-white/90 font-medium">
              <Activity className="w-4 h-4 text-[#FF8A3D]" />
              <span>Mindfulness Activity</span>
            </div>
            <button className="flex items-center gap-1 text-[11px] text-[#9E9EA7] bg-white/5 border border-white/10 px-2.5 py-1 rounded-lg hover:text-white">
              <span>Last Month</span>
              <ChevronDown className="w-3 h-3" />
            </button>
          </div>

          {/* Capsule Matrix */}
          <div className="space-y-1.5 mb-3.5">
            {activityMatrix.map((row, rIdx) => (
              <div key={rIdx} className="flex items-center justify-between gap-1.5">
                {row.map((item, cIdx) => (
                  <div
                    key={cIdx}
                    className={`h-4.5 rounded-full flex-1 transition-all duration-200 ${
                      item === 'reached'
                        ? 'bg-[#F3E8DC] shadow-[0_0_8px_rgba(243,232,220,0.5)]'
                        : item === 'partial'
                        ? 'border border-dashed border-white/40 bg-transparent'
                        : 'bg-white/[0.04]'
                    }`}
                    title={item === 'reached' ? 'Goal Reached' : item === 'partial' ? 'Partial Session' : 'No Activity'}
                  />
                ))}
              </div>
            ))}
          </div>

          {/* Matrix Legend */}
          <div className="flex items-center justify-between text-[10px] text-[#9E9EA7] pt-2 border-t border-white/5 px-1">
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-2 rounded-full bg-[#F3E8DC]" />
              <span>Goal reached</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-2 rounded-full border border-dashed border-white/50" />
              <span>Partial</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-2 rounded-full bg-white/10" />
              <span>No activity</span>
            </div>
          </div>
        </div>

        {/* Card 3: Daily Average Heart Rate / HRV */}
        <div className="rounded-[24px] bg-[#16141B]/85 border border-white/10 p-4 mb-3 shadow-lg backdrop-blur-md">
          <div className="flex items-center justify-between mb-2">
            <div>
              <span className="text-[10px] text-[#9E9EA7] uppercase tracking-wider block">Daily Average</span>
              <div className="flex items-baseline gap-1">
                <span className="text-xl font-bold text-white">76</span>
                <span className="text-xs font-semibold text-[#FF6B2C]">BPM</span>
              </div>
            </div>
            <div className="text-right">
              <span className="text-[10px] text-[#9E9EA7] block">Last reading</span>
              <span className="text-xs font-medium text-white/90">2 min ago</span>
            </div>
          </div>

          {/* HR Gradient Track & Dynamic Heart Pill */}
          <div className="relative pt-4 pb-2">
            {/* Track bar */}
            <div className="h-1.5 w-full rounded-full bg-gradient-to-r from-[#B85D32] via-[#FF6B2C] to-[#FFA05C] shadow-[0_0_10px_rgba(255,107,44,0.3)]" />

            {/* Floating Heart Badge at 89 BPM */}
            <div
              className="absolute -top-1 transition-all duration-300 -translate-x-1/2"
              style={{ left: `${((currentHR - 54) / (98 - 54)) * 100}%` }}
            >
              <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#FF6B2C] text-white text-[11px] font-bold shadow-[0_0_15px_rgba(255,107,44,0.8)] border border-white/30 animate-pulse">
                <Heart className="w-3 h-3 fill-white text-white" />
                <span>{currentHR}</span>
              </div>
            </div>

            {/* Min / Max Labels */}
            <div className="flex items-center justify-between text-[10px] text-[#9E9EA7] mt-3">
              <span>Lowest 54 ↓</span>
              <span>Peak 98 ↑</span>
            </div>
          </div>
        </div>

        {/* Card 4: Partner Sync / Couple Nudge Card */}
        <div className="rounded-[24px] bg-gradient-to-b from-[#201B28]/90 to-[#15121B]/90 border border-[#FF6B2C]/25 p-4 shadow-[0_8px_30px_rgba(0,0,0,0.5)] backdrop-blur-md">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-full bg-gradient-to-tr from-[#FF6B2C] to-[#FFA05C] flex items-center justify-center text-white text-xs font-bold border border-white/20">
                S
              </div>
              <div>
                <span className="text-xs font-bold text-white block leading-tight">Partner Status: Sarah</span>
                <span className="text-[10px] text-[#FFA05C] font-medium">Synced Wearable • Cycle Day 24</span>
              </div>
            </div>
            <span className="px-2 py-0.5 rounded-full bg-[#FF6B2C]/15 border border-[#FF6B2C]/30 text-[#FFA05C] text-[9px] font-semibold">
              Cortisol Alert
            </span>
          </div>

          <p className="text-[11px] text-[#D1D0D7] leading-relaxed mb-3">
            Sarah is forecasted to have a <span className="text-[#FFA05C] font-semibold">High Cortisol Spike</span> on Thursday. Clear her evening schedule or send a supportive check-in.
          </p>

          <button
            onClick={handleSendNudge}
            disabled={nudgeSent}
            className={`w-full py-2.5 px-4 rounded-full text-xs font-semibold flex items-center justify-center gap-1.5 transition-all duration-300 ${
              nudgeSent
                ? 'bg-emerald-500 text-white shadow-[0_0_20px_rgba(16,185,129,0.5)]'
                : 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8038] text-white hover:brightness-110 active:scale-95 shadow-[0_0_20px_rgba(255,107,44,0.4)]'
            }`}
          >
            {nudgeSent ? (
              <>
                <Check className="w-3.5 h-3.5" />
                <span>Nudge Sent to Sarah! ♥</span>
              </>
            ) : (
              <>
                <Send className="w-3.5 h-3.5" />
                <span>Send Supportive Nudge</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
