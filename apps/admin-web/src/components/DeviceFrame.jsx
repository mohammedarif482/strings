import React from 'react';
import { Wifi } from 'lucide-react';

export default function DeviceFrame({ children, className = '' }) {
  return (
    <div className={`relative mx-auto w-[380px] sm:w-[390px] h-[810px] rounded-[52px] bg-[#0E0D12] p-[11px] shadow-[0_25px_70px_rgba(0,0,0,0.85),0_0_0_1px_rgba(255,255,255,0.12),inset_0_0_3px_rgba(255,255,255,0.4)] transition-all duration-300 ${className}`}>
      {/* Outer Titanium Bezel Accent */}
      <div className="absolute inset-0 rounded-[52px] pointer-events-none border border-white/10" />

      {/* Side buttons */}
      <div className="absolute -left-[14px] top-[115px] w-[3px] h-[28px] bg-[#2E2A36] rounded-l-sm" /> {/* Action button */}
      <div className="absolute -left-[14px] top-[160px] w-[3px] h-[50px] bg-[#2E2A36] rounded-l-sm" /> {/* Vol up */}
      <div className="absolute -left-[14px] top-[225px] w-[3px] h-[50px] bg-[#2E2A36] rounded-l-sm" /> {/* Vol down */}
      <div className="absolute -right-[14px] top-[170px] w-[3px] h-[80px] bg-[#2E2A36] rounded-r-sm" /> {/* Power */}

      {/* Screen Inner Display */}
      <div className="relative w-full h-full rounded-[42px] bg-[#0B0A0E] overflow-hidden flex flex-col border border-white/5">
        {/* iOS Status Bar */}
        <div className="relative z-30 w-full h-11 px-7 pt-3 flex items-center justify-between text-white text-[13px] font-semibold tracking-tight select-none">
          {/* Time */}
          <span>9:41</span>

          {/* Dynamic Island */}
          <div className="absolute top-2.5 left-1/2 -translate-x-1/2 w-[110px] h-[30px] rounded-full bg-black flex items-center justify-between px-3 shadow-sm border border-white/5">
            <div className="w-2.5 h-2.5 rounded-full bg-[#1C1A24] flex items-center justify-center">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2A2338]" />
            </div>
            {/* Ambient orange pulse indicator in Dynamic Island */}
            <div className="flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-[#FF8A3D] animate-ping" />
            </div>
          </div>

          {/* Icons: Signal, Wifi, Battery */}
          <div className="flex items-center gap-1.5">
            {/* Cellular signal */}
            <div className="flex items-end gap-0.5 h-2.5">
              <div className="w-0.5 h-1 bg-white rounded-xs" />
              <div className="w-0.5 h-1.5 bg-white rounded-xs" />
              <div className="w-0.5 h-2 bg-white rounded-xs" />
              <div className="w-0.5 h-2.5 bg-white rounded-xs" />
            </div>
            {/* WiFi */}
            <Wifi className="w-3.5 h-3.5 stroke-[2.5]" />
            {/* Battery */}
            <div className="flex items-center">
              <div className="w-5 h-2.5 rounded-[4px] border border-white/80 p-0.5 flex items-center">
                <div className="h-full w-full bg-white rounded-[2px]" />
              </div>
              <div className="w-0.5 h-1 bg-white/80 rounded-r-xs" />
            </div>
          </div>
        </div>

        {/* Screen Children */}
        <div className="relative flex-1 w-full h-[calc(100%-44px)] overflow-hidden">
          {children}
        </div>

        {/* Bottom Home Indicator */}
        <div className="pointer-events-none absolute bottom-1.5 left-1/2 -translate-x-1/2 w-32 h-1 rounded-full bg-white/40 z-50" />
      </div>
    </div>
  );
}
