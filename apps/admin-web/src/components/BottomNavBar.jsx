import React from 'react';
import { Home, Star, Activity, User, Sun } from 'lucide-react';

export default function BottomNavBar({ activeTab, onTabChange, onOpenCheckIn }) {
  return (
    <div className="absolute bottom-5 left-0 right-0 px-5 pointer-events-auto z-40">
      <div className="mx-auto max-w-[340px] h-[64px] rounded-full bg-[#16141B]/85 backdrop-blur-2xl border border-white/10 shadow-[0_12px_40px_rgba(0,0,0,0.7)] px-4 flex items-center justify-between">
        {/* Tab 1: Dashboard */}
        <button
          onClick={() => onTabChange('today')}
          aria-label="Today Dashboard"
          className="p-2.5 rounded-full transition-all duration-200 group flex items-center justify-center text-white"
        >
          <div className={`p-1.5 rounded-xl transition-colors ${activeTab === 'today' ? 'bg-white/15 text-white' : 'text-[#7E7D88] hover:text-white'}`}>
            <Home className="w-5 h-5 stroke-[2]" />
          </div>
        </button>

        {/* Tab 2: Favorites / Guided */}
        <button
          onClick={() => onTabChange('player')}
          aria-label="Now Playing Session"
          className="p-2.5 rounded-full transition-all duration-200 group flex items-center justify-center"
        >
          <div className={`p-1.5 rounded-xl transition-colors ${activeTab === 'player' ? 'bg-white/15 text-white' : 'text-[#7E7D88] hover:text-white'}`}>
            <Star className="w-5 h-5 stroke-[2]" />
          </div>
        </button>

        {/* Center Glowing Action Button (FAB) */}
        <div className="relative -top-1">
          <button
            onClick={onOpenCheckIn}
            aria-label="Quick Check-in"
            className="w-13 h-13 px-4 py-2.5 rounded-full bg-gradient-to-b from-[#FF8A3D] to-[#FF5E1E] text-white flex items-center justify-center shadow-[0_0_25px_rgba(255,107,44,0.65)] hover:scale-105 active:scale-95 transition-all duration-200 border border-[#FFA566]/60 group"
          >
            <Sun className="w-6 h-6 text-white stroke-[2.2] animate-spin-slow group-hover:rotate-45 transition-transform" />
          </button>
        </div>

        {/* Tab 4: Insights */}
        <button
          onClick={() => onTabChange('insights')}
          aria-label="AI Insights"
          className="p-2.5 rounded-full transition-all duration-200 group flex items-center justify-center"
        >
          <div className={`p-1.5 rounded-xl transition-colors ${activeTab === 'insights' ? 'bg-white/15 text-white' : 'text-[#7E7D88] hover:text-white'}`}>
            <Activity className="w-5 h-5 stroke-[2]" />
          </div>
        </button>

        {/* Tab 5: Profile / Partner */}
        <button
          onClick={() => onTabChange('profile')}
          aria-label="Profile"
          className="p-2.5 rounded-full transition-all duration-200 group flex items-center justify-center"
        >
          <div className={`p-1.5 rounded-xl transition-colors ${activeTab === 'profile' ? 'bg-white/15 text-white' : 'text-[#7E7D88] hover:text-white'}`}>
            <User className="w-5 h-5 stroke-[2]" />
          </div>
        </button>
      </div>
    </div>
  );
}
