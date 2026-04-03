// ─── SHARED THEME TOKENS ─────────────────────────────────────────────────────
// Consumed by MacroSidePanel, DistrictAnalyticsPanel, and page.tsx

export type ThemeMode = 'light' | 'night';

export interface ThemeTokens {
  pageBg: string;
  sidePanel: string;
  cardBg: string;
  cardBorder: string;
  sectionLabel: string;
  value: string;
  subText: string;
  accent: string;
  accentBg: string;
  accentBorder: string;
  tagWarn: string;
  tabActive: string;
  tabInactive: string;
  msgCard: string;
  msgText: string;
  msgSub: string;
  mapStyle: string;
  tooltipBg: string;
  tooltipBorder: string;
  tooltipColor: string;
  nightBtn: string;
  chartStroke: string;
  chartFill: string;
  radarGrid: string;
  radarTick: string;
  pillActive: string;
  pillInactive: string;
  pillBg: string;
}

export const T: Record<ThemeMode, ThemeTokens> = {
  light: {
    pageBg:        'bg-[#edf7f1]',
    sidePanel:     'bg-white/70 backdrop-blur-2xl border-l border-green-100/80',
    cardBg:        'bg-white/80 backdrop-blur-md',
    cardBorder:    'border border-green-100',
    sectionLabel:  'text-gray-400',
    value:         'text-black',
    subText:       'text-gray-400',
    accent:        'text-black',
    accentBg:      'bg-emerald-50',
    accentBorder:  'border-emerald-100',
    tagWarn:       'bg-red-50 text-red-600 border border-red-200',
    tabActive:     'text-emerald-600 border-b-2 border-emerald-500',
    tabInactive:   'text-gray-400',
    msgCard:       'bg-gray-50 border border-gray-100',
    msgText:       'text-gray-700',
    msgSub:        'text-gray-400',
    mapStyle:      'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
    tooltipBg:     '#fff',
    tooltipBorder: '#d1fae5',
    tooltipColor:  '#111',
    nightBtn:      'bg-emerald-600 text-white border-emerald-500',
    chartStroke:   '#059669',
    chartFill:     '#10b981',
    radarGrid:     'rgba(16,185,129,0.15)',
    radarTick:     '#6b7280',
    pillActive:    'bg-emerald-600 text-white',
    pillInactive:  'text-gray-400',
    pillBg:        'bg-gray-100',
  },
  night: {
    pageBg:        'bg-[#050e05]',
    sidePanel:     'bg-[#0a1a0a]/85 backdrop-blur-2xl border-l border-[#1a3d1a]/60',
    cardBg:        'bg-[#0d1f0d]/80 backdrop-blur-md',
    cardBorder:    'border border-[#1a3d1a]/60',
    sectionLabel:  'text-[#39ff5e]/40',
    value:         'text-[#d0ffd8]',
    subText:       'text-[#39ff5e]/40',
    accent:        'text-[#39ff5e]',
    accentBg:      'bg-[#0a2a0a]',
    accentBorder:  'border-[#1a4d1a]',
    tagWarn:       'bg-red-950/50 text-red-400 border border-red-800/50',
    tabActive:     'text-[#39ff5e] border-b-2 border-[#39ff5e]',
    tabInactive:   'text-[#39ff5e]/30',
    msgCard:       'bg-[#0a1a0a] border border-[#1a3d1a]/60',
    msgText:       'text-[#c0ffc8]',
    msgSub:        'text-[#39ff5e]/30',
    mapStyle:      'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json',
    tooltipBg:     '#0a1a0a',
    tooltipBorder: '#1a3d1a',
    tooltipColor:  '#d0ffd8',
    nightBtn:      'bg-[#39ff5e] text-black border-[#39ff5e] shadow-[0_0_16px_rgba(57,255,94,0.4)]',
    chartStroke:   '#39ff5e',
    chartFill:     '#00ff55',
    radarGrid:     'rgba(57,255,94,0.12)',
    radarTick:     '#39ff5e66',
    pillActive:    'bg-[#39ff5e] text-black',
    pillInactive:  'text-[#39ff5e]/40',
    pillBg:        'bg-[#0a1a0a]',
  },
};
