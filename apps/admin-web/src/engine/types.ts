export type CyclePhase = 'menstrual' | 'follicular' | 'ovulatory' | 'luteal';

export interface User {
  id: string;
  name: string;
  partnerId?: string;
  cycleStartDate: Date;
  averageCycleLength: number; // default 28
}

export interface DailyCheckin {
  userId: string;
  date: Date;
  moodScore: number;    // 1 - 10
  stressScore: number;  // 1 - 10
  energyLevel: number;  // 1 - 10
  sleepHours: number;
}

export interface WearableData {
  hrv: number;            // ms
  restingHR: number;      // bpm
  deepSleepRatio: number; // 0.0 - 1.0
}

export interface PredictionResult {
  userId: string;
  date: Date;
  predictedState: string;     // e.g. "High Stress / High Cortisol State"
  confidenceScore: number;    // 0.0 to 1.0
  primaryDriver: string;      // e.g. "Late Luteal Cortisol Spike + 3-day Sleep Debt"
  suggestedActionTag: string; // maps to guided content
  cyclePhase: CyclePhase;
  cycleDay: number;
  combinedStressIndex: number;
  rollingStressAvg: number;
  rollingMoodAvg: number;
  rollingSleepAvg: number;
}

export interface PartnerNudge {
  senderId: string;
  recipientId: string;
  message: string;
  suggestedSupport: string;
  timestamp: Date;
  isHelpful?: boolean;
}
