import React, { useState } from 'react';
import { Sun, MapPin, Play, ChevronRight, Sparkles, Activity, Clock, Heart } from 'lucide-react';
import { playHapticChime } from '../utils/sound';

export default function ScreenDashboard({ onPlaySession, appState }) {
  const [selectedDay, setSelectedDay] = useState(12);

  const days = [
    { day: 9, label: 'Sat' },
    { day: 10, label: 'Sun' },
    { day: 11, label: 'Mon' },
    { day: 12, label: 'Tue', active: true },
    { day: 13, label: 'Wed' },
    { day: 14, label: 'Thu' },
    { day: 15, label: 'Fri' },
  ];

  // Weekly energy bar heights
  const weeklyEnergy = [
    { day: 'S', height: '35%' },
    { day: 'M', height: '45%' },
    { day: 'T', height: '30%' },
    { day: 'W', height: '55%' },
    { day: 'T', height: '90%' },
    { day: 'F', height: `${Math.min(100, Math.max(20, appState.energy))}%` },
    { day: 'S', height: '70%' },
  ];

  return (
    <div className="relative w-full h-full flex flex-col justify-between overflow-y-auto no-scrollbar pb-28 text-white select-none">
      {/* Radiant Ambient Orange Glow Layer */}
      <div 
        className="pointer-events-none absolute -top-16 left-1/2 -translate-x-1/2 w-[420px] h-[360px] rounded-full blur-[65px] opacity-75"
        style={{
          background: 'radial-gradient(circle, rgba(255, 107, 44, 0.55) 0%, rgba(200, 80, 30, 0.25) 45%, rgba(11, 11, 14, 0) 75%)'
        }}
      />

      {/* Main Content Area */}
      <div className="relative z-10 px-5 pt-3">
        {/* Top Header */}
        <div className="flex items-center justify-between mb-4">
          {/* Brand Logo & Name */}
          <div className="flex items-center gap-2">
            <div className="w-6 h-6 rounded-full bg-white/10 flex items-center justify-center backdrop-blur-sm">
              <Sun className="w-4 h-4 text-white stroke-[2.2]" />
            </div>
            <span className="text-xl font-bold tracking-tight text-white">Aivo</span>
          </div>

          {/* Location Pill */}
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/10 border border-white/15 backdrop-blur-md text-xs text-white/90 shadow-sm">
            <MapPin className="w-3 h-3 text-[#FFA05C]" />
            <span className="font-medium tracking-tight">Toronto, Ontario</span>
          </div>
        </div>

        {/* Date / Cycle Ribbon */}
        <div className="relative mb-5">
          <div className="flex items-center justify-between overflow-x-auto no-scrollbar py-2 px-1">
            {days.map((item) => {
              const isSelected = selectedDay === item.day;
              return (
                <button
                  key={item.day}
                  onClick={() => {
                    setSelectedDay(item.day);
                    playHapticChime('tap');
                  }}
                  className={`flex flex-col items-center justify-center transition-all duration-300 relative group px-1.5 ${
                    isSelected ? 'scale-105' : 'opacity-70 hover:opacity-100'
                  }`}
                >
                  {/* Glowing Ring for active day */}
                  <div
                    className={`w-11 h-11 rounded-full flex items-center justify-center text-sm font-semibold transition-all duration-300 ${
                      isSelected
                        ? 'bg-gradient-to-b from-[#FFA767] to-[#FF6B2C] text-white shadow-[0_0_20px_rgba(255,107,44,0.7)] border-2 border-white/80'
                        : 'bg-white/5 text-white/80 border border-white/10 group-hover:bg-white/10'
                    }`}
                  >
                    {item.day}
                  </div>
                  <span className={`text-[11px] mt-1.5 font-medium ${isSelected ? 'text-white font-semibold' : 'text-[#9E9EA7]'}`}>
                    {item.label}
                  </span>
                </button>
              );
            })}
          </div>

          {/* Current Cycle Phase Micro-tag */}
          <div className="flex items-center justify-center gap-2 mt-1">
            <div className="w-1.5 h-1.5 rounded-full bg-[#FF8A3D] animate-ping" />
            <span className="text-[11px] text-[#FFA05C] font-medium tracking-wide">
              Luteal Phase • Day 22 (Cortisol Peak Forecasted)
            </span>
          </div>
        </div>

        {/* Hero Recommendation Card */}
        <div className="relative rounded-[28px] bg-gradient-to-b from-[#1C1822]/90 to-[#121017]/90 border border-white/10 p-6 mb-4 shadow-[0_15px_35px_rgba(0,0,0,0.5)] overflow-hidden">
          {/* Radiant ethereal silhouette artwork in card background */}
          <div className="absolute top-2 left-1/2 -translate-x-1/2 w-48 h-40 pointer-events-none opacity-40">
            <div className="w-full h-full rounded-full bg-gradient-to-b from-[#FF8A3D]/40 via-white/10 to-transparent blur-xl" />
            {/* Ethereal body icon outline */}
            <svg viewBox="0 0 100 120" className="absolute inset-0 w-full h-full text-white/60 drop-shadow-[0_0_15px_rgba(255,107,44,0.6)]" fill="none" stroke="currentColor">
              {/* Head */}
              <circle cx="50" cy="22" r="12" strokeWidth="1.5" className="animate-pulse" />
              {/* Torso */}
              <path d="M50 34 C 42 38, 38 48, 36 62 C 34 76, 42 90, 50 98 C 58 90, 66 76, 64 62 C 62 48, 58 38, 50 34 Z" strokeWidth="1.2" strokeDasharray="2 3" opacity="0.8" />
              {/* Pulse Core Nodes */}
              <circle cx="50" cy="22" r="2.5" fill="#FFA05C" />
              <circle cx="50" cy="52" r="3" fill="#FF6B2C" />
              <circle cx="50" cy="72" r="2.5" fill="#FF8A3D" />
            </svg>
          </div>

          <div className="relative z-10 flex flex-col items-center text-center">
            {/* Sub-tag */}
            <div className="flex items-center gap-1.5 mb-2">
              <span className="w-1.5 h-1.5 rounded-full bg-[#FF8A3D]" />
              <span className="text-[11px] font-medium tracking-wide text-[#9E9EA7] uppercase">
                Aivo recommendation
              </span>
            </div>

            {/* Title */}
            <h2 className="text-[22px] font-bold text-white tracking-tight mb-2">
              Reset Your Mind
            </h2>

            {/* Subtext */}
            <p className="text-[12px] leading-relaxed text-[#A0A0AA] max-w-[260px] mb-4">
              A gentle guided session designed to release tension and bring your attention back to the present.
            </p>

            {/* Action Chips */}
            <div className="flex items-center gap-3 mb-5">
              <div className="flex items-center gap-1 text-[11px] text-white/90 bg-white/5 border border-white/10 px-3 py-1 rounded-full">
                <Play className="w-3 h-3 text-[#FFA05C] fill-current" />
                <span>10 min</span>
              </div>
              <div className="flex items-center gap-1 text-[11px] text-white/90 bg-white/5 border border-white/10 px-3 py-1 rounded-full">
                <Sparkles className="w-3 h-3 text-[#FFA05C]" />
                <span>Guided</span>
              </div>
            </div>

            {/* Primary CTA Button: Play Now */}
            <button
              onClick={() => {
                playHapticChime('tap');
                onPlaySession();
              }}
              className="w-full py-3.5 px-6 rounded-full bg-white text-black font-semibold text-sm flex items-center justify-center gap-2 hover:bg-white/90 active:scale-[0.98] transition-all duration-200 shadow-[0_4px_25px_rgba(255,255,255,0.25)] group"
            >
              <Play className="w-4 h-4 fill-black text-black group-hover:translate-x-0.5 transition-transform" />
              <span>Play Now</span>
            </button>
          </div>
        </div>

        {/* Biometric & Forecast Grid */}
        <div className="space-y-3 mb-4">
          {/* Card 1: Energy Forecast */}
          <div className="rounded-[24px] bg-[#16141B]/80 border border-white/10 p-5 shadow-lg backdrop-blur-md">
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2 text-xs text-[#9E9EA7]">
                <Activity className="w-4 h-4 text-[#FF8A3D]" />
                <span className="font-medium">Energy Forecast</span>
              </div>
              <ChevronRight className="w-4 h-4 text-[#7E7D88]" />
            </div>

            <div className="flex items-end justify-between">
              {/* Big Percentage */}
              <div>
                <span className="text-[34px] font-extrabold tracking-tight text-white leading-none">
                  {appState.energy}%
                </span>
                <span className="block text-[11px] text-[#A0A0AA] mt-1">
                  Peak vitality predicted at 2:00 PM
                </span>
              </div>

              {/* Weekly Mini Bar Chart */}
              <div className="flex items-end gap-1.5 h-12 pb-1">
                {weeklyEnergy.map((bar, idx) => (
                  <div key={idx} className="flex flex-col items-center gap-1">
                    <div className="w-2.5 h-10 bg-white/5 rounded-full flex items-end overflow-hidden">
                      <div
                        className="w-full rounded-full bg-gradient-to-t from-[#B85D32] via-[#FF6B2C] to-[#FFA05C]"
                        style={{ height: bar.height }}
                      />
                    </div>
                    <span className="text-[9px] font-medium text-[#7E7D88]">{bar.day}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* 3 Metric Sub-Cards Grid */}
          <div className="grid grid-cols-3 gap-2.5">
            {/* Card 1: Average Session */}
            <div className="rounded-[20px] bg-[#16141B]/80 border border-white/10 p-3.5 flex flex-col justify-between backdrop-blur-md">
              <span className="text-sm font-bold text-white tracking-tight leading-tight">
                9 minutes
              </span>
              <span className="text-[10px] text-[#9E9EA7] mt-2 leading-tight">
                Average session
              </span>
            </div>

            {/* Card 2: Current Mood */}
            <div className="rounded-[20px] bg-[#16141B]/80 border border-white/10 p-3.5 flex flex-col justify-between backdrop-blur-md">
              <span className="text-sm font-bold text-white tracking-tight leading-tight">
                {appState.moodLabel}
              </span>
              <span className="text-[10px] text-[#9E9EA7] mt-2 leading-tight">
                Current mood
              </span>
            </div>

            {/* Card 3: Meditation Time */}
            <div className="rounded-[20px] bg-[#16141B]/80 border border-white/10 p-3.5 flex flex-col justify-between backdrop-blur-md">
              <span className="text-sm font-bold text-[#FF6B2C] tracking-tight leading-tight drop-shadow-[0_0_10px_rgba(255,107,44,0.4)]">
                8:30 <span className="text-[10px] font-normal text-[#FF8A3D]">PM</span>
              </span>
              <span className="text-[10px] text-[#9E9EA7] mt-2 leading-tight">
                Meditation Time
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
