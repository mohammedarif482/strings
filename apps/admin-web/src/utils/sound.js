// Ambient Audio Synthesizer for Aivo Wellness Guided Sessions
let audioCtx = null;
let activeOscillators = [];
let gainNode = null;

function getAudioContext() {
  if (!audioCtx) {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (AudioContextClass) {
      audioCtx = new AudioContextClass();
    }
  }
  if (audioCtx && audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

export function playAmbientDrone(play = true) {
  const ctx = getAudioContext();
  if (!ctx) return;

  if (!play) {
    if (gainNode) {
      gainNode.gain.setTargetAtTime(0.0001, ctx.currentTime, 0.5);
      setTimeout(() => {
        activeOscillators.forEach(osc => {
          try { osc.stop(); osc.disconnect(); } catch (e) {}
        });
        activeOscillators = [];
      }, 600);
    }
    return;
  }

  // Clear previous
  activeOscillators.forEach(osc => {
    try { osc.stop(); osc.disconnect(); } catch (e) {}
  });
  activeOscillators = [];

  // Create warm 432Hz / 528Hz calming drone chord
  gainNode = ctx.createGain();
  gainNode.gain.setValueAtTime(0.001, ctx.currentTime);
  gainNode.gain.exponentialRampToValueAtTime(0.08, ctx.currentTime + 1.5);
  gainNode.connect(ctx.destination);

  // Frequencies: root 216Hz, 432Hz harmonic, 528Hz love frequency, 108Hz sub-bass
  const freqs = [108, 216, 432, 528];
  freqs.forEach(freq => {
    const osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, ctx.currentTime);

    // Subtle gentle vibrato LFO
    const lfo = ctx.createOscillator();
    const lfoGain = ctx.createGain();
    lfo.frequency.value = 0.2; // 0.2 Hz slow breath cycle
    lfoGain.gain.value = 1.2;
    lfo.connect(osc.frequency);
    lfo.start();

    osc.connect(gainNode);
    osc.start();
    activeOscillators.push(osc, lfo);
  });
}

export function playHapticChime(type = 'tap') {
  const ctx = getAudioContext();
  if (!ctx) return;

  const osc = ctx.createOscillator();
  const chimeGain = ctx.createGain();

  chimeGain.connect(ctx.destination);
  osc.connect(chimeGain);

  const now = ctx.currentTime;
  if (type === 'nudge') {
    osc.type = 'sine';
    osc.frequency.setValueAtTime(587.33, now); // D5
    osc.frequency.exponentialRampToValueAtTime(880, now + 0.3); // A5
    chimeGain.gain.setValueAtTime(0.12, now);
    chimeGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.8);
    osc.start(now);
    osc.stop(now + 0.85);
  } else if (type === 'pulse') {
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(329.63, now); // E4
    chimeGain.gain.setValueAtTime(0.08, now);
    chimeGain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
    osc.start(now);
    osc.stop(now + 0.45);
  } else {
    // gentle click
    osc.type = 'sine';
    osc.frequency.setValueAtTime(659.25, now);
    chimeGain.gain.setValueAtTime(0.05, now);
    chimeGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.15);
    osc.start(now);
    osc.stop(now + 0.16);
  }
}
