import '../models/content_entry.dart';

const List<ContentEntry> contentSeedLibrary = [
  // 1. Luteal Phase High Cortisol / High Stress
  ContentEntry(
    id: 'cnt_01',
    stateTag: 'luteal_high_cortisol',
    phaseApplicability: ['luteal'],
    title: 'Reset Your Mind',
    paraphrasedSummary: 'Elevated progesterone withdrawal combined with late-luteal cortisol spikes frequently mimics situational crisis.',
    sourceReference: 'Neuroendocrinology & HPA Axis Reactivity (Gordon et al., 2021)',
    actionTipForUser: '10-minute physiological sigh protocol (double inhale, elongated exhale) to downregulate sympathetic drive.',
    partnerNudgeTemplate: '{name} is experiencing late-luteal cortisol sensitivity. Lower conversational friction, defer high-stakes debates, and prepare dinner.',
    durationMinutes: 10,
    contentType: 'Guided Somatic',
  ),

  // 2. Late Luteal Sleep Deficit / Emotional Vulnerability
  ContentEntry(
    id: 'cnt_02',
    stateTag: 'late_luteal_sleep_deficit',
    phaseApplicability: ['luteal'],
    title: 'Restore Cortisol Balance',
    paraphrasedSummary: 'Sleep debt during cycle days 21–28 compounds amygdala reactivity by up to 60%, reducing cognitive emotional bandwidth.',
    sourceReference: 'Sleep & Affective Neuroscience (Walker et al., UC Berkeley)',
    actionTipForUser: 'Take a 20-minute Non-Sleep Deep Rest (NSDR) session before 3:00 PM; avoid intense evening cardio.',
    partnerNudgeTemplate: '{name} is carrying acute sleep debt in her late-luteal window. Protect her quiet downtime and encourage a 9:30 PM bedtime.',
    durationMinutes: 15,
    contentType: 'NSDR Protocol',
  ),

  // 3. Luteal Emotional Vulnerability
  ContentEntry(
    id: 'cnt_03',
    stateTag: 'luteal_emotional_vulnerability',
    phaseApplicability: ['luteal'],
    title: 'Somatic Grounding & Release',
    paraphrasedSummary: 'GABA receptor subunit remodeling in the late luteal window causes heightened sensory vulnerability.',
    sourceReference: 'Psychoneuroendocrinology of Allopregnanolone (Bäckström et al.)',
    actionTipForUser: 'Place a warm compress on the sternum and engage in 5 minutes of gentle body scanning.',
    partnerNudgeTemplate: '{name} may feel emotionally depleted today due to shifting GABA sensitivity. Offer gentle presence without attempting to fix.',
    durationMinutes: 8,
    contentType: 'Somatic Focus',
  ),

  // 4. Menstrual Phase Low Energy / Recovery
  ContentEntry(
    id: 'cnt_04',
    stateTag: 'menstrual_low_energy_recovery',
    phaseApplicability: ['menstrual'],
    title: 'Gentle Restorative Slumber',
    paraphrasedSummary: 'Systemic estrogen and progesterone nadir triggers cellular renewal, requiring increased rest and iron preservation.',
    sourceReference: 'Female Athlete Health & Basal Metabolic Shifts (Elliott-Sale et al.)',
    actionTipForUser: 'Prioritize restorative yin poses and warm bone broth or electrolyte-rich hydration.',
    partnerNudgeTemplate: '{name} has entered Day 1–2 of her cycle with lowest basal energy. Keep evenings low-key and bring warm tea or a heating pad.',
    durationMinutes: 12,
    contentType: 'Restorative',
  ),

  // 5. Menstrual Cramp & Pelvic Tension
  ContentEntry(
    id: 'cnt_05',
    stateTag: 'menstrual_cramp_tension',
    phaseApplicability: ['menstrual'],
    title: 'Pelvic Unwinding & Deep Warmth',
    paraphrasedSummary: 'Uterine prostaglandin release increases visceral smooth muscle tone, radiating discomfort to the lumbar spine.',
    sourceReference: 'Clinical Obstetrics & Prostaglandin Dynamics (Dawood, M.Y.)',
    actionTipForUser: 'Perform 8 minutes of supported child’s pose with diaphragmatic belly breathing into the lower pelvis.',
    partnerNudgeTemplate: '{name} is navigating peak menstrual cramping. A warm bath, hot water bottle, and zero errand requests will be deeply appreciated.',
    durationMinutes: 10,
    contentType: 'Targeted Relief',
  ),

  // 6. Menstrual Reflective Calm
  ContentEntry(
    id: 'cnt_06',
    stateTag: 'menstrual_reflective_calm',
    phaseApplicability: ['menstrual'],
    title: 'Inward Reflection & Quietude',
    paraphrasedSummary: 'Cross-hemispheric neural coherence is elevated during menstruation, fostering deep retrospective problem solving.',
    sourceReference: 'Functional Connectivity & Menstrual Cycle (Hidalgo-Lopez et al.)',
    actionTipForUser: '10-minute unstructured journaling session focusing on intuitive boundary setting.',
    partnerNudgeTemplate: '{name} is in a reflective, quiet phase. Give her space for creative thoughts and uninterrupted evening solitude.',
    durationMinutes: 10,
    contentType: 'Mindfulness',
  ),

  // 7. Follicular Rising Momentum / Cognitive Focus
  ContentEntry(
    id: 'cnt_07',
    stateTag: 'follicular_rising_momentum',
    phaseApplicability: ['follicular'],
    title: 'Cognitive Activation & Clarity',
    paraphrasedSummary: 'Steadily climbing estradiol enhances hippocampal neuroplasticity, working memory, and dopamine receptor density.',
    sourceReference: 'Estradiol & Prefrontal Cortex Synaptogenesis (Morrison & Baxter)',
    actionTipForUser: 'Block out a 90-minute deep-work sprint this morning to tackle your most intellectually complex challenge.',
    partnerNudgeTemplate: '{name} is in high-momentum follicular phase! It is an ideal window to plan future trips or brainstorm shared goals together.',
    durationMinutes: 15,
    contentType: 'Focus Priming',
  ),

  // 8. Follicular High Focus & Drive
  ContentEntry(
    id: 'cnt_08',
    stateTag: 'follicular_high_focus',
    phaseApplicability: ['follicular'],
    title: 'Creative Momentum Flow',
    paraphrasedSummary: 'Peak insulin sensitivity and cellular energetic throughput support sustained executive function.',
    sourceReference: 'Cellular Metabolism Across the Follicular Phase (Hackney et al.)',
    actionTipForUser: 'Execute strength training or creative synthesis; your physiological recovery rate is near maximum.',
    partnerNudgeTemplate: '{name} is radiating high stamina and mental clarity. Match her energetic pace or collaborate on active projects.',
    durationMinutes: 10,
    contentType: 'Energy Flow',
  ),

  // 9. Follicular Balanced Vitality
  ContentEntry(
    id: 'cnt_09',
    stateTag: 'follicular_balanced_vitality',
    phaseApplicability: ['follicular'],
    title: 'Vitality Expansion & Aerobic Priming',
    paraphrasedSummary: 'Cardiovascular efficiency and heart rate variability peak as estrogen stabilizes autonomic tone.',
    sourceReference: 'Autonomic Regulation & Estrogen Balance (Du et al., Frontiers in Physiology)',
    actionTipForUser: 'Engage in a 25-minute brisk outdoor zone-2 session with natural light exposure.',
    partnerNudgeTemplate: '{name} is in balanced vitality. Great day to invite her out for an active evening walk or workout.',
    durationMinutes: 12,
    contentType: 'Vitality Boost',
  ),

  // 10. Ovulatory Peak Social Energy & Balance
  ContentEntry(
    id: 'cnt_10',
    stateTag: 'ovulatory_peak_social_energy',
    phaseApplicability: ['ovulatory', 'follicular'],
    title: 'Expansive Social Connection',
    paraphrasedSummary: 'Estradiol and luteinizing hormone surge maximizes verbal fluency, extroversion, and communicative resonance.',
    sourceReference: 'Hormonal Influences on Social Cognitive Fluency (Macrae et al.)',
    actionTipForUser: 'Schedule crucial pitches, team meetings, or meaningful conversations with close partners.',
    partnerNudgeTemplate: '{name} is at peak ovulatory communicative vitality! Perfect evening for a spontaneous date night or lively dinner.',
    durationMinutes: 8,
    contentType: 'Social Resonance',
  ),

  // 11. Ovulatory High Stamina
  ContentEntry(
    id: 'cnt_11',
    stateTag: 'ovulatory_high_stamina',
    phaseApplicability: ['ovulatory'],
    title: 'Peak Resilience & Drive',
    paraphrasedSummary: 'Testosterone and estrogen peak simultaneously around cycle day 14, maximizing muscular power and pain tolerance.',
    sourceReference: 'Neuromuscular Function in Ovulatory Transition (Sarwar et al.)',
    actionTipForUser: 'Channel high physical capacity into demanding tasks; take 5 minutes to ground excessive nervous excitement.',
    partnerNudgeTemplate: '{name} has peak biological stamina today. She will thrive with energetic activities and active support.',
    durationMinutes: 10,
    contentType: 'Active Grounding',
  ),

  // 12. Early Luteal Metabolic Shift
  ContentEntry(
    id: 'cnt_12',
    stateTag: 'early_luteal_metabolic_shift',
    phaseApplicability: ['luteal'],
    title: 'Metabolic Stabilization & Unwind',
    paraphrasedSummary: 'Progesterone begins to climb, raising basal body temperature by ~0.3°C and slightly increasing baseline caloric burn.',
    sourceReference: 'Thermoregulation & Basal Metabolic Rate Shifts (Solomon et al.)',
    actionTipForUser: 'Ensure adequate complex carbohydrate intake with dinner to promote steady nighttime serotonin synthesis.',
    partnerNudgeTemplate: '{name} is adjusting to early luteal progesterone shifts. A comforting home-cooked dinner will ground her evening.',
    durationMinutes: 10,
    contentType: 'Metabolic Balance',
  ),

  // 13. Early Luteal Stress Buffer
  ContentEntry(
    id: 'cnt_13',
    stateTag: 'early_luteal_stress_buffer',
    phaseApplicability: ['luteal'],
    title: 'Preemptive Autonomic Reset',
    paraphrasedSummary: 'Early luteal allopregnanolone provides a temporary calming cushion before the late-luteal drop.',
    sourceReference: 'Neuroactive Steroids & Stress Modulation (Paul & Purdy)',
    actionTipForUser: 'Engage in 10 minutes of gentle coherent breathing (5.5s inhale, 5.5s exhale) to reinforce autonomic stability.',
    partnerNudgeTemplate: '{name} is enjoying balanced early-luteal calm. Help her maintain this momentum by keeping home logistics smooth.',
    durationMinutes: 10,
    contentType: 'Coherent Breathing',
  ),

  // 14. High Wearable HRV / Optimal Resilience State
  ContentEntry(
    id: 'cnt_14',
    stateTag: 'high_wearable_hrv_optimal_resilience',
    phaseApplicability: ['any', 'follicular', 'ovulatory'],
    title: 'Peak Resilience & Flow State',
    paraphrasedSummary: 'Biometric telemetry indicates superior parasympathetic recovery (HRV > 75ms), indicating high biological readiness.',
    sourceReference: 'Heart Rate Variability as a Biomarker for Autonomic Flexibility (Thayer et al.)',
    actionTipForUser: 'Your autonomic nervous system is primed for high performance. Lean into creative risk and decisive leadership.',
    partnerNudgeTemplate: '{name} has stellar autonomic recovery today! Celebrate her vitality and enjoy shared high-energy pursuits.',
    durationMinutes: 10,
    contentType: 'Flow State',
  ),

  // 15. Low Wearable HRV / Autonomic Strain
  ContentEntry(
    id: 'cnt_15',
    stateTag: 'low_wearable_hrv_autonomic_strain',
    phaseApplicability: ['any', 'luteal', 'menstrual'],
    title: 'Vagal Nerve Toning & Slow Exhale',
    paraphrasedSummary: 'Depressed heart rate variability signals sympathetic dominance and incomplete overnight recovery.',
    sourceReference: 'Autonomic Strain & Central Autonomic Network Regulation (Kemp et al.)',
    actionTipForUser: 'Perform 12 minutes of box breathing with 2 minutes of cold splash face exposure to trigger the mammalian dive reflex.',
    partnerNudgeTemplate: '{name}\'s wearable shows autonomic strain today. Reduce evening commitments and take initiative on shared errands.',
    durationMinutes: 12,
    contentType: 'Vagal Toning',
  ),

  // 16. Chronic Sleep Debt Restoration
  ContentEntry(
    id: 'cnt_16',
    stateTag: 'chronic_sleep_debt_restoration',
    phaseApplicability: ['any'],
    title: 'Circadian Anchor & Sleep Debt Protocol',
    paraphrasedSummary: 'A cumulative 3-day sleep deficit reduces prefrontal inhibition, skewing perception toward stress threat bias.',
    sourceReference: 'Sleep Deprivation & Neural Threat Detection (Yoo et al., Nature Neuroscience)',
    actionTipForUser: 'Get 10 minutes of direct morning sunlight into your eyes before 9:00 AM; dim blue screens 2 hours prior to bed.',
    partnerNudgeTemplate: '{name} has accumulated notable sleep debt. Encourage her to log off work early and offer to handle morning coffee.',
    durationMinutes: 10,
    contentType: 'Circadian Reset',
  ),

  // 17. High Stress / Cortisol State (General)
  ContentEntry(
    id: 'cnt_17',
    stateTag: 'high_stress_general',
    phaseApplicability: ['any'],
    title: 'Somatic De-escalation Protocol',
    paraphrasedSummary: 'Acute sympathetic overdrive triggers peripheral vasoconstriction and shallow clavicular respiration.',
    sourceReference: 'Physiological Stress Cascades & Somatic De-escalation (Sapolsky, R.)',
    actionTipForUser: 'Do 8 minutes of progressive muscle relaxation: tense shoulders 5s, release 10s.',
    partnerNudgeTemplate: '{name} is navigating high stress. Be a calm sounding board and avoid questioning her reactions right now.',
    durationMinutes: 8,
    contentType: 'De-escalation',
  ),

  // 18. Default / Balanced Recovery State (Fallback)
  ContentEntry(
    id: 'cnt_18',
    stateTag: 'default_generic_recovery',
    phaseApplicability: ['any'],
    title: 'Mindful Focus & Vitality Check-in',
    paraphrasedSummary: 'Your physiological markers are well-regulated. Consistent daily mindfulness preserves this autonomic equilibrium.',
    sourceReference: 'Neurobiology of Mindfulness & Autonomic Balance (Tang et al., Nat Rev Neurosci)',
    actionTipForUser: 'Take 5 mindful breaths before your next meal to prime digestion and parasympathetic presence.',
    partnerNudgeTemplate: '{name} is in a steady, balanced state today. Send an encouraging check-in to keep connection warm.',
    durationMinutes: 9,
    contentType: 'Mindful Focus',
  ),
];
