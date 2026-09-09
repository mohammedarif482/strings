import React, { useState, useEffect, useRef } from 'react';
import { 
  Activity, Users, HeartHandshake, ShieldCheck, Sparkles, 
  Send, RefreshCw, ChevronDown, ChevronUp, BookOpen, Clock, 
  AlertTriangle, CheckCircle2, ArrowUpRight, Zap, Radio
} from 'lucide-react';

const API_BASE = (typeof process !== 'undefined' && process.env?.NEXT_PUBLIC_API_URL) || 'https://strings-api.onrender.com';

export default function AdminDashboard({ onBackToSimulator }) {
  // --- State ---
  const [analytics, setAnalytics] = useState({
    active_users: 1420,
    paired_couples: 680,
    total_daily_predictions: 3842,
    nudge_helpful_rate: 89.4,
    cloud_simulator_health: {
      status: 'healthy',
      streaming_active: true,
      mean_pipeline_latency_ms: 15.7,
      cycle_interval_minutes: 15
    }
  });

  const [predictions, setPredictions] = useState([
    {
      id: 'pred_0991',
      user_anonymized_id: 'USR-8192',
      partner_anonymized_id: 'USR-4011',
      cycle_day: 24,
      cycle_phase: 'luteal',
      combined_stress_index: 0.88,
      confidence_score: 0.94,
      predicted_state: 'High Stress & Cortisol Shift',
      primary_driver: 'Late-luteal cortisol sensitivity + 5.2h sleep debt.',
      state_tag: 'luteal_high_cortisol',
      partner_nudge_status: 'delivered',
      partner_tapback_reaction: '❤️',
      created_at: 'Just now'
    },
    {
      id: 'pred_0990',
      user_anonymized_id: 'USR-3104',
      partner_anonymized_id: 'USR-9921',
      cycle_day: 9,
      cycle_phase: 'follicular',
      combined_stress_index: 0.24,
      confidence_score: 0.91,
      predicted_state: 'Peak Resilience & Focus',
      primary_driver: 'Balanced baseline, steady HRV (72ms), 8.1h sleep.',
      state_tag: 'follicular_peak',
      partner_nudge_status: 'not_triggered',
      partner_tapback_reaction: null,
      created_at: '2m ago'
    },
    {
      id: 'pred_0989',
      user_anonymized_id: 'USR-5520',
      partner_anonymized_id: 'USR-1149',
      cycle_day: 23,
      cycle_phase: 'luteal',
      combined_stress_index: 0.74,
      confidence_score: 0.88,
      predicted_state: 'High Stress & Cortisol Shift',
      primary_driver: 'Elevated sympathetic tone and 2-day sleep deficit.',
      state_tag: 'luteal_high_cortisol',
      partner_nudge_status: 'delivered',
      partner_tapback_reaction: '🙏',
      created_at: '7m ago'
    },
    {
      id: 'pred_0988',
      user_anonymized_id: 'USR-7731',
      partner_anonymized_id: 'USR-2280',
      cycle_day: 14,
      cycle_phase: 'ovulatory',
      combined_stress_index: 0.38,
      confidence_score: 0.89,
      predicted_state: 'Elevated Social Energy',
      primary_driver: 'Ovulatory estrogen peak with deep sleep ratio (24%).',
      state_tag: 'follicular_peak',
      partner_nudge_status: 'not_triggered',
      partner_tapback_reaction: null,
      created_at: '12m ago'
    },
    {
      id: 'pred_0987',
      user_anonymized_id: 'USR-6419',
      partner_anonymized_id: 'USR-8832',
      cycle_day: 26,
      cycle_phase: 'luteal',
      combined_stress_index: 0.92,
      confidence_score: 0.96,
      predicted_state: 'High Stress & Cortisol Shift',
      primary_driver: 'Late-luteal progesterone drop + RHR elevation (+7 bpm).',
      state_tag: 'luteal_high_cortisol',
      partner_nudge_status: 'delivered',
      partner_tapback_reaction: '❤️',
      created_at: '15m ago'
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
    const interval = setInterval(fetchLiveData, 15000);
    return () => clearInterval(interval);
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
          <button 
            onClick={fetchLiveData}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs text-slate-300 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg transition-colors"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            <span>Sync Live</span>
          </button>

          <button 
            onClick={onBackToSimulator}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-gradient-to-r from-[#FF6B2C] to-[#FF8A3D] hover:opacity-90 rounded-lg shadow-md shadow-[#FF6B2C]/20 transition-all"
          >
            <span>Switch to App Simulator</span>
            <ArrowUpRight className="w-3.5 h-3.5" />
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
                {analytics.active_users.toLocaleString()}
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-emerald-400">
                <span>↗ +8.2%</span>
                <span className="text-slate-500">simulated telemetry</span>
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
                {analytics.paired_couples.toLocaleString()}
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-slate-400">
                <span>680 / 710 target links active</span>
              </div>
            </div>
          </div>

          {/* AI Nudge Accuracy */}
          <div className="bg-[#121015]/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-medium text-slate-400">Nudge Helpful Rate</span>
              <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-400">
                <ShieldCheck className="w-4 h-4" />
              </div>
            </div>
            <div className="mt-3">
              <div className="text-2xl font-bold tracking-tight text-white">
                {analytics.nudge_helpful_rate}%
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-emerald-400">
                <span>512 positive / 573 total feedback</span>
              </div>
            </div>
          </div>

          {/* Cloud Streaming Health */}
          <div className="bg-[#121015]/90 border border-white/10 rounded-2xl p-4 flex flex-col justify-between shadow-xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all">
            <div className="flex items-center justify-between">
              <span className="text-xs font-medium text-slate-400">Cloud Simulator Engine</span>
              <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 text-[10px] font-semibold border border-emerald-500/30">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                <span>STREAMING</span>
              </div>
            </div>
            <div className="mt-3">
              <div className="text-2xl font-bold tracking-tight text-white flex items-center gap-2">
                <span>{analytics.cloud_simulator_health.mean_pipeline_latency_ms} ms</span>
                <span className="text-xs font-normal text-slate-400">p95</span>
              </div>
              <div className="flex items-center gap-1 mt-1 text-[11px] text-slate-400">
                <Clock className="w-3 h-3 text-slate-500" />
                <span>15-min autonomous cron loop</span>
              </div>
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
              <span className="text-[11px] text-slate-500 font-mono">1,000 devices simulated</span>
            </div>

            {/* List of Predictions */}
            <div className="flex flex-col gap-3 max-h-[620px] overflow-y-auto pr-1 custom-scrollbar">
              {predictions.map((p) => {
                const isHigh = p.combined_stress_index >= 0.70;
                return (
                  <div 
                    key={p.id}
                    className="p-3.5 rounded-2xl bg-white/[0.03] border border-white/5 hover:border-white/15 transition-all flex flex-col gap-2"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs font-semibold text-slate-300">{p.user_anonymized_id}</span>
                        <span className="text-slate-600 text-xs">→</span>
                        <span className="font-mono text-xs text-slate-400">{p.partner_anonymized_id}</span>
                      </div>
                      <span className="text-[10px] text-slate-500">{p.created_at}</span>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-1.5">
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-md uppercase tracking-wider ${
                          p.cycle_phase === 'luteal' ? 'bg-purple-500/20 text-purple-300 border border-purple-500/30' : 'bg-blue-500/20 text-blue-300 border border-blue-500/30'
                        }`}>
                          Day {p.cycle_day} • {p.cycle_phase}
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
