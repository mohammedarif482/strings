import React, { useState, useEffect } from 'react';
import { ArrowLeft, MoreHorizontal, Play, Pause, RotateCcw, RotateCw, Gauge, Sliders, Sparkles, Circle, CheckCircle } from 'lucide-react';
import { playAmbientDrone, playHapticChime } from '../utils/sound';

export default function ScreenPlayer({ onBack }) {
  const [isPlaying, setIsPlaying] = useState(true);
  const [activeNode, setActiveNode] = useState('mind');
  const [playheadPos, setPlayheadPos] = useState(12);
  const [isHolding, setIsHolding] = useState(false);
  const [sessionCompleted, setSessionCompleted] = useState(false);

  // Audio drone playback hook
  useEffect(() => {
    if (isPlaying) {
      playAmbientDrone(true);
    } else {
      playAmbientDrone(false);
    }
    return () => {
      playAmbientDrone(false);
    };
  }, [isPlaying]);

  // Animated visualizer playhead
  useEffect(() => {
    if (!isPlaying) return;
    const interval = setInterval(() => {
      setPlayheadPos((prev) => (prev + 1) % 24);
    }, 400);
    return () => clearInterval(interval);
  }, [isPlaying]);

  const togglePlay = () => {
    playHapticChime('tap');
    setIsPlaying(!isPlaying);
  };

  const handleNodeClick = (node) => {
    playHapticChime('pulse');
    setActiveNode(node);
  };

  const handleHoldToFinish = () => {
    setIsHolding(true);
    playHapticChime('nudge');
    setTimeout(() => {
      setSessionCompleted(true);
      setIsHolding(false);
      setIsPlaying(false);
    }, 1500);
  };

  // 24 columns x 5 rows of equalizer dots
  const columns = 24;
  const rows = 5;

  return (
    <div className="relative w-full h-full flex flex-col justify-between overflow-y-auto no-scrollbar pb-10 text-white select-none bg-[#0D0B10]">
      {/* Ambient background aura */}
      <div 
        className="pointer-events-none absolute top-10 left-1/2 -translate-x-1/2 w-[380px] h-[400px] rounded-full blur-[70px] opacity-40"
        style={{
          background: 'radial-gradient(circle, rgba(255, 138, 61, 0.4) 0%, rgba(184, 93, 50, 0.15) 50%, transparent 80%)'
        }}
      />

      {/* Top Header */}
      <div className="relative z-20 px-5 pt-3 flex items-center justify-between">
        <button
          onClick={() => {
            playAmbientDrone(false);
            onBack();
          }}
          className="flex items-center gap-2 text-white/90 hover:text-white transition-colors"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2]" />
          <span className="text-base font-semibold tracking-tight">Now Playing</span>
        </button>

        <button className="w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-[#9E9EA7] hover:text-white">
          <MoreHorizontal className="w-4 h-4" />
        </button>
      </div>

      {/* Central Ethereal Body Visualization */}
      <div className="relative flex-1 flex items-center justify-center min-h-[300px] my-2">
        {/* Glowing Luminous Silhouette Container */}
        <div className="relative w-64 h-80 flex items-center justify-center">
          {/* Outer soft ambient glow behind body */}
          <div className="absolute inset-0 bg-gradient-to-b from-white/20 via-[#FF8A3D]/25 to-white/5 blur-2xl rounded-full scale-90 animate-breathe" />

          {/* SVG Ethereal Human Silhouette */}
          <svg viewBox="0 0 200 320" className="w-full h-full drop-shadow-[0_0_25px_rgba(255,255,255,0.4)]" fill="none">
            <defs>
              <linearGradient id="bodyGlow" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stopColor="#FFFFFF" stopOpacity="0.85" />
                <stop offset="40%" stopColor="#FFDECB" stopOpacity="0.65" />
                <stop offset="70%" stopColor="#FFA05C" stopOpacity="0.45" />
                <stop offset="100%" stopColor="#FFFFFF" stopOpacity="0.2" />
              </linearGradient>
              <filter id="softGlow" x="-20%" y="-20%" width="140%" height="140%">
                <feGaussianBlur stdDeviation="3" result="blur" />
                <feComposite in="SourceGraphic" in2="blur" operator="over" />
              </filter>
            </defs>

            {/* Silhouette Outline */}
            <g filter="url(#softGlow)">
              {/* Head */}
              <ellipse cx="100" cy="50" rx="20" ry="24" fill="url(#bodyGlow)" opacity="0.9" />
              {/* Neck */}
              <path d="M94 72 L106 72 L109 85 L91 85 Z" fill="url(#bodyGlow)" opacity="0.8" />
              {/* Shoulders & Torso */}
              <path
                d="M91 85 C75 88 50 105 38 135 C32 150 42 165 48 160 C56 150 68 130 75 125 C72 150 72 195 78 220 C82 235 90 270 94 305 L106 305 C110 270 118 235 122 220 C128 195 128 150 125 125 C132 130 144 150 152 160 C158 165 168 150 162 135 C150 105 125 88 109 85 Z"
                fill="url(#bodyGlow)"
                opacity="0.75"
              />
            </g>

            {/* Pulsing Light Rings on Vitals */}
            {/* Mind Node Ring */}
            <circle cx="100" cy="50" r={activeNode === 'mind' ? 10 : 6} stroke="#FFFFFF" strokeWidth="1.5" className="animate-ping" opacity="0.6" />
            <circle cx="100" cy="50" r="3.5" fill="#FFFFFF" />

            {/* Heart Node Ring */}
            <circle cx="100" cy="115" r={activeNode === 'heart' ? 12 : 7} stroke="#FF6B2C" strokeWidth="1.5" className="animate-ping" opacity="0.7" />
            <circle cx="100" cy="115" r="4" fill="#FF6B2C" />

            {/* Breath Node Ring */}
            <circle cx="100" cy="155" r={activeNode === 'breath' ? 10 : 6} stroke="#FFA05C" strokeWidth="1.5" className="animate-ping" opacity="0.6" />
            <circle cx="100" cy="155" r="3.5" fill="#FFA05C" />

            {/* Leader lines */}
            <line x1="100" y1="50" x2="125" y2="40" stroke="rgba(255,255,255,0.4)" strokeDasharray="2 2" strokeWidth="1" />
            <line x1="100" y1="115" x2="135" y2="125" stroke="rgba(255,255,255,0.4)" strokeDasharray="2 2" strokeWidth="1" />
            <line x1="100" y1="155" x2="70" y2="170" stroke="rgba(255,255,255,0.4)" strokeDasharray="2 2" strokeWidth="1" />
          </svg>

          {/* Callout Pill: Mind */}
          <div
            onClick={() => handleNodeClick('mind')}
            className={`absolute top-4 right-0 px-3 py-1 rounded-xl cursor-pointer transition-all duration-300 border ${
              activeNode === 'mind'
                ? 'bg-[#1F1C25] border-[#FF8A3D] text-white shadow-[0_0_15px_rgba(255,138,61,0.4)] scale-105'
                : 'bg-[#18151D]/80 border-white/10 text-white/70 hover:text-white'
            }`}
          >
            <div className="text-[11px] font-semibold text-white leading-tight">Mind</div>
            <div className="text-[9px] text-[#A0A0AA] leading-tight">Release Thoughts</div>
          </div>

          {/* Callout Pill: Heart */}
          <div
            onClick={() => handleNodeClick('heart')}
            className={`absolute top-28 right-0 px-3 py-1 rounded-xl cursor-pointer transition-all duration-300 border ${
              activeNode === 'heart'
                ? 'bg-[#1F1C25] border-[#FF6B2C] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)] scale-105'
                : 'bg-[#18151D]/80 border-white/10 text-white/70 hover:text-white'
            }`}
          >
            <div className="text-[11px] font-semibold text-white leading-tight">Heart</div>
            <div className="text-[9px] text-[#A0A0AA] leading-tight">Find Peace</div>
          </div>

          {/* Callout Pill: Breath */}
          <div
            onClick={() => handleNodeClick('breath')}
            className={`absolute top-40 left-0 px-3 py-1 rounded-xl cursor-pointer transition-all duration-300 border ${
              activeNode === 'breath'
                ? 'bg-[#1F1C25] border-[#FFA05C] text-white shadow-[0_0_15px_rgba(255,160,92,0.4)] scale-105'
                : 'bg-[#18151D]/80 border-white/10 text-white/70 hover:text-white'
            }`}
          >
            <div className="text-[11px] font-semibold text-white leading-tight">Breath</div>
            <div className="text-[9px] text-[#A0A0AA] leading-tight">Stay Present</div>
          </div>
        </div>
      </div>

      {/* Track & Context Information */}
      <div className="relative z-20 px-6 flex flex-col items-center text-center mb-3">
        <div className="flex items-center gap-1.5 mb-1.5">
          <span className="w-1.5 h-1.5 rounded-full bg-[#FF8A3D]" />
          <span className="text-[10px] font-medium tracking-wide text-[#9E9EA7] uppercase">
            Aivo recommendation
          </span>
        </div>

        <h3 className="text-xl font-bold text-white tracking-tight mb-1.5">
          Reset Your Mind
        </h3>

        <p className="text-[11px] leading-relaxed text-[#A0A0AA] max-w-[270px] mb-3">
          A gentle guided session designed to release tension and bring your attention back to the present.
        </p>

        <div className="flex items-center gap-3 mb-4">
          <div className="flex items-center gap-1 text-[10px] text-white/80 bg-white/5 border border-white/10 px-2.5 py-0.5 rounded-full">
            <Play className="w-2.5 h-2.5 text-[#FFA05C] fill-current" />
            <span>10 min</span>
          </div>
          <div className="flex items-center gap-1 text-[10px] text-white/80 bg-white/5 border border-white/10 px-2.5 py-0.5 rounded-full">
            <Sparkles className="w-2.5 h-2.5 text-[#FFA05C]" />
            <span>Guided</span>
          </div>
        </div>

        {/* Matrix Dot Grid Audio Visualizer */}
        <div className="w-full max-w-[320px] mb-4">
          {/* Inverted Triangle Playhead Marker */}
          <div className="relative w-full h-3 mb-1">
            <div
              className="absolute -top-1 w-0 h-0 border-l-[4px] border-l-transparent border-r-[4px] border-r-transparent border-t-[5px] border-t-white transition-all duration-300"
              style={{
                left: `${(playheadPos / (columns - 1)) * 100}%`,
                transform: 'translateX(-50%)',
              }}
            />
          </div>

          {/* Matrix of Dots */}
          <div className="flex justify-between items-center bg-[#15131A] p-2.5 rounded-2xl border border-white/5 shadow-inner">
            {Array.from({ length: columns }).map((_, cIdx) => {
              const isNearPlayhead = Math.abs(cIdx - playheadPos) <= 2;
              return (
                <div key={cIdx} className="flex flex-col gap-1.5 items-center">
                  {Array.from({ length: rows }).map((_, rIdx) => {
                    const isLit = isPlaying && (isNearPlayhead ? (rIdx >= 1) : ((cIdx + rIdx) % 3 === 0));
                    return (
                      <div
                        key={rIdx}
                        className={`w-1.5 h-1.5 rounded-full transition-all duration-200 ${
                          isLit
                            ? 'bg-white shadow-[0_0_6px_rgba(255,255,255,0.8)] scale-110'
                            : 'bg-white/10'
                        }`}
                      />
                    );
                  })}
                </div>
              );
            })}
          </div>
        </div>

        {/* Dual Control Buttons: Hold to Finish & Take a Break */}
        <div className="w-full max-w-[320px] flex items-center gap-2.5 mb-4">
          {/* Hold to finish button */}
          <button
            onClick={handleHoldToFinish}
            disabled={sessionCompleted}
            className={`flex-1 py-3 px-3 rounded-full border text-xs font-semibold flex items-center justify-center gap-1.5 transition-all duration-200 ${
              sessionCompleted
                ? 'bg-emerald-500/20 border-emerald-500/40 text-emerald-400'
                : 'bg-[#1B1822] border-white/10 text-white/90 hover:bg-white/10 active:scale-95'
            }`}
          >
            {sessionCompleted ? (
              <>
                <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />
                <span>Finished!</span>
              </>
            ) : (
              <>
                <Circle className="w-3.5 h-3.5 stroke-[2.5]" />
                <span>Hold to finish</span>
              </>
            )}
          </button>

          {/* Take a break button */}
          <button
            onClick={togglePlay}
            className="flex-1 py-3 px-3 rounded-full bg-white text-black text-xs font-semibold flex items-center justify-center gap-1.5 hover:bg-white/90 active:scale-95 transition-all shadow-[0_0_15px_rgba(255,255,255,0.25)]"
          >
            {isPlaying ? (
              <>
                <Pause className="w-3.5 h-3.5 fill-black text-black" />
                <span>Take a break</span>
              </>
            ) : (
              <>
                <Play className="w-3.5 h-3.5 fill-black text-black" />
                <span>Resume</span>
              </>
            )}
          </button>
        </div>

        {/* Bottom Playback Navigation Bar */}
        <div className="w-full max-w-[320px] flex items-center justify-between px-2 pt-1 text-[#7E7D88]">
          <button className="p-2 hover:text-white transition-colors" title="Speed">
            <Gauge className="w-4 h-4" />
          </button>

          <button
            onClick={() => {
              playHapticChime('tap');
              setPlayheadPos((prev) => (prev > 3 ? prev - 3 : 0));
            }}
            className="p-2 hover:text-white transition-colors relative"
            title="Rewind 10s"
          >
            <RotateCcw className="w-4 h-4" />
            <span className="text-[8px] absolute top-2.5 left-2.5 font-bold">10</span>
          </button>

          {/* Glowing Center Amber Play/Pause Button */}
          <button
            onClick={togglePlay}
            className="w-12 h-12 rounded-full bg-gradient-to-b from-[#FF8A3D] to-[#FF5E1E] text-white flex items-center justify-center shadow-[0_0_25px_rgba(255,107,44,0.7)] hover:scale-105 active:scale-95 transition-all border border-[#FFA566]/60"
            title={isPlaying ? "Pause" : "Play"}
          >
            {isPlaying ? (
              <Pause className="w-5 h-5 fill-white text-white" />
            ) : (
              <Play className="w-5 h-5 fill-white text-white translate-x-0.5" />
            )}
          </button>

          <button
            onClick={() => {
              playHapticChime('tap');
              setPlayheadPos((prev) => (prev + 3) % columns);
            }}
            className="p-2 hover:text-white transition-colors relative"
            title="Forward 10s"
          >
            <RotateCw className="w-4 h-4" />
            <span className="text-[8px] absolute top-2.5 left-2.5 font-bold">10</span>
          </button>

          <button className="p-2 hover:text-white transition-colors" title="Audio Equalizer">
            <Sliders className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
