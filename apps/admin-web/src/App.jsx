import React, { useState } from 'react';
import AdminDashboard from './components/AdminDashboard';
import { Volume2, VolumeX, Sparkles } from 'lucide-react';
import { playAmbientDrone, playHapticChime } from './utils/sound';

export default function App() {
  const [soundEnabled, setSoundEnabled] = useState(false);

  const toggleSound = () => {
    if (soundEnabled) {
      playAmbientDrone(false);
      setSoundEnabled(false);
    } else {
      setSoundEnabled(true);
      playHapticChime('tap');
    }
  };

  return (
    <div className="min-h-screen bg-[#08080A] text-white flex flex-col items-center justify-between font-sans">
      {/* Top Floating Control Bar */}
      <header className="sticky top-0 z-50 w-full backdrop-blur-xl bg-[#100E14]/80 border-b border-white/10 px-4 py-3 flex items-center justify-between shadow-lg">
        {/* Left Branding */}
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-[#FF6B2C] to-[#FFA05C] flex items-center justify-center shadow-[0_0_15px_rgba(255,107,44,0.6)]">
            <Sparkles className="w-4 h-4 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold text-white tracking-tight flex items-center gap-1.5">
              Aivo Wellness <span className="text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded-full bg-[#FF6B2C]/20 text-[#FFA05C] border border-[#FF6B2C]/30">V1 Prototype</span>
            </h1>
            <p className="text-[11px] text-[#9E9EA7] hidden sm:block">Predictive Biological & Relationship Health</p>
          </div>
        </div>

        {/* Live Admin Console Telemetry Status */}
        <div className="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/25 text-emerald-400 text-xs font-mono">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          <span className="font-semibold tracking-wide">ADMIN CONSOLE</span>
          <span className="text-slate-500">•</span>
          <span className="text-slate-300">Live Telemetry (Arya & Arif)</span>
        </div>

        {/* Sound & Action Button */}
        <div className="flex items-center gap-2">
          <button
            onClick={toggleSound}
            className="p-2 rounded-full bg-white/5 border border-white/10 text-[#9E9EA7] hover:text-white hover:bg-white/10 transition-colors"
            title={soundEnabled ? "Mute Ambient Sound" : "Enable Ambient Sound"}
          >
            {soundEnabled ? <Volume2 className="w-4 h-4 text-[#FFA05C]" /> : <VolumeX className="w-4 h-4" />}
          </button>
        </div>
      </header>

      {/* Main Admin Console (Primary, Non-Toggleable View) */}
      <AdminDashboard />
    </div>
  );
}
