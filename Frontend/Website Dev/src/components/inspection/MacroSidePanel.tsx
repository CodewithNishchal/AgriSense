"use client";

/**
 * MacroSidePanel
 * ─────────────────────────────────────────────────────────────────────────────
 * The right-side panel shown in the INITIAL (pre-transition) state of the
 * Inspection Dashboard.  It displays six surveillance metric cards with mini
 * sparkbar charts, then a tabbed Messages / Notes section.
 *
 * Data wiring note:
 *  – Replace the `macroMetrics` and `messages` constants below with real API
 *    calls (e.g. fetch from /api/surveillance/macro) once the backend is ready.
 *  – Each metric card's `bars` array is the time-series sparkline data.
 */

import { useState, useEffect } from 'react';
import { Bell, Newspaper, Search, MapPin, ShieldAlert, Bug, Thermometer, Droplets } from 'lucide-react';
import type { ThemeTokens } from './themeTokens';

// ─── DATA TYPES ───────────────────────────────────────────────────────────────
interface MetricCard {
  id: string;
  label: string;
  value: string;
  sub: string;
  dot: string;           // Tailwind bg-* class for the pulsing dot
  color: string;         // Tailwind gradient classes for the icons
  icon: any;             // Lucide icon component
}

interface Message {
  id: number;
  type: 'warning' | 'officer' | 'info';
  time: string;
  title: string;
  body: string;
  avatar: string | null;
}

interface NewsItem {
  id: number;
  title: string;
  source: string;
  time: string;
  image: string;
  url: string;
}

// ─── MOCK DATA ────────────────────────────────────────────────────────────────
// TODO: Replace with real API fetch
// ─── MOCK DATA (Fallback) ────────────────────────────────────────────────────────
const initialMetrics: MetricCard[] = [
  {
    id: 'scans', label: 'ACTIVE SCANS', value: '...', sub: 'Loading...',
    dot: 'bg-emerald-500',
    color: 'from-emerald-400 to-green-600',
    icon: Search,
  },
  {
    id: 'hotspot', label: 'FASTEST HOTSPOT', value: '...', sub: 'Loading...',
    dot: 'bg-blue-500',
    color: 'from-blue-400 to-blue-600',
    icon: MapPin,
  },
  {
    id: 'risk', label: 'RISK INDEX', value: '...', sub: 'Loading...',
    dot: 'bg-red-500',
    color: 'from-orange-400 to-red-500',
    icon: ShieldAlert,
  },
  {
    id: 'pathogen', label: 'TOP PATHOGEN', value: '...', sub: 'Loading...',
    dot: 'bg-amber-500',
    color: 'from-amber-400 to-orange-500',
    icon: Bug,
  },
  {
    id: 'temp', label: '7-DAY VELOCITY', value: '...', sub: 'Loading...',
    dot: 'bg-cyan-500',
    color: 'from-cyan-400 to-sky-500',
    icon: Thermometer,
  },
  {
    id: 'precip', label: 'AFFECTED SPREAD', value: '...', sub: 'Loading...',
    dot: 'bg-indigo-400',
    color: 'from-indigo-400 to-blue-500',
    icon: Droplets,
  },
];

const news: NewsItem[] = [
  {
    id: 1, title: 'Heatwave in India: Wheat production targets under threat as temperatures soar.',
    source: 'Hindustan Times', time: '1h ago',
    image: 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?q=80&w=120&auto=format&fit=crop',
    url: 'https://www.hindustantimes.com/india-news/heatwave-in-india-wheat-production-under-threat-101682570000000.html',
  },
  {
    id: 2, title: 'Ministry of Agriculture scales up PM-Kisan verification with AI tools.',
    source: 'Times of India', time: '3h ago',
    image: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=120&auto=format&fit=crop',
    url: 'https://timesofindia.indiatimes.com/india/govt-integrates-ai-in-pm-kisan-portal/articleshow/103982500.cms',
  },
  {
    id: 3, title: 'Sustainable Farming: How Indian startups are changing the landscape.',
    source: 'The Hindu', time: '8h ago',
    image: 'https://images.unsplash.com/photo-1471193945509-9ad0617afabf?q=80&w=120&auto=format&fit=crop',
    url: 'https://www.thehindu.com/sci-tech/agriculture/how-indian-startups-are-changing-farming/article67000000.ece',
  },
  {
    id: 4, title: 'Onion prices surge as unseasonal rain hits supply chain in Maharashtra.',
    source: 'Economic Times', time: '12h ago',
    image: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?q=80&w=120&auto=format&fit=crop',
    url: 'https://economictimes.indiatimes.com/news/economy/agriculture/onion-prices-surge/articleshow/104000000.cms',
  },
  {
    id: 5, title: 'Millet Mission: India pushes for global adoption of ancient grains.',
    source: 'Mint', time: '1d ago',
    image: 'https://images.unsplash.com/photo-1595113316349-9fa4eb24f884?q=80&w=120&auto=format&fit=crop',
    url: 'https://www.livemint.com/news/india/india-pushes-millet-adoption-11670000000000.html',
  },
  {
    id: 6, title: 'Yellow Rust Disease alert issued for wheat farmers in Punjab and Haryana.',
    source: 'Indian Express', time: '2d ago',
    image: 'https://images.unsplash.com/photo-1592231263056-17b60586e90e?q=80&w=120&auto=format&fit=crop',
    url: 'https://indianexpress.com/article/cities/chandigarh/yellow-rust-wheat-alert-punjab-haryana-farmers-8400000/',
  },
];

const messages: Message[] = [
  {
    id: 1, type: 'warning', time: '5m ago',
    title: 'Warning!',
    body: 'UP hotspot scan readings for Wheat Rust are higher than normal. Immediate review recommended.',
    avatar: null,
  },
  {
    id: 2, type: 'officer', time: '10m ago',
    title: 'Field Officer – Priya S.',
    body: 'Confirmed 3 new villages in Nagpur block reporting first symptoms. Deploying response team.',
    avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Priya',
  },
  {
    id: 3, type: 'info', time: '22m ago',
    title: 'System Alert',
    body: 'Agmarknet Mandi data synced. ₹47L economic loss estimate calculated for Nagpur zone.',
    avatar: null,
  },
];

// ─── COMPONENT ────────────────────────────────────────────────────────────────
interface Props {
  theme: ThemeTokens;
  isNightVision: boolean;
}

export default function MacroSidePanel({ theme, isNightVision }: Props) {
  const [activeTab, setActiveTab] = useState<'messages' | 'news'>('news');
  const [macroMetrics, setMacroMetrics] = useState<MetricCard[]>(initialMetrics);

  useEffect(() => {
    fetch('/api/analytics/national')
      .then(res => res.json())
      .then(res => {
        if (res.status === 'success') {
          const data = res.data;
          setMacroMetrics(prev => prev.map(m => {
            if (m.id === 'scans') {
              return { 
                ...m, 
                value: String(data.overview.total_scans_all_time || 0), 
                sub: `${data.overview.national_positivity_rate_pct || 0}% Positivity` 
              };
            }
            if (m.id === 'hotspot') {
              return { 
                ...m, 
                value: data.hotspot.primary_district || 'N/A', 
                sub: `${data.hotspot.cases_in_cluster || 0} cases in cluster` 
              };
            }
            if (m.id === 'risk') {
              const positivity = data.overview.national_positivity_rate_pct || 0;
              const growth = Math.min(Math.max(data.velocity.week_over_week_growth_pct || 0, -100), 100);
              
              // Composite Risk Score: weights Positivity (70%) and Growth (30%)
              const score = Math.min(Math.round((positivity * 0.7) + ((growth + 100) / 2 * 0.3)), 100);
              
              let label = "LOW";
              if (score > 75) label = "CRITICAL";
              else if (score > 50) label = "HIGH";
              else if (score > 25) label = "MODERATE";

              return { 
                ...m, 
                value: `${label} (${score})`, 
                sub: `Velocity: ${growth > 0 ? '+' : ''}${growth}%` 
              };
            }
            if (m.id === 'pathogen') {
              return { 
                ...m, 
                value: data.overview.dominant_pathogen || 'Unknown', 
                sub: 'Dominant Strain' 
              };
            }
            if (m.id === 'temp') {
              return { 
                ...m, 
                value: String(data.overview.scans_last_7_days || 0), 
                sub: 'Scans this week' 
              };
            }
            if (m.id === 'precip') {
              return { 
                ...m, 
                value: `${data.area.total_affected_area_sq_km || 0} km²`, 
                sub: 'Geographic Area' 
              };
            }
            return m;
          }));
        }
      })
      .catch(err => {
        console.error("Fetch Error:", err);
      });
  }, []);

  return (
    <div className={`flex-1 flex flex-col h-full overflow-hidden rounded-[24px] border ${theme.cardBorder} ${theme.sidePanel} shadow-[0_4px_30px_rgba(16,185,129,0.06)]`}>

      {/* ── Section label ─────────────────────────────────────────────────── */}
      <div className="px-5 pt-6 pb-4 shrink-0">
        <p className={`text-[14px] font-black uppercase tracking-[0.2em] ${theme.sectionLabel}`}>
          INDIA · NATIONAL SURVEILLANCE METRICS
        </p>
      </div>

      {/* ── 2×3 Metric card grid ──────────────────────────────────────────── */}
      <div className="px-4 grid grid-cols-2 gap-3 shrink-0">
        {macroMetrics.map(m => (
          <div
            key={m.id}
            className={`${theme.cardBg} ${theme.cardBorder} rounded-2xl p-4 flex items-center justify-between hover:shadow-lg transition-all duration-300 group`}
          >
            <div className="min-w-0 mr-2">
              <p className={`text-[9px] font-black uppercase tracking-widest ${theme.sectionLabel} mb-2 flex items-center gap-1.5 truncate`}>
                {m.label}
                <span className={`w-1.5 h-1.5 rounded-full inline-block shrink-0 ${m.dot} animate-pulse`} />
              </p>
              <p className={`text-base font-black ${theme.value} leading-tight truncate`}>{m.value}</p>
              <p className={`text-[10px] ${theme.subText} mt-0.5 truncate`}>{m.sub}</p>
            </div>
            <div className={`w-11 h-11 rounded-2xl flex items-center justify-center bg-gradient-to-br ${m.color} shadow-lg shadow-emerald-500/10 group-hover:scale-110 transition-transform duration-300`}>
              <m.icon className="w-5 h-5 text-white" />
            </div>
          </div>
        ))}
      </div>

      {/* ── Messages / Notes tabs ──────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col overflow-hidden px-4 mt-4 pb-4 min-h-0">

        {/* Tab bar */}
        <div className={`flex gap-4 border-b ${theme.accentBorder} mb-3 shrink-0`}>
          {(['messages', 'news'] as const).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`pb-2 text-[14px] font-extrabold uppercase tracking-widest transition-all ${
                activeTab === tab ? theme.tabActive : theme.tabInactive
              }`}
            >
              {tab === 'messages' ? (
                <span className="flex items-center gap-1.5">
                  <Bell className="w-3 h-3" />
                  Messages
                </span>
              ) : (
                <span className="flex items-center gap-1.5">
                  <Newspaper className="w-3 h-3" />
                  News
                </span>
              )}
            </button>
          ))}
        </div>

        {/* Scrollable message/news list */}
        <div className="flex-1 h-0 overflow-y-auto flex flex-col gap-2.5">
          {activeTab === 'messages' ? (
            messages.map(msg => (
              <div key={msg.id} className={`rounded-[16px] p-3.5 ${theme.msgCard} flex gap-3 items-start shrink-0`}>
                {/* Avatar or pulse dot */}
                {msg.avatar ? (
                  <img
                    src={msg.avatar}
                    alt={msg.title}
                    className="w-9 h-9 rounded-full shrink-0 border border-white/20 object-cover"
                  />
                ) : (
                  <div className={`w-9 h-9 rounded-full shrink-0 flex items-center justify-center ${
                    msg.type === 'warning' ? 'bg-red-100 dark:bg-red-950/40' : 'bg-blue-100'
                  }`}>
                    <div className={`w-2.5 h-2.5 rounded-full ${
                      msg.type === 'warning' ? 'bg-red-500 animate-pulse' : 'bg-blue-400'
                    }`} />
                  </div>
                )}
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-start gap-2">
                    <p className={`text-[11px] font-bold ${theme.msgText} leading-tight`}>{msg.title}</p>
                    <span className={`text-[9px] font-bold shrink-0 ${theme.msgSub}`}>{msg.time}</span>
                  </div>
                  <p className={`text-[10px] leading-relaxed mt-1 ${theme.msgSub}`}>{msg.body}</p>
                </div>
              </div>
            ))
          ) : (
            news.map(item => (
              <a
                key={item.id}
                href={item.url}
                target="_blank"
                rel="noopener noreferrer"
                className={`rounded-[16px] overflow-hidden ${theme.msgCard} flex items-center gap-3 p-2 hover:bg-white/10 transition-colors group border border-transparent hover:border-emerald-500/20 shrink-0`}
              >
                <div className="w-20 h-20 rounded-xl overflow-hidden shrink-0">
                  <img src={item.image} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" alt="news" />
                </div>
                <div className="flex-1 min-w-0 pr-1">
                  <div className="flex justify-between items-center mb-1.5">
                    <span className={`text-[10px] font-black uppercase text-emerald-500 tracking-wider`}>{item.source}</span>
                    <span className={`text-[10px] font-bold ${theme.msgSub}`}>{item.time}</span>
                  </div>
                  <p className={`text-[13px] font-bold ${theme.msgText} leading-snug line-clamp-3 overflow-hidden`}>
                    {item.title}
                  </p>
                </div>
              </a>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
