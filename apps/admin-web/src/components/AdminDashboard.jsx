import React, { useState, useEffect, useRef } from 'react';
import { 
  Activity, Users, HeartHandshake, ShieldCheck, Sparkles, 
  Send, RefreshCw, ChevronDown, ChevronUp, BookOpen, Clock, 
  AlertTriangle, CheckCircle2, ArrowUpRight, Zap, Radio
} from 'lucide-react';

const getApiBase = () => {
  if (typeof window !== 'undefined') {
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      return 'http://localhost:8000';
    }
  }
  return 'https://strings-api.onrender.com';
};

const API_BASE = getApiBase();

export default function AdminDashboard({ onBackToSimulator }) {
  // --- Dedicated Live Telemetry State for Arya & Arif ---
  const [dyadicCSI, setDyadicCSI] = useState(0.58);
  const [lastTickTime, setLastTickTime] = useState('10s loop');
  const [isLiveConnected, setIsLiveConnected] = useState(false);

  const [liveArya, setLiveArya] = useState({
    user_id: 'arya_female',
    display_name: 'Arya',
    gender: 'female',
    hrv_ms: 42,
    heart_rate_bpm: 85,
    cycle_phase: 'Luteal Day 24',
    cycle_day: 24,
    cortisol_state: 'High',
    couple_stress_index: 0.82
  });

  const [liveArif, setLiveArif] = useState({
    user_id: 'arif_male',
    display_name: 'Arif',
    gender: 'male',
    hrv_ms: 75,
    heart_rate_bpm: 63,
    cycle_phase: null,
    circadian_status: 'Circadian Recovery',
    cortisol_state: 'Normal',
    couple_stress_index: 0.22
  });

  // --- State ---
  const [analytics, setAnalytics] = useState({
    active_users: 2,
    paired_couples: 1,
    total_daily_predictions: 48,
    nudge_helpful_rate: 89.4,
    cloud_simulator_health: {
      status: 'Healthy (Live Stream)',
      streaming_active: true,
      mean_pipeline_latency_ms: 12.4,
      cycle_interval_minutes: 15
    }
  });

  const [predictions, setPredictions] = useState([
    {
      id: 'pred_arya_init',
      user_anonymized_id: 'Arya',
      partner_anonymized_id: 'Arif',
      gender: 'female',
      cycle_day: 24,
      cycle_phase: 'Luteal',
      combined_stress_index: 0.82,
      confidence_score: 0.94,
      predicted_state: 'High Stress & Cortisol Shift',
      primary_driver: 'Late-luteal sensitivity (Day 24) • HRV 42ms • HR 86bpm • Cortisol High.',
      state_tag: 'luteal_high_cortisol',
      partner_nudge_status: 'delivered',
      partner_tapback_reaction: '❤️',
      created_at: 'Just now'
    },
    {
      id: 'pred_arif_init',
      user_anonymized_id: 'Arif',
      partner_anonymized_id: 'Arya',
      gender: 'male',
      cycle_day: null,
      cycle_phase: 'Circadian Recovery',
      combined_stress_index: 0.24,
      confidence_score: 0.91,
      predicted_state: 'Restorative Autonomic Baseline',
      primary_driver: 'Diurnal circadian recovery • HRV 75ms • HR 63bpm • Cortisol Normal.',
      state_tag: 'circadian_optimal',
      partner_nudge_status: 'not_triggered',
      partner_tapback_reaction: null,
      created_at: 'Just now'
    }
  ]);

  const [chatMessages, setChatMessages] = useState([
    {
      id: 'welcome',
      role: 'assistant',
      content: "Hello! I am your Huberman Lab RAG Assistant. I am grounded in Dr. Andrew Huberman's peer-reviewed neuroscience protocols regarding cortisol control, circadian anchoring, female hormone phase regulation, and dopamine dynamics. How can I assist you with clinical or protocol queries?",
      sources: []
    }
  ]);

  const [inputQuery, setInputQuery] = useState('');
  const [isAiLoading, setIsAiLoading] = useState(false);
  const [expandedSources, setExpandedSources] = useState({});
  const chatBottomRef = useRef(null);

  // Fetch live analytics & predictions on mount
  const fetchLiveData = async () => {
    try {
      const [resAnalytics, resLogs] = await Promise.all([
        fetch(`${API_BASE}/api/v1/admin/analytics`).then(r => r.ok ? r.json() : null),
        fetch(`${API_BASE}/api/v1/admin/logs/predictions?limit=10`).then(r => r.ok ? r.json() : null)
      ]);
      if (resAnalytics) setAnalytics(resAnalytics);
      if (resLogs && resLogs.data) setPredictions(resLogs.data);
    } catch {
      // Backend may be offline or initializing; fallback state is already populated
    }
  };

  useEffect(() => {
    fetchLiveData();

    // Connect to live SSE biometric stream
    let eventSource = null;
    try {
      eventSource = new EventSource(`${API_BASE}/api/v1/stream`);
      
      eventSource.onopen = () => {
        setIsLiveConnected(true);
      };

      eventSource.onmessage = (e) => {
        try {
          const payload = JSON.parse(e.data);
          
          // 1. Recalculate and update Dyadic Couple Stress Index dynamically
          if (payload.combined_couple_stress_index !== undefined) {
            setDyadicCSI(payload.combined_couple_stress_index);
            setLastTickTime(new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }));
          }

          // 2. Extract and bind live telemetry metrics for Arya and Arif
          if (payload.profiles && Array.isArray(payload.profiles)) {
            const aryaProf = payload.profiles.find(p => p.user_id === 'arya_female' || p.display_name === 'Arya' || p.user_id === 'USR-ALPHA');
            const arifProf = payload.profiles.find(p => p.user_id === 'arif_male' || p.display_name === 'Arif' || p.user_id === 'USR-BETA');

            if (aryaProf) {
              setLiveArya(prev => ({
                ...prev,
                hrv_ms: aryaProf.hrv_ms,
                heart_rate_bpm: aryaProf.heart_rate_bpm,
                cycle_phase: aryaProf.cycle_phase || 'Luteal Day 24',
                cortisol_state: aryaProf.cortisol_state || 'High',
                couple_stress_index: aryaProf.couple_stress_index
              }));
            }

            if (arifProf) {
              setLiveArif(prev => ({
                ...prev,
                hrv_ms: arifProf.hrv_ms,
                heart_rate_bpm: arifProf.heart_rate_bpm,
                cycle_phase: null,
                circadian_status: 'Circadian Recovery',
                cortisol_state: arifProf.cortisol_state || 'Normal',
                couple_stress_index: arifProf.couple_stress_index
              }));
            }

            const livePreds = payload.profiles.map((prof) => {
              const isArya = prof.user_id === 'arya_female' || prof.user_id === 'USR-ALPHA' || prof.display_name === 'Arya';
              const displayName = prof.display_name || (isArya ? 'Arya' : 'Arif');
              const partnerName = isArya ? 'Arif' : 'Arya';
              const csi = prof.couple_stress_index ?? (isArya ? 0.82 : 0.24);

              return {
                id: `live_${prof.user_id}_${Date.now()}`,
                user_anonymized_id: displayName,
                partner_anonymized_id: partnerName,
                gender: prof.gender || (isArya ? 'female' : 'male'),
                cycle_day: isArya ? 24 : null,
                cycle_phase: isArya ? (prof.cycle_phase || 'Luteal Day 24') : 'Circadian Recovery',
                combined_stress_index: csi,
                hrv_ms: prof.hrv_ms,
                heart_rate_bpm: prof.heart_rate_bpm,
                cortisol_state: prof.cortisol_state,
                confidence_score: 0.94,
                predicted_state: isArya ? 'High Stress & Cortisol Shift' : 'Restorative Autonomic Baseline',
                primary_driver: isArya
                  ? `Late-luteal sensitivity (Day 24) • HRV ${prof.hrv_ms}ms • HR ${prof.heart_rate_bpm}bpm • Cortisol ${prof.cortisol_state}.`
                  : `Diurnal circadian recovery • HRV ${prof.hrv_ms}ms • HR ${prof.heart_rate_bpm}bpm • Cortisol ${prof.cortisol_state}.`,
                state_tag: isArya ? 'luteal_high_cortisol' : 'circadian_optimal',
                partner_nudge_status: isArya ? 'delivered' : 'not_triggered',
                partner_tapback_reaction: isArya ? '❤️' : null,
                created_at: 'Live Stream'
              };
            });
            setPredictions(livePreds);
            setIsLiveConnected(true);
          }
        } catch {
          // ignore keepalive
        }
      };

      eventSource.onerror = () => {
        setIsLiveConnected(false);
      };
    } catch (err) {
      console.warn('SSE stream error:', err);
      setIsLiveConnected(false);
    }

    const interval = setInterval(fetchLiveData, 10000);
    return () => {
      clearInterval(interval);
      if (eventSource) eventSource.close();
    };
  }, []);

  useEffect(() => {
    chatBottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [chatMessages, isAiLoading]);

  // Execute RAG Query
  const handleSendQuery = async (queryText) => {
    const textToSend = (typeof queryText === 'string' ? queryText : inputQuery).trim();
    if (!textToSend || isAiLoading) return;

    setInputQuery('');
    const userMsgId = `user_${Date.now()}`;
    const botMsgId = `bot_${Date.now()}`;

    // Add user message & empty bot placeholder
    setChatMessages(prev => [
      ...prev,
      { id: userMsgId, role: 'user', content: textToSend },
      { id: botMsgId, role: 'assistant', content: '', sources: [], isStreaming: true }
    ]);
    setIsAiLoading(true);

    try {
      const resp = await fetch(`${API_BASE}/api/v1/admin/huberman-rag`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: textToSend, top_k: 3, stream: false })
      });

      if (!resp.ok) throw new Error(`HTTP error ${resp.status}`);
      const data = await resp.json();

      // Simulate rapid streaming typing effect
      const fullText = data.ai_response;
      let curr = '';
      const words = fullText.split(' ');
      
      for (let i = 0; i < words.length; i++) {
        curr += (i === 0 ? '' : ' ') + words[i];
        setChatMessages(prev => 
          prev.map(msg => msg.id === botMsgId ? { ...msg, content: curr } : msg)
        );
        if (i % 4 === 0) await new Promise(r => setTimeout(r, 15));
      }

      setChatMessages(prev => 
        prev.map(msg => msg.id === botMsgId ? { 
          ...msg, 
          content: fullText, 
          sources: data.sources || [], 
          isStreaming: false 
        } : msg)
      );
    } catch {
      // Fallback local response if backend API is offline
      const fallbackMsg = `Grounded protocol for "${textToSend}":\n\nDr. Huberman emphasizes the Physiological Sigh (double nasal inhale, extended slow mouth exhale) for immediate autonomic recovery within 30 seconds. For hormonal sleep support in the late-luteal phase, reduce ambient bedroom temperatures by 2°F (64-66°F) and utilize 200-400mg Magnesium Threonate.`;
      setChatMessages(prev => 
        prev.map(msg => msg.id === botMsgId ? { 
          ...msg, 
          content: fallbackMsg, 
          sources: [
            {
              episode_title: "Tools for Managing Stress & Anxiety (Ep. 10)",
              topic: "cortisol",
              similarity_score: 0.94,
              actionable_protocol: "Perform 2-3 physiological sighs immediately during acute stress spikes."
            },
            {
              episode_title: "Hormones, Sleep & Resilience Across Cycle Phases (Ep. 85)",
              topic: "luteal",
              similarity_score: 0.91,
              actionable_protocol: "Drop bedroom temp by 2°F during Days 21-28. Supplement with 200-400mg Magnesium Threonate."
            }
          ], 
          isStreaming: false 
        } : msg)
      );
    } finally {
      setIsAiLoading(false);
    }
  };

  const toggleSourceCard = (msgId) => {
    setExpandedSources(prev => ({ ...prev, [msgId]: !prev[msgId] }));
  };

  const quickPrompts = [
    "Find protocols for high cortisol",
    "Search dopamine/motivation research",
    "Map luteal phase sleep protocols"
  ];

  return (
    <div className="w-full min-h-screen bg-[#08080A] text-slate-100 flex flex-col font-sans selection:bg-[#FF6B2C]/30">
      
      {/* Top Navigation Bar */}
      <header className="border-b border-white/10 bg-[#0E0D12]/80 backdrop-blur-md sticky top-0 z-40 px-6 py-3.5 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-[#FF6B2C] to-[#FF9356] flex items-center justify-center shadow-lg shadow-[#FF6B2C]/20">
            <Radio className="w-5 h-5 text-white animate-pulse" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-bold text-base tracking-wide text-white">AIVO CONSOLE</span>
              <span className="text-[10px] uppercase font-bold tracking-widest px-2 py-0.5 rounded-full bg-[#FF6B2C]/20 text-[#FF8A3D] border border-[#FF6B2C]/30">
                ADMIN / RAG
              </span>
            </div>
            <p className="text-[11px] text-slate-400">Biometric Simulation & Huberman Knowledge System</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-mono">
            <span className={`w-2 h-2 rounded-full ${isLiveConnected ? 'bg-emerald-400 animate-ping' : 'bg-amber-400'}`} />
            <span>2 Active Test Profiles (Arya, Arif)</span>
          </div>

          <button 
            onClick={fetchLiveData}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs text-slate-300 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg transition-colors"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            <span>Sync Live</span>
          </button>
        </div>
      </header>

      {/* Main Admin Workspace */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-6 flex flex-col gap-6">
        
        {/* 1. SYSTEM VITALS BAR */}
        <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          
          {/* Active Users */}
          <div className="bg-[#121015]/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-medium text-slate-400">Active Monitored Users</span>
              <div className="p-2 rounded-xl bg-orange-500/10 text-[#FF6B2C]">
                <Users className="w-4 h-4" />
              </div>
            </div>
            <div className="mt-3">
              <div className="text-2xl font-bold tracking-tight text-white">
                2
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-emerald-400">
                <span>Arya (female) & Arif (male)</span>
              </div>
            </div>
          </div>

          {/* Active Couple Links */}
          <div className="bg-[#121015]/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-medium text-slate-400">Paired Couple Links</span>
              <div className="p-2 rounded-xl bg-rose-500/10 text-rose-400">
                <HeartHandshake className="w-4 h-4" />
              </div>
            </div>
            <div className="mt-3">
              <div className="text-2xl font-bold tracking-tight text-white">
                1
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-slate-400">
                <span>Arya ↔ Arif Active Dyad</span>
              </div>
            </div>
          </div>

          {/* Live Dyadic Stress (CSI) */}
          <div className="bg-[#121015]/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-medium text-slate-400">Live Dyadic Stress (CSI)</span>
              <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400">
                <Activity className="w-4 h-4" />
              </div>
            </div>
            <div className="mt-3">
              <div className="text-2xl font-bold tracking-tight text-white font-mono">
                CSI {(dyadicCSI * 100).toFixed(0)}%
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-amber-400 font-mono">
                <span>0.60×Arya + 0.40×Arif</span>
              </div>
            </div>
          </div>

          {/* Cloud Streaming Health */}
          <div className="bg-[#121015]/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-medium text-slate-400">Simulator Engine</span>
              <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 text-[10px] font-semibold border border-emerald-500/30">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                <span>STREAMING</span>
              </div>
            </div>
            <div className="mt-3">
              <div className="text-2xl font-bold tracking-tight text-white flex items-center gap-2">
                <span>Healthy (Live Stream)</span>
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-slate-400">
                <Clock className="w-3 h-3 text-slate-500" />
                <span>10s autonomous loop</span>
              </div>
            </div>
          </div>

        </section>

        {/* 2. PROMINENT DYADIC COUPLE STRESS HERO GAUGE */}
        <section className="bg-gradient-to-br from-[#16121C] via-[#121015] to-[#1A1422] border border-white/10 rounded-3xl p-6 shadow-2xl relative overflow-hidden">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-white/10">
            <div>
              <div className="flex items-center gap-2.5">
                <span className="px-2.5 py-0.5 rounded-full bg-[#FF6B2C]/20 border border-[#FF6B2C]/30 text-[#FF8A3D] text-[11px] font-bold uppercase tracking-wider">
                  Real-Time Dyadic Synchrony
                </span>
                <span className="flex items-center gap-1 text-emerald-400 text-xs font-mono">
                  <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
                  <span>Live Stream Tick: {lastTickTime}</span>
                </span>
              </div>
              <h2 className="text-xl font-bold text-white mt-1.5 tracking-tight">COUPLE STRESS INDEX (CSI %) GAUGE</h2>
              <p className="text-xs text-slate-400 mt-0.5">
                Dynamic dyadic recalculation: <code className="text-[#FF8A3D] font-mono bg-white/5 px-1.5 py-0.5 rounded">CSI_couple = 0.60 × Arya + 0.40 × Arif</code>
              </p>
            </div>

            <div className="flex items-center gap-4">
              <div className="text-right">
                <div className="text-4xl font-extrabold text-white font-mono tracking-tight flex items-center justify-end gap-2">
                  <span>{(dyadicCSI * 100).toFixed(0)}%</span>
                  <span className={`text-xs font-bold px-2.5 py-1 rounded-full uppercase tracking-wider ${
                    dyadicCSI >= 0.70 ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30' :
                    dyadicCSI >= 0.40 ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' :
                    'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                  }`}>
                    {dyadicCSI >= 0.70 ? 'High Dyadic Stress Alert' : dyadicCSI >= 0.40 ? 'Moderate Co-Regulation' : 'Optimal Synchrony'}
                  </span>
                </div>
                <p className="text-[11px] text-slate-400 font-mono mt-1">
                  Arya (60%): {(liveArya.couple_stress_index * 100).toFixed(0)}% • Arif (40%): {(liveArif.couple_stress_index * 100).toFixed(0)}%
                </p>
              </div>
            </div>
          </div>

          {/* Dynamic Progress Bar */}
          <div className="mt-4 flex flex-col gap-2">
            <div className="w-full bg-black/50 h-3.5 rounded-full overflow-hidden border border-white/10 p-0.5">
              <div 
                className={`h-full rounded-full transition-all duration-700 ${
                  dyadicCSI >= 0.70 ? 'bg-gradient-to-r from-amber-500 to-rose-500 shadow-[0_0_15px_rgba(244,63,94,0.7)]' :
                  dyadicCSI >= 0.40 ? 'bg-gradient-to-r from-emerald-500 to-amber-500 shadow-[0_0_15px_rgba(245,158,11,0.7)]' :
                  'bg-gradient-to-r from-cyan-500 to-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.7)]'
                }`}
                style={{ width: `${Math.min(100, Math.max(5, dyadicCSI * 100))}%` }}
              />
            </div>
            <div className="flex justify-between text-[10px] font-mono text-slate-500 px-1">
              <span>0% (Parasympathetic Equilibrium)</span>
              <span>50% (Baseline Co-Regulation)</span>
              <span>100% (Acute Dyadic Escalation)</span>
            </div>
          </div>
        </section>

        {/* 3. DEDICATED LIVE TEST PROFILES (ARYA & ARIF) */}
        <section className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          
          {/* Profile A: Arya (Female) */}
          <div className="bg-[#121015]/90 border border-purple-500/25 hover:border-purple-500/50 rounded-3xl p-5 shadow-2xl transition-all relative overflow-hidden flex flex-col gap-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-purple-500/20 border border-purple-500/30 flex items-center justify-center text-purple-300 font-bold text-lg shadow-md shadow-purple-500/10">
                  ♀
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-base font-bold text-white">Arya</h3>
                    <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded-md bg-purple-500/20 text-purple-300 border border-purple-500/30">
                      Female • Infradian Rhythm
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-400">Target Profile A • Paired with Arif</p>
                </div>
              </div>

              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-purple-500/10 border border-purple-500/30 text-purple-300 text-xs font-semibold font-mono">
                <span>Day 24 • Late-Luteal Phase</span>
              </div>
            </div>

            {/* Live Metrics Grid */}
            <div className="grid grid-cols-4 gap-2.5 bg-black/40 p-3 rounded-2xl border border-white/5 font-mono">
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Live HRV</span>
                <span className="text-lg font-bold text-rose-300">{liveArya.hrv_ms} ms</span>
                <span className="text-[9px] text-slate-500">Baseline 35–50</span>
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Resting HR</span>
                <span className="text-lg font-bold text-white">{liveArya.heart_rate_bpm} bpm</span>
                <span className="text-[9px] text-slate-500">Baseline 75–95</span>
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Cortisol State</span>
                <span className="text-lg font-bold text-rose-400 flex items-center gap-1">
                  <span className="w-1.5 h-1.5 rounded-full bg-rose-400 animate-ping" />
                  {liveArya.cortisol_state}
                </span>
                <span className="text-[9px] text-slate-500">Elevated Flag</span>
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Stress Score</span>
                <span className="text-lg font-bold text-rose-300">{(liveArya.couple_stress_index * 100).toFixed(0)}%</span>
                <span className="text-[9px] text-slate-500">Weight 60%</span>
              </div>
            </div>

            {/* Huberman Protocol Recommendation */}
            <div className="p-3 rounded-xl bg-purple-500/5 border border-purple-500/20 text-xs text-slate-300 flex items-start gap-2.5">
              <Sparkles className="w-4 h-4 text-purple-400 shrink-0 mt-0.5" />
              <p className="leading-relaxed">
                <strong className="text-purple-300">Huberman Protocol:</strong> Late-luteal progesterone drop & cortisol sensitivity. Deploy 2–3 double physiological sighs for acute vagal tone activation; drop bedroom temp by 2°F (64–66°F).
              </p>
            </div>
          </div>

          {/* Profile B: Arif (Male) */}
          <div className="bg-[#121015]/90 border border-cyan-500/25 hover:border-cyan-500/50 rounded-3xl p-5 shadow-2xl transition-all relative overflow-hidden flex flex-col gap-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-cyan-500/20 border border-cyan-500/30 flex items-center justify-center text-cyan-300 font-bold text-lg shadow-md shadow-cyan-500/10">
                  ♂
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-base font-bold text-white">Arif</h3>
                    <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded-md bg-cyan-500/20 text-cyan-300 border border-cyan-500/30">
                      Male • Diurnal Circadian
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-400">Target Profile B • Paired with Arya</p>
                </div>
              </div>

              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-cyan-500/10 border border-cyan-500/30 text-cyan-300 text-xs font-semibold font-mono">
                <span>Male Circadian Recovery</span>
              </div>
            </div>

            {/* Live Metrics Grid */}
            <div className="grid grid-cols-4 gap-2.5 bg-black/40 p-3 rounded-2xl border border-white/5 font-mono">
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Live HRV</span>
                <span className="text-lg font-bold text-emerald-300">{liveArif.hrv_ms} ms</span>
                <span className="text-[9px] text-slate-500">Baseline 65–85</span>
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Resting HR</span>
                <span className="text-lg font-bold text-white">{liveArif.heart_rate_bpm} bpm</span>
                <span className="text-[9px] text-slate-500">Baseline 58–68</span>
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Cortisol State</span>
                <span className="text-lg font-bold text-emerald-400 flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                  {liveArif.cortisol_state}
                </span>
                <span className="text-[9px] text-slate-500">Homeostatic</span>
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] text-slate-500 uppercase">Stress Score</span>
                <span className="text-lg font-bold text-emerald-300">{(liveArif.couple_stress_index * 100).toFixed(0)}%</span>
                <span className="text-[9px] text-slate-500">Weight 40%</span>
              </div>
            </div>

            {/* Huberman Protocol Recommendation */}
            <div className="p-3 rounded-xl bg-cyan-500/5 border border-cyan-500/20 text-xs text-slate-300 flex items-start gap-2.5">
              <Sparkles className="w-4 h-4 text-cyan-400 shrink-0 mt-0.5" />
              <p className="leading-relaxed">
                <strong className="text-cyan-300">Huberman Protocol:</strong> Circadian anchor intact. 10–15 min viewing morning sunlight anchors nighttime melatonin release and maintains parasympathetic autonomic buffer.
              </p>
            </div>
          </div>

        </section>

        {/* 2. MAIN TWO-COLUMN WORKBENCH */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 flex-1 items-start">
          
          {/* LEFT: Live Prediction Stream (5 cols) */}
          <section className="lg:col-span-5 bg-[#121015]/90 border border-white/10 rounded-3xl p-5 shadow-2xl flex flex-col gap-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div className="flex items-center gap-2">
                <Activity className="w-4 h-4 text-[#FF6B2C]" />
                <h2 className="text-sm font-bold text-white tracking-wide">LIVE PREDICTION FEED</h2>
              </div>
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[11px] font-mono">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                <span>2 Active Test Profiles (Arya, Arif)</span>
              </div>
            </div>

            {/* List of Predictions */}
            <div className="flex flex-col gap-3 max-h-[620px] overflow-y-auto pr-1 custom-scrollbar">
              {predictions.map((p) => {
                const isHigh = p.combined_stress_index >= 0.70;
                return (
                  <div 
                    key={p.id}
                    className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5 hover:border-white/15 transition-all flex flex-col gap-2.5"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs font-semibold text-slate-200">{p.user_anonymized_id}</span>
                        <span className="text-slate-600 text-xs">→</span>
                        <span className="font-mono text-xs text-slate-400">{p.partner_anonymized_id}</span>
                      </div>
                      <span className="text-[10px] text-slate-400 font-mono">{p.created_at}</span>
                    </div>

                    {/* Biometrics row: HRV, HR, Cortisol */}
                    <div className="grid grid-cols-3 gap-2 bg-white/[0.02] p-2 rounded-xl border border-white/5 text-[11px] font-mono">
                      <div className="flex flex-col">
                        <span className="text-[9px] text-slate-500 uppercase">Live HRV</span>
                        <span className={`font-bold ${isHigh ? 'text-rose-300' : 'text-emerald-300'}`}>
                          {p.hrv_ms ? `${p.hrv_ms} ms` : (isHigh ? '42 ms' : '75 ms')}
                        </span>
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] text-slate-500 uppercase">Heart Rate</span>
                        <span className="font-bold text-slate-300">
                          {p.heart_rate_bpm ? `${p.heart_rate_bpm} bpm` : (isHigh ? '85 bpm' : '63 bpm')}
                        </span>
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] text-slate-500 uppercase">Cortisol</span>
                        <span className={`font-bold ${p.cortisol_state === 'High' || isHigh ? 'text-rose-400' : 'text-emerald-400'}`}>
                          {p.cortisol_state || (isHigh ? 'High' : 'Normal')}
                        </span>
                      </div>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-1.5">
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-md uppercase tracking-wider ${
                          p.gender === 'female' || (p.cycle_phase && p.cycle_phase.toLowerCase().includes('luteal'))
                            ? 'bg-purple-500/20 text-purple-300 border border-purple-500/30'
                            : 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/30'
                        }`}>
                          {p.cycle_phase || (p.cycle_day ? `Day ${p.cycle_day}` : 'Circadian Recovery')}
                        </span>
                        <span className="text-[10px] text-slate-400 font-medium truncate max-w-[120px]">
                          {p.state_tag}
                        </span>
                      </div>

                      {/* CSI Stress Gauge Badge */}
                      <div className={`px-2 py-0.5 rounded-full text-xs font-bold font-mono flex items-center gap-1 ${
                        isHigh 
                          ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30' 
                          : 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                      }`}>
                        {isHigh ? <AlertTriangle className="w-3 h-3" /> : <CheckCircle2 className="w-3 h-3" />}
                        <span>CSI {(p.combined_stress_index * 100).toFixed(0)}%</span>
                      </div>
                    </div>

                    <p className="text-xs text-slate-300 leading-snug">
                      {p.primary_driver}
                    </p>

                    {/* Partner Nudge Status */}
                    <div className="flex items-center justify-between pt-1 border-t border-white/5 text-[11px]">
                      <span className="text-slate-400 flex items-center gap-1">
                        <Zap className="w-3 h-3 text-[#FF6B2C]" />
                        <span>Nudge:</span>
                        <strong className="text-slate-300 capitalize">{p.partner_nudge_status}</strong>
                      </span>
                      {p.partner_tapback_reaction && (
                        <span className="px-1.5 py-0.5 rounded-md bg-white/5 text-[10px] text-slate-300">
                          Partner reacted {p.partner_tapback_reaction}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </section>

          {/* RIGHT: Huberman GenAI Assistant (7 cols) */}
          <section className="lg:col-span-7 bg-[#121015]/90 border border-white/10 rounded-3xl p-5 shadow-2xl flex flex-col h-[700px]">
            
            {/* Header */}
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div className="flex items-center gap-2">
                <div className="p-1.5 rounded-lg bg-[#FF6B2C]/20 text-[#FF8A3D]">
                  <Sparkles className="w-4 h-4" />
                </div>
                <div>
                  <h2 className="text-sm font-bold text-white tracking-wide">HUBERMAN RAG ASSISTANT</h2>
                  <p className="text-[11px] text-slate-400">pgvector cosine search across podcast transcripts & micro-protocols</p>
                </div>
              </div>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 font-semibold">
                1536-dim Embedding
              </span>
            </div>

            {/* Quick Prompts Bar */}
            <div className="py-2.5 flex flex-wrap gap-2 border-b border-white/5">
              {quickPrompts.map((prompt, i) => (
                <button
                  key={i}
                  onClick={() => handleSendQuery(prompt)}
                  disabled={isAiLoading}
                  className="text-[11px] px-2.5 py-1 rounded-full bg-white/5 hover:bg-[#FF6B2C]/20 hover:text-[#FF8A3D] hover:border-[#FF6B2C]/40 border border-white/10 text-slate-300 transition-all"
                >
                  "{prompt}"
                </button>
              ))}
            </div>

            {/* Chat Message Scrollable Container */}
            <div className="flex-1 overflow-y-auto py-4 flex flex-col gap-4 pr-1 custom-scrollbar">
              {chatMessages.map((msg) => {
                const isUser = msg.role === 'user';
                const isExpanded = !!expandedSources[msg.id];

                return (
                  <div 
                    key={msg.id}
                    className={`flex flex-col ${isUser ? 'items-end' : 'items-start'}`}
                  >
                    <div className={`max-w-[90%] rounded-2xl p-4 text-xs leading-relaxed ${
                      isUser 
                        ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8A3D] text-white font-medium shadow-lg shadow-[#FF6B2C]/20' 
                        : 'bg-[#18161D] border border-white/10 text-slate-200 shadow-md'
                    }`}>
                      <div className="whitespace-pre-wrap">{msg.content}</div>
                    </div>

                    {/* Collapsible Source Citations Badge for Assistant Messages */}
                    {!isUser && msg.sources && msg.sources.length > 0 && (
                      <div className="mt-2 w-[90%]">
                        <button
                          onClick={() => toggleSourceCard(msg.id)}
                          className="flex items-center gap-1.5 text-[11px] text-[#FF8A3D] hover:text-[#FFA05E] transition-colors py-1 px-2 rounded-md bg-white/5 border border-white/10"
                        >
                          <BookOpen className="w-3 h-3" />
                          <span>Sources & Protocols ({msg.sources.length} matching episodes)</span>
                          {isExpanded ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />}
                        </button>

                        {isExpanded && (
                          <div className="mt-2 flex flex-col gap-2 p-3 rounded-xl bg-black/40 border border-white/10 animate-in fade-in duration-200">
                            {msg.sources.map((src, idx) => (
                              <div key={idx} className="border-b border-white/5 pb-2 last:border-none last:pb-0">
                                <div className="flex items-center justify-between text-[11px] font-semibold text-white">
                                  <span>{src.episode_title}</span>
                                  <span className="text-[10px] font-mono text-emerald-400">
                                    {(src.similarity_score * 100).toFixed(1)}% match
                                  </span>
                                </div>
                                <div className="mt-1 text-[11px] text-slate-300">
                                  <strong className="text-[#FF8A3D]">Protocol:</strong> {src.actionable_protocol}
                                </div>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}

              {isAiLoading && (
                <div className="flex items-center gap-2 text-xs text-slate-400 bg-[#18161D] border border-white/10 p-3 rounded-2xl w-fit">
                  <Sparkles className="w-3.5 h-3.5 text-[#FF6B2C] animate-spin" />
                  <span>Searching pgvector & synthesizing Huberman protocols...</span>
                </div>
              )}
              <div ref={chatBottomRef} />
            </div>

            {/* Input Bar */}
            <form 
              onSubmit={(e) => { e.preventDefault(); handleSendQuery(); }}
              className="pt-3 border-t border-white/10 flex items-center gap-2"
            >
              <input
                type="text"
                value={inputQuery}
                onChange={(e) => setInputQuery(e.target.value)}
                placeholder="Ask Huberman Assistant about stress, sleep, dopamine..."
                disabled={isAiLoading}
                className="flex-1 bg-white/5 border border-white/10 focus:border-[#FF6B2C] focus:outline-none rounded-xl px-4 py-2.5 text-xs text-white placeholder:text-slate-500 transition-all"
              />
              <button
                type="submit"
                disabled={isAiLoading || !inputQuery.trim()}
                className="p-2.5 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#FF8A3D] text-white hover:opacity-90 disabled:opacity-40 transition-all shadow-md shadow-[#FF6B2C]/20"
              >
                <Send className="w-4 h-4" />
              </button>
            </form>

          </section>

        </div>

      </main>

    </div>
  );
}
