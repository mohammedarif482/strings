import React, { useState } from 'react';
import DeviceFrame from './components/DeviceFrame';
import ScreenDashboard from './components/ScreenDashboard';
import ScreenPlayer from './components/ScreenPlayer';
import ScreenInsights from './components/ScreenInsights';
import BottomNavBar from './components/BottomNavBar';
import CheckInModal from './components/CheckInModal';
import ShowcaseView from './components/ShowcaseView';
import AdminDashboard from './components/AdminDashboard';
import { Smartphone, LayoutGrid, Volume2, VolumeX, Sparkles, Radio } from 'lucide-react';
import { playAmbientDrone, playHapticChime } from './utils/sound';

export default function App() {
  const [viewMode, setViewMode] = useState(() => {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      if (params.get('mode') === 'device') return 'single';
      if (params.get('mode') === 'showcase') return 'showcase';
    }
    return 'admin'; // Default to Admin Console
  });
  const [activeTab, setActiveTab] = useState('today'); // 'today' | 'player' | 'insights' | 'profile'
  const [isCheckInOpen, setIsCheckInOpen] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(true);

  // Dynamic application state
  const [appState, setAppState] = useState({
    wellnessScore: 82,
    energy: 78,
    moodLabel: 'Calm',
    stressLevel: 3,
    sleepHours: 8,
  });

  const handleSaveCheckIn = ({ mood, stress, energy, sleep }) => {
    // Recalculate predictive score
    const calculatedScore = Math.round(
      (mood * 4) + (energy * 0.3) + ((10 - stress) * 2.5) + (sleep * 1.5)
    );
    const clampedScore = Math.min(99, Math.max(45, calculatedScore));

    const moodNames = {
      1: 'Exhausted', 2: 'Vulnerable', 3: 'Anxious', 4: 'Tense',
      5: 'Neutral', 6: 'Balanced', 7: 'Restored', 8: 'Calm',
      9: 'Energized', 10: 'Vibrant'
    };

    setAppState({
      wellnessScore: clampedScore,
      energy: energy,
      moodLabel: moodNames[mood] || 'Calm',
      stressLevel: stress,
      sleepHours: sleep,
    });
  };

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

        {/* View Mode Switcher */}
        <div className="flex items-center gap-1.5 bg-black/40 p-1 rounded-full border border-white/10">
          <button
            onClick={() => {
              playHapticChime('tap');
              setViewMode('single');
            }}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
              viewMode === 'single'
                ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8038] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)]'
                : 'text-[#9E9EA7] hover:text-white'
            }`}
          >
            <Smartphone className="w-3.5 h-3.5" />
            <span>Interactive Device</span>
          </button>

          <button
            onClick={() => {
              playHapticChime('tap');
              setViewMode('showcase');
            }}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
              viewMode === 'showcase'
                ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8038] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)]'
                : 'text-[#9E9EA7] hover:text-white'
            }`}
          >
            <LayoutGrid className="w-3.5 h-3.5" />
            <span>3-Phone Showcase</span>
          </button>

          <button
            onClick={() => {
              playHapticChime('tap');
              setViewMode('admin');
            }}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
              viewMode === 'admin'
                ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8038] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)]'
                : 'text-[#9E9EA7] hover:text-white'
            }`}
          >
            <Radio className="w-3.5 h-3.5" />
            <span>Admin Console (RAG)</span>
          </button>
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

          <button
            onClick={() => {
              playHapticChime('tap');
              setIsCheckInOpen(true);
            }}
            className="hidden sm:flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/10 border border-white/15 text-xs font-semibold hover:bg-white/15 transition-all text-white"
          >
            <Sparkles className="w-3.5 h-3.5 text-[#FFA05C]" />
            <span>Quick Check-In</span>
          </button>
        </div>
      </header>

      {/* Main Viewport Container */}
      {viewMode === 'admin' ? (
        <AdminDashboard onBackToSimulator={() => setViewMode('single')} />
      ) : (
        <main className="w-full flex-1 flex flex-col items-center justify-center p-4">
          {viewMode === 'single' ? (
            <div className="relative py-4">
              <DeviceFrame>
                {/* Tab Screen Content */}
                {activeTab === 'today' && (
                  <ScreenDashboard
                    appState={appState}
                    onPlaySession={() => setActiveTab('player')}
                  />
                )}

                {activeTab === 'player' && (
                  <ScreenPlayer onBack={() => setActiveTab('today')} />
                )}

                {activeTab === 'insights' && (
                  <ScreenInsights
                    appState={appState}
                    onUpdateScore={() => {}}
                  />
                )}

                {activeTab === 'profile' && (
                  <div className="w-full h-full flex flex-col items-center justify-center p-6 text-center text-white select-none">
                    <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-[#FF6B2C] to-[#FFA05C] flex items-center justify-center text-3xl font-bold mb-4 shadow-[0_0_25px_rgba(255,107,44,0.6)]">
                      A
                    </div>
                    <h2 className="text-xl font-bold mb-1">Dr. Alex Rivera</h2>
                    <p className="text-xs text-[#9E9EA7] mb-6">Biological Profile • Toronto, ON</p>

                    <div className="w-full max-w-xs space-y-3">
                      <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-left">
                        <div className="text-[11px] text-[#9E9EA7]">Synced Partner</div>
                        <div className="text-sm font-semibold text-white">Sarah • Oura Ring v4 Connected</div>
                      </div>
                      <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-left">
                        <div className="text-[11px] text-[#9E9EA7]">Biometric Model</div>
                        <div className="text-sm font-semibold text-white">Cortisol & HRV Circadian Sync</div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Floating Bottom Nav */}
                {activeTab !== 'player' && (
                  <BottomNavBar
                    activeTab={activeTab}
                    onTabChange={(tab) => {
                      playHapticChime('tap');
                      setActiveTab(tab);
                    }}
                    onOpenCheckIn={() => setIsCheckInOpen(true)}
                  />
                )}
              </DeviceFrame>
            </div>
          ) : (
            <ShowcaseView
              appState={appState}
              onPlaySession={() => {
                setViewMode('single');
                setActiveTab('player');
              }}
              onOpenCheckIn={() => setIsCheckInOpen(true)}
            />
          )}
        </main>
      )}

      {/* Quick Check-in Bottom Sheet Modal */}
      <CheckInModal
        isOpen={isCheckInOpen}
        onClose={() => setIsCheckInOpen(false)}
        onSaveCheckIn={handleSaveCheckIn}
      />
    </div>
  );
}
