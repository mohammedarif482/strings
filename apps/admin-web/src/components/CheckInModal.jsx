import React, { useState } from 'react';
import { X, Sparkles, HeartPulse, BatteryCharging, Moon, Smile } from 'lucide-react';
import { playHapticChime } from '../utils/sound';

export default function CheckInModal({ isOpen, onClose, onSaveCheckIn }) {
  const [mood, setMood] = useState(8);
  const [stress, setStress] = useState(3);
  const [energy, setEnergy] = useState(78);
  const [sleep, setSleep] = useState(8);

  if (!isOpen) return null;

  const getMoodLabel = (v) => {
    if (v <= 3) return 'Vulnerable';
    if (v <= 6) return 'Balanced';
    if (v <= 8) return 'Calm & Centered';
    return 'Vibrant & Radiating';
  };

  const getStressLabel = (v) => {
    if (v <= 3) return 'Low Cortisol (Optimal)';
    if (v <= 6) return 'Moderate Tension';
    if (v <= 8) return 'Elevated Stress';
    return 'Cortisol Spike Warning';
  };

  const handleSave = () => {
    playHapticChime('nudge');
    onSaveCheckIn({ mood, stress, energy, sleep });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-md transition-opacity">
      {/* Click outside backdrop */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* Modal Sheet */}
      <div className="relative w-full max-w-[430px] rounded-t-[32px] bg-[#141219]/95 backdrop-blur-2xl border-t border-x border-white/10 p-6 pb-10 shadow-[0_-20px_60px_rgba(0,0,0,0.8)] z-10 animate-in slide-in-from-bottom duration-300">
        {/* Grab bar */}
        <div className="mx-auto w-12 h-1 rounded-full bg-white/20 mb-5" />

        <div className="flex items-center justify-between mb-6">
          <div>
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-[#FF6B2C]/20 text-[#FF8A3D]">
                <Sparkles className="w-3.5 h-3.5" />
              </span>
              <h3 className="text-xl font-semibold text-white tracking-tight">30-Sec Quick Check-In</h3>
            </div>
            <p className="text-xs text-[#9E9EA7] mt-0.5">Calibrating your biological & cortisol forecast</p>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-[#9E9EA7] hover:text-white hover:bg-white/10 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* 4 Interactive Sliders */}
        <div className="space-y-5 mb-8">
          {/* 1. Mood Slider */}
          <div className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5">
            <div className="flex items-center justify-between text-xs mb-2">
              <span className="flex items-center gap-1.5 text-white/90 font-medium">
                <Smile className="w-4 h-4 text-[#FF8A3D]" /> Current Mood
              </span>
              <span className="text-[#FF8A3D] font-semibold">{getMoodLabel(mood)} ({mood}/10)</span>
            </div>
            <input
              type="range"
              min="1"
              max="10"
              value={mood}
              onChange={(e) => {
                setMood(Number(e.target.value));
                playHapticChime('tap');
              }}
              className="w-full accent-[#FF6B2C]"
            />
          </div>

          {/* 2. Stress / Cortisol Slider */}
          <div className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5">
            <div className="flex items-center justify-between text-xs mb-2">
              <span className="flex items-center gap-1.5 text-white/90 font-medium">
                <HeartPulse className="w-4 h-4 text-[#FF6B2C]" /> Stress & Tension
              </span>
              <span className="text-[#FFA05C] font-semibold">{getStressLabel(stress)} ({stress}/10)</span>
            </div>
            <input
              type="range"
              min="1"
              max="10"
              value={stress}
              onChange={(e) => {
                setStress(Number(e.target.value));
                playHapticChime('tap');
              }}
              className="w-full accent-[#FF6B2C]"
            />
          </div>

          {/* 3. Energy Forecast Slider */}
          <div className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5">
            <div className="flex items-center justify-between text-xs mb-2">
              <span className="flex items-center gap-1.5 text-white/90 font-medium">
                <BatteryCharging className="w-4 h-4 text-[#FF8A3D]" /> Physical Energy
              </span>
              <span className="text-white font-semibold">{energy}%</span>
            </div>
            <input
              type="range"
              min="20"
              max="100"
              value={energy}
              onChange={(e) => {
                setEnergy(Number(e.target.value));
                playHapticChime('tap');
              }}
              className="w-full accent-[#FF6B2C]"
            />
          </div>

          {/* 4. Sleep Quality Slider */}
          <div className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5">
            <div className="flex items-center justify-between text-xs mb-2">
              <span className="flex items-center gap-1.5 text-white/90 font-medium">
                <Moon className="w-4 h-4 text-[#FFB074]" /> Sleep Quality
              </span>
              <span className="text-white font-semibold">{sleep} hrs (Restorative)</span>
            </div>
            <input
              type="range"
              min="4"
              max="12"
              step="0.5"
              value={sleep}
              onChange={(e) => {
                setSleep(Number(e.target.value));
                playHapticChime('tap');
              }}
              className="w-full accent-[#FF6B2C]"
            />
          </div>
        </div>

        {/* Submit CTA */}
        <button
          onClick={handleSave}
          className="w-full py-4 rounded-full bg-gradient-to-r from-[#FF6B2C] via-[#FF8038] to-[#FF5E1E] text-white font-semibold text-sm tracking-wide shadow-[0_0_30px_rgba(255,107,44,0.5)] hover:shadow-[0_0_40px_rgba(255,107,44,0.7)] active:scale-[0.98] transition-all flex items-center justify-center gap-2 border border-white/20"
        >
          <Sparkles className="w-4 h-4" /> Save & Generate Forecast
        </button>
      </div>
    </div>
  );
}
