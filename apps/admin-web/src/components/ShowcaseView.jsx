import React from 'react';
import DeviceFrame from './DeviceFrame';
import ScreenDashboard from './ScreenDashboard';
import ScreenPlayer from './ScreenPlayer';
import ScreenInsights from './ScreenInsights';
import BottomNavBar from './BottomNavBar';

export default function ShowcaseView({ appState, onPlaySession, onOpenCheckIn }) {
  return (
    <div className="relative w-full min-h-screen py-10 px-4 flex flex-col items-center justify-center overflow-x-auto bg-[#ECE8E1] text-[#222]">
      {/* Subtle Studio Striped Background (matching reference render) */}
      <div 
        className="pointer-events-none absolute inset-0 opacity-40"
        style={{
          backgroundImage: 'repeating-linear-gradient(90deg, transparent, transparent 38px, rgba(0,0,0,0.04) 38px, rgba(0,0,0,0.04) 40px)'
        }}
      />

      {/* Atmospheric studio vignette */}
      <div 
        className="pointer-events-none absolute inset-0"
        style={{
          background: 'radial-gradient(circle at 50% 40%, rgba(255,255,255,0.7) 0%, rgba(225,220,210,0.4) 60%, rgba(195,190,180,0.7) 100%)'
        }}
      />

      {/* 3 Mockup Phones Side by Side */}
      <div className="relative z-10 w-full max-w-[1380px] flex flex-col lg:flex-row items-center justify-center gap-8 xl:gap-12 my-6">
        {/* Phone 1: Dashboard / Today */}
        <div className="flex flex-col items-center transition-transform hover:-translate-y-2 duration-300">
          <div className="text-xs font-semibold uppercase tracking-widest text-[#777] mb-3">
            Screen 1 • Today View
          </div>
          <div className="relative">
            <DeviceFrame className="shadow-[0_30px_70px_rgba(0,0,0,0.45)]">
              <ScreenDashboard onPlaySession={onPlaySession} appState={appState} />
              <BottomNavBar activeTab="today" onTabChange={() => {}} onOpenCheckIn={onOpenCheckIn} />
            </DeviceFrame>
          </div>
        </div>

        {/* Phone 2: Active State / Player (Center) */}
        <div className="flex flex-col items-center transition-transform hover:-translate-y-2 duration-300 lg:-translate-y-4">
          <div className="text-xs font-semibold uppercase tracking-widest text-[#FF6B2C] mb-3 flex items-center gap-1">
            <span className="w-2 h-2 rounded-full bg-[#FF6B2C] animate-ping" />
            Screen 2 • Guided Player
          </div>
          <div className="relative">
            <DeviceFrame className="shadow-[0_35px_80px_rgba(0,0,0,0.5)]">
              <ScreenPlayer onBack={() => {}} />
            </DeviceFrame>
          </div>
        </div>

        {/* Phone 3: AI Insights (Right) */}
        <div className="flex flex-col items-center transition-transform hover:-translate-y-2 duration-300">
          <div className="text-xs font-semibold uppercase tracking-widest text-[#777] mb-3">
            Screen 3 • AI Insights
          </div>
          <div className="relative">
            <DeviceFrame className="shadow-[0_30px_70px_rgba(0,0,0,0.45)]">
              <ScreenInsights appState={appState} onUpdateScore={() => {}} />
              <BottomNavBar activeTab="insights" onTabChange={() => {}} onOpenCheckIn={onOpenCheckIn} />
            </DeviceFrame>
          </div>
        </div>
      </div>

      {/* Footer Branding matching mockup reference */}
      <div className="relative z-10 w-full max-w-[1240px] flex items-center justify-between px-6 pt-6 text-[#444] border-t border-black/10">
        <div className="flex items-center gap-2 font-semibold tracking-tight text-sm">
          {/* Logo glyph */}
          <div className="w-5 h-5 flex items-center justify-center">
            <svg viewBox="0 0 24 24" className="w-full h-full text-black fill-current">
              <path d="M12 2L6 8L12 14L18 8L12 2ZM6 16L12 22L18 16L12 10L6 16Z" />
            </svg>
          </div>
          <span className="font-bold text-base tracking-tight text-black font-serif italic">Orbix Studio</span>
        </div>

        <div className="flex items-center gap-1.5 text-xs font-medium text-[#555]">
          <span>Press like</span>
          <span className="text-red-500">♥</span>
        </div>
      </div>
    </div>
  );
}
