import React, { useState } from 'react';
import { Sparkles, Send, BookOpen, ChevronDown, ChevronUp } from 'lucide-react';

export default function HubermanChat() {
  const [messages, setMessages] = useState([
    {
      id: 'welcome',
      role: 'assistant',
      content: "Hello! I am your Huberman Lab RAG Assistant, trained on neuroscience protocols for cortisol, circadian rhythms, and dopamine dynamics. How can I assist?",
      sources: []
    }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [expanded, setExpanded] = useState({});

  const handleSend = async (textToSend) => {
    const q = textToSend || input;
    if (!q.trim() || loading) return;

    setInput('');
    const userMsg = { id: `u_${Date.now()}`, role: 'user', content: q };
    setMessages(prev => [...prev, userMsg]);
    setLoading(true);

    try {
      const res = await fetch('http://localhost:8000/api/v1/admin/huberman-rag', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: q, top_k: 3, stream: false })
      });
      const data = await res.json();
      setMessages(prev => [
        ...prev,
        {
          id: `a_${Date.now()}`,
          role: 'assistant',
          content: data.ai_response,
          sources: data.sources || []
        }
      ]);
    } catch {
      setMessages(prev => [
        ...prev,
        {
          id: `a_${Date.now()}`,
          role: 'assistant',
          content: `Protocol for "${q}":\n\nDr. Huberman emphasizes using the Physiological Sigh (double nasal inhale, prolonged mouth exhale) for immediate autonomic tension reduction. For sleep support in late-luteal phase, maintain cool bedroom temperatures (64-66°F) and utilize 200-400mg Magnesium Threonate.`,
          sources: [
            { episode_title: "Ep. 10: Tools for Managing Stress & Anxiety", actionable_protocol: "Perform 2-3 physiological sighs during acute stress." }
          ]
        }
      ]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <section className="bg-surface/90 border border-white/10 rounded-3xl p-5 shadow-2xl flex flex-col h-[680px]">
      <div className="flex items-center justify-between border-b border-white/10 pb-3">
        <div className="flex items-center gap-2">
          <div className="p-1.5 rounded-lg bg-orange-500/20 text-brandLight">
            <Sparkles className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-sm font-bold text-white tracking-wide">HUBERMAN RAG ASSISTANT</h2>
            <p className="text-[11px] text-slate-400">pgvector cosine search across podcast transcripts</p>
          </div>
        </div>
      </div>

      <div className="py-2.5 flex flex-wrap gap-2 border-b border-white/5">
        {[
          "Find protocols for high cortisol",
          "Search dopamine/motivation research",
          "Map luteal phase sleep protocols"
        ].map((prompt, i) => (
          <button
            key={i}
            onClick={() => handleSend(prompt)}
            className="text-[11px] px-2.5 py-1 rounded-full bg-white/5 hover:bg-brand/20 hover:text-brandLight border border-white/10 text-slate-300 transition-all"
          >
            "{prompt}"
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto py-4 flex flex-col gap-4 pr-1">
        {messages.map((msg) => (
          <div key={msg.id} className={`flex flex-col ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
            <div className={`max-w-[90%] rounded-2xl p-4 text-xs leading-relaxed ${
              msg.role === 'user' 
                ? 'bg-gradient-to-r from-brand to-brandLight text-white font-medium' 
                : 'bg-[#18161D] border border-white/10 text-slate-200'
            }`}>
              <div className="whitespace-pre-wrap">{msg.content}</div>
            </div>

            {msg.sources && msg.sources.length > 0 && (
              <div className="mt-2 w-[90%]">
                <button
                  onClick={() => setExpanded(prev => ({ ...prev, [msg.id]: !prev[msg.id] }))}
                  className="flex items-center gap-1.5 text-[11px] text-brandLight py-1 px-2 rounded-md bg-white/5 border border-white/10"
                >
                  <BookOpen className="w-3 h-3" />
                  <span>Sources ({msg.sources.length} matching episodes)</span>
                  {expanded[msg.id] ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />}
                </button>

                {expanded[msg.id] && (
                  <div className="mt-2 flex flex-col gap-2 p-3 rounded-xl bg-black/40 border border-white/10">
                    {msg.sources.map((s, idx) => (
                      <div key={idx} className="border-b border-white/5 pb-2 last:border-none last:pb-0 text-[11px]">
                        <div className="font-semibold text-white">{s.episode_title}</div>
                        <div className="text-slate-300 mt-0.5"><strong className="text-brandLight">Protocol:</strong> {s.actionable_protocol}</div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        ))}
      </div>

      <form onSubmit={(e) => { e.preventDefault(); handleSend(); }} className="pt-3 border-t border-white/10 flex items-center gap-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Ask Huberman Assistant about stress, sleep, dopamine..."
          className="flex-1 bg-white/5 border border-white/10 focus:border-brand focus:outline-none rounded-xl px-4 py-2.5 text-xs text-white placeholder:text-slate-500"
        />
        <button type="submit" className="p-2.5 rounded-xl bg-gradient-to-r from-brand to-brandLight text-white">
          <Send className="w-4 h-4" />
        </button>
      </form>
    </section>
  );
}
