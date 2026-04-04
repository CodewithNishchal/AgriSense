"use client";

import { useState, useEffect } from 'react';
import {
  BarChart, Bar, XAxis, Tooltip, ResponsiveContainer,
  ComposedChart, LineChart, Line, AreaChart, Area,
  Radar, RadarChart, PolarGrid, PolarAngleAxis, YAxis, Legend,
} from 'recharts';
import { Activity, ShieldAlert, AlertTriangle, Search, Bug, ChevronLeft, CloudRain, Thermometer, Droplets, Wind, Zap, Microscope } from 'lucide-react';
import toast from 'react-hot-toast';
import type { ThemeTokens } from './themeTokens';

// ─── MOCK DATA ────────────────────────────────────────────────────────────────
const unifiedData = [
  { day: '04 May', total: 550, confirmed: 220, humidity: 65 },
  { day: '07 May', total: 720, confirmed: 300, humidity: 72 },
  { day: '10 May', total: 890, confirmed: 280, humidity: 68 },
  { day: '13 May', total: 850, confirmed: 350, humidity: 82 },
  { day: '16 May', total: 1020, confirmed: 400, humidity: 88 },
];

const velocityData = [
  { day: '10 May', actual: 33, predicted: null },
  { day: '13 May', actual: 41, predicted: null },
  { day: '15 May', actual: 49, predicted: 49 },
  { day: '17 May', predicted: 58 },
  { day: '19 May', predicted: 72 },
  { day: '21 May', predicted: 85 },
];

const economicData = [
  { day: '10 May', actual: 388000, predicted: null },
  { day: '13 May', actual: 420000, predicted: null },
  { day: '15 May', actual: 472000, predicted: 472000 },
  { day: '17 May', predicted: 520000 },
  { day: '19 May', predicted: 590000 },
  { day: '21 May', predicted: 680000 },
];

// radarData is now populated live from the backend — no hardcoded values

const initialKpi = {
  pathogen: 'Loading...',
  totalScans: '...',
  confirmedActive: '...',
  economicRisk: '...',
  officers: '...',
};

interface Props {
  theme: ThemeTokens;
  isNightVision: boolean;
  districtName?: string;
  lat?: number;
  lng?: number;
  onBack: () => void;
}

export default function DistrictAnalyticsPanel({
  theme, isNightVision, districtName = 'Nagpur', lat, lng, onBack,
}: Props) {
  const [timeRange, setTimeRange] = useState<'7' | '30'>('7');
  const [kpiData, setKpiData] = useState(initialKpi);
  const [chartData, setChartData] = useState<any[]>([]);
  const [radarData, setRadarData] = useState<{ subject: string; A: number }[]>([]);

  // ── Open-Meteo Weather (free, no API key) ────────────────────────────────
  const [weather, setWeather] = useState<{
    temp: string; humidity: string; wind: string; windDir: string; riskScore: string; riskLabel: string;
  } | null>(null);

  useEffect(() => {
    if (!lat || !lng) return;
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m&wind_speed_unit=kmh`;
    fetch(url)
      .then(r => r.json())
      .then(data => {
        const c = data.current;
        const t = c.temperature_2m as number;
        const h = c.relative_humidity_2m as number;
        const ws = c.wind_speed_10m as number;
        const wd = c.wind_direction_10m as number;

        // Convert wind degrees to compass direction
        const dirs = ['N','NE','E','SE','S','SW','W','NW'];
        const compassDir = dirs[Math.round(wd / 45) % 8];

        // AI Risk = weighted formula: high humidity & warm temp = disease spread risk
        const rawRisk = Math.min(10, ((h / 100) * 5.5) + ((Math.max(0, t - 15)) / 20) * 4.5);
        const riskScore = rawRisk.toFixed(1);
        const riskLabel = rawRisk >= 8 ? 'Severe Outbreak' : rawRisk >= 6 ? 'High Risk' : rawRisk >= 4 ? 'Moderate Risk' : 'Low Risk';

        setWeather({
          temp: `${t}°C`,
          humidity: `${h}%`,
          wind: `${ws.toFixed(0)}km/h ${compassDir}`,
          windDir: wd >= 90 && wd <= 270 ? 'Infection Path' : 'Dispersing Wind',
          riskScore: `${riskScore}/10`,
          riskLabel,
        });
      })
      .catch(err => console.error('❌ Weather fetch error:', err));
  }, [lat, lng]);

  // Fetch Chart Data (Time-series)
  useEffect(() => {
    async function fetchChartData() {
      try {
        const res = await fetch(`/api/charts?district=${encodeURIComponent(districtName)}`);
        const rawData = await res.json();

        // THE HACKATHON TRICK DATA PREP
        // Transform the DB rows into Recharts-friendly keys for history/forecast rendering
        const processed = rawData.map((day: any, index: number, array: any[]) => {
          // Connect point: The last history point should also be the start of the forecast line
          const isConnectPoint = !day.is_forecast && (array[index + 1]?.is_forecast === true);
          
          return {
            name: day.date_label,
            humidity: day.avg_humidity,
            // History keys
            history_cases: !day.is_forecast ? day.positive_cases : null,
            history_risk: !day.is_forecast ? day.economic_risk_inr : null,
            // Forecast keys (includes connect point for continuous lines)
            forecast_cases: day.is_forecast || isConnectPoint ? day.positive_cases : null,
            forecast_risk: day.is_forecast || isConnectPoint ? day.economic_risk_inr : null,
          };
        });

        setChartData(processed);
      } catch (err) {
        console.error("❌ Chart data fetch error:", err);
      }
    }
    fetchChartData();
  }, [districtName]);

  useEffect(() => {
    fetch(`/api/analytics/${encodeURIComponent(districtName)}`)
      .then(res => res.json())
      .then(res => {
        if (res.status === 'success') {
          // ── KPI cards ──────────────────────────────────────────────────────
          setKpiData({
            pathogen: res.data.primaryPathogen,
            totalScans: res.data.totalScans.toLocaleString(),
            confirmedActive: res.data.activeInfections.toLocaleString(),
            economicRisk: res.data.economicRiskFormatted.replace('₹', ''),
            officers: res.data.extensionOfficers.toString(),
          });
          // ── Radar chart — live pathogen distribution ────────────────────
          if (res.data.pathogenDistribution && res.data.pathogenDistribution.length > 0) {
            setRadarData(res.data.pathogenDistribution);
          }
        }
      })
      .catch(console.error);
  }, [districtName]);

  const tooltipStyle = {
    backgroundColor: theme.tooltipBg,
    border: `1px solid ${theme.tooltipBorder}`,
    borderRadius: 12, fontSize: 11, fontWeight: 700,
    color: theme.tooltipColor,
  };

  const xTickStyle = { fontSize: 8, fill: isNightVision ? '#39ff5e44' : '#9ca3af' };
  const cursorStyle = { fill: isNightVision ? 'rgba(57,255,94,0.05)' : 'rgba(16,185,129,0.04)' };

  const handleDispatch = () => {
    toast.error(`Emergency Response Dispatched to ${districtName}!`, {
      duration: 5000,
      icon: '🚨',
      style: {
        borderRadius: '16px',
        background: '#000',
        color: '#fff',
        border: '2px solid #ef4444',
        fontSize: '14px',
        fontWeight: 'bold',
        textTransform: 'uppercase',
        letterSpacing: '1px',
      },
    });
    
    // Simulate some logs in the marquee or state
    console.log(`[DISPATCH] Rapid response team initiated for ${districtName}`);
  };

  return (
    <div className={`flex flex-col h-full overflow-hidden p-6 gap-6 ${isNightVision ? 'bg-[#0a0f16]' : 'bg-[#f8fafc]'}`}>
      
      {/* ── SVG Gradients ── */}
      <svg width="0" height="0" className="absolute">
        <defs>
          <linearGradient id="barGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={isNightVision ? '#39ff5e' : '#10b981'} />
            <stop offset="100%" stopColor={isNightVision ? '#006622' : '#047857'} />
          </linearGradient>
          <filter id="glow"><feGaussianBlur stdDeviation="2.5" result="blur"/><feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
        </defs>
      </svg>

      {/* ── Header Area ── */}
      <div className="flex items-center justify-between shrink-0">
        <div className="flex items-center gap-4">
          <button onClick={onBack} className={`h-10 px-4 rounded-2xl flex items-center justify-center gap-2 ${theme.accentBg} border ${theme.accentBorder} ${theme.accent} hover:scale-105 transition-transform shadow-lg`}>
            <ChevronLeft className="w-5 h-5" />
            <span className="text-[11px] font-black uppercase tracking-wider">Return</span>
          </button>
          <div>
            <h2 className={`text-xl font-black ${theme.accent} tracking-tight`}>{districtName} Hotspot Analysis</h2>
            <p className={`text-[11px] font-bold ${theme.subText} uppercase tracking-[0.2em] opacity-60`}>Project Agri-NXT · Bio-Surveillance Core</p>
          </div>
        </div>
        
        <div className="flex items-center gap-3">
          <div className={`flex rounded-xl p-1 border ${theme.pillBg} ${theme.cardBorder}`}>
            {['7', '30'].map(r => (
              <button key={r} onClick={() => setTimeRange(r as any)} className={`px-4 py-1.5 text-[11px] font-black rounded-lg transition-all ${timeRange === r ? theme.pillActive : theme.pillInactive}`}>{r}D</button>
            ))}
          </div>
          <button 
            onClick={handleDispatch}
            className="px-5 py-2.5 rounded-xl bg-red-600 text-white text-[11px] font-black uppercase tracking-widest shadow-xl shadow-red-600/20 hover:bg-red-700 transition-colors flex items-center gap-2 hover:scale-105 active:scale-95 duration-200"
          >
            <ShieldAlert className="w-4 h-4" /> Dispatch Rapid Response
          </button>
        </div>
      </div>

      {/* ── KPI Summary Banner ── */}
      <div className="grid grid-cols-5 gap-4 shrink-0">
        {[
          { label: 'Primary Pathogen', value: kpiData.pathogen, icon: Bug, color: 'text-red-500', bg: 'bg-red-500/10' },
          { label: 'Total Diagnostic Scans', value: kpiData.totalScans, icon: Search, color: 'text-emerald-500', bg: 'bg-emerald-500/10' },
          { label: 'Active Infections', value: kpiData.confirmedActive, icon: Activity, color: 'text-orange-500', bg: 'bg-orange-500/10' },
          { label: 'Economic Risk (Est.)', value: `₹${kpiData.economicRisk}`, icon: ShieldAlert, color: 'text-blue-500', bg: 'bg-blue-500/10' },
          { label: 'Extension Readiness', value: `${kpiData.officers} Officers`, icon: Zap, color: 'text-purple-500', bg: 'bg-purple-500/10' },
        ].map((kpi, i) => (
          <div key={i} className={`${theme.cardBg} ${theme.cardBorder} rounded-2xl p-4 flex items-center gap-4 shadow-sm border`}>
            <div className={`w-10 h-10 rounded-xl ${kpi.bg} ${kpi.color} flex items-center justify-center shrink-0`}>
              <kpi.icon className="w-5 h-5" />
            </div>
            <div>
              <p className="text-[14px] font-black text-gray-800 dark:text-white uppercase tracking-tight">{kpi.value}</p>
              <p className={`text-[9px] font-bold ${theme.subText} uppercase tracking-wider`}>{kpi.label}</p>
            </div>
          </div>
        ))}
      </div>

      {/* ── Main Analytical Dashboard — Scrollable content ── */}
      <div className="flex-1 overflow-y-auto pr-2 custom-scrollbar space-y-6 min-h-0">
        
        {/* Row 1: The Big Insights */}
        <div className="grid grid-cols-3 gap-6 h-[340px] shrink-0">
          {/* Large Chart: Unified Outbreak Correlation */}
          <div className={`col-span-2 ${theme.cardBg} ${theme.cardBorder} rounded-3xl p-6 flex flex-col shadow-sm border relative`}>
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-2">
                <Microscope className={`w-4 h-4 ${theme.accent}`} />
                <span className="text-[11px] font-black uppercase tracking-widest text-gray-400">Diagnostic vs Atmospheric Correlation</span>
              </div>
              <div className="flex gap-4">
                <div className="flex items-center gap-2"><div className="w-3 h-3 rounded bg-emerald-500/20" /><span className="text-[10px] font-bold text-gray-400 uppercase">Scans</span></div>
                <div className="flex items-center gap-2"><div className="w-3 h-3 rounded bg-emerald-500" /><span className="text-[10px] font-bold text-gray-400 uppercase">Positives</span></div>
                <div className="flex items-center gap-2"><div className="w-3 h-3 rounded bg-blue-500" /><span className="text-[10px] font-bold text-gray-400 uppercase">Humidity %</span></div>
              </div>
            </div>
            <div className="flex-1 min-h-0">
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={chartData.length > 0 ? chartData : unifiedData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={xTickStyle} dy={10} />
                  <YAxis yAxisId="left" hide />
                  <YAxis yAxisId="right" orientation="right" hide />
                  <Tooltip contentStyle={tooltipStyle} cursor={cursorStyle} />
                  <Legend verticalAlign="top" height={36} iconType="circle" wrapperStyle={{ fontSize: '10px', textTransform: 'uppercase', fontWeight: 700, paddingLeft: '40px' }} />
                  
                  {/* Historical Cases (Bars/Solid) */}
                  <Bar yAxisId="left" dataKey="history_cases" name="Confirmed Cases" fill="url(#barGrad)" radius={[8, 8, 0, 0]} barSize={34} />
                  
                  {/* Forecast Cases (Dashed Line) */}
                  <Line yAxisId="left" type="monotone" dataKey="forecast_cases" name="AI Prediction" stroke={isNightVision ? '#39ff5e' : '#10b981'} strokeWidth={3} strokeDasharray="5 5" dot={false} />
                  
                  {/* Humidity Line (Environmental Context) */}
                  <Line yAxisId="right" type="monotone" dataKey="humidity" name="Avg Humidity (%)" stroke="#3b82f6" strokeWidth={2} dot={{ r: 4, fill: '#3b82f6' }} strokeOpacity={0.7} />
                </ComposedChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Regional Pathogen Radar */}
          <div className={`${theme.cardBg} ${theme.cardBorder} rounded-3xl p-6 flex flex-col shadow-sm border`}>
            <div className="flex items-center gap-2 mb-4">
              <AlertTriangle className={`w-4 h-4 text-orange-500`} />
              <span className="text-[11px] font-black uppercase tracking-widest text-gray-400">Pathogen Diversity</span>
            </div>
            <div className="flex-1">
              {radarData.length === 0 ? (
                <div className="w-full h-full flex flex-col items-center justify-center gap-2 opacity-50">
                  <div className="w-24 h-24 rounded-full border-2 border-dashed border-emerald-500/30 animate-pulse" />
                  <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Fetching data…</span>
                </div>
              ) : (
                <div className="h-[220px] w-full flex flex-col mt-2">
                  <ResponsiveContainer width="100%" height="100%">
                    <RadarChart cx="50%" cy="50%" outerRadius="75%" data={radarData}>
                      <PolarGrid stroke={isNightVision ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)'} strokeWidth={1} />
                      <PolarAngleAxis dataKey="subject" tick={{ fill: theme.radarTick, fontSize: 8, fontWeight: 800 }} />
                      
                      {/* National Baseline (Ghosted Layer) */}
                      <Radar name="National Avg" dataKey="B" stroke="#3b82f6" fill="#3b82f6" fillOpacity={0.1} strokeWidth={2} strokeDasharray="4 4" />
                      
                      {/* District Metrics (Active Layer) */}
                      <Radar name="District" dataKey="A" stroke="#10b981" fill="#10b981" fillOpacity={0.3} strokeWidth={3} />
                    </RadarChart>
                  </ResponsiveContainer>
                  
                  {/* Legend Overlay */}
                  <div className="flex justify-center gap-6 mt-4 shrink-0 bg-black/5 rounded-full py-1.5 mx-auto px-4">
                    <div className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-full bg-[#10b981]" />
                      <span className="text-[10px] font-black text-gray-400 uppercase tracking-tighter">District</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-full bg-[#3b82f6] opacity-60" />
                      <span className="text-[10px] font-black text-gray-400 uppercase tracking-tighter">National Avg</span>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Row 2: Predictive & Environmental Row */}
        <div className="grid grid-cols-2 gap-6 h-[280px] shrink-0">
          
          {/* Spread Velocity Forecast */}
          <div className={`${theme.cardBg} ${theme.cardBorder} rounded-3xl p-6 flex flex-col shadow-sm border`}>
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Activity className={`w-4 h-4 text-emerald-500`} />
                <span className="text-[11px] font-black uppercase tracking-widest text-gray-400">AI Spread Forecast</span>
              </div>
              <span className="text-[10px] font-black text-emerald-500 uppercase tracking-wider animate-pulse">Predicting Tomorrow...</span>
            </div>
            <div className="flex-1">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={chartData.length > 0 ? chartData : velocityData} margin={{ top: 10, right: 30, left: -20, bottom: 0 }}>
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={xTickStyle} dy={10} />
                  <Tooltip contentStyle={tooltipStyle} />
                  <Line type="monotone" dataKey="history_cases" name="Actual" stroke="#10b981" strokeWidth={4} dot={{ r: 5, fill: '#fff', strokeWidth: 3 }} />
                  <Line type="monotone" dataKey="forecast_cases" name="Predicted" stroke="#10b981" strokeWidth={3} strokeDasharray="6 6" strokeOpacity={0.4} dot={{ r: 4, fill: '#fff', strokeWidth: 2 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Economic Value Impact Forecast */}
          <div className={`${theme.cardBg} ${theme.cardBorder} rounded-3xl p-6 flex flex-col shadow-sm border`}>
             <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Search className={`w-4 h-4 text-blue-500`} />
                <span className="text-[11px] font-black uppercase tracking-widest text-gray-400">Economic Asset Vulnerability</span>
              </div>
              <span className="text-[10px] font-bold text-gray-400 uppercase tracking-tighter">Unit: INR</span>
            </div>
            <div className="flex-1">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData.length > 0 ? chartData : economicData} margin={{ top: 10, right: 30, left: -20, bottom: 0 }}>
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={xTickStyle} dy={10} />
                  <Tooltip contentStyle={tooltipStyle} />
                  <Area type="monotone" dataKey="history_risk" name="History" stroke="#3b82f6" fillOpacity={0.1} fill="#3b82f6" strokeWidth={3} />
                  <Area type="monotone" dataKey="forecast_risk" name="Prediction" stroke="#3b82f6" fillOpacity={0.05} fill="#3b82f6" strokeWidth={2} strokeDasharray="5 5" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Row 3: Environment Row (Weather) — Live from Open-Meteo */}
        <div className="grid grid-cols-4 gap-6 shrink-0 pb-6">
          {[
            {
              label: 'Ambient Temp',
              val: weather?.temp ?? '---',
              info: weather ? (parseFloat(weather.temp) > 30 ? '+Heat Stress' : 'Normal Range') : 'Fetching...',
              icon: Thermometer,
              color: 'text-red-500',
            },
            {
              label: 'Surface Humidity',
              val: weather?.humidity ?? '---',
              info: weather ? (parseInt(weather.humidity) >= 80 ? 'Critical Risk' : parseInt(weather.humidity) >= 60 ? 'Moderate Risk' : 'Stable') : 'Fetching...',
              icon: Droplets,
              color: 'text-blue-500',
            },
            {
              label: 'Wind Direction',
              val: weather?.wind ?? '---',
              info: weather?.windDir ?? 'Fetching...',
              icon: Wind,
              color: 'text-emerald-500',
            },
            {
              label: 'AI Risk Rating',
              val: weather?.riskScore ?? '---',
              info: weather?.riskLabel ?? 'Calculating...',
              icon: Zap,
              color: parseFloat(weather?.riskScore ?? '0') >= 8 ? 'text-red-500' : parseFloat(weather?.riskScore ?? '0') >= 6 ? 'text-orange-500' : 'text-yellow-500',
            },
          ].map((item, i) => (
            <div key={i} className={`${theme.cardBg} ${theme.cardBorder} rounded-2xl p-5 border flex flex-col gap-1 transition-all duration-500`}>
              <div className="flex items-center gap-2 mb-2">
                <item.icon className={`w-4 h-4 ${item.color}`} />
                <span className="text-[10px] font-black uppercase tracking-widest text-gray-400">{item.label}</span>
              </div>
              <p className={`text-xl font-black ${isNightVision ? 'text-white' : 'text-gray-800'} ${
                weather ? '' : 'animate-pulse'
              }`}>{item.val}</p>
              <p className={`text-[10px] font-bold ${item.color}`}>{item.info}</p>
            </div>
          ))}
        </div>
      </div>

      {/* ── Footer: Activity Marquee ── */}
      <div className={`h-12 flex items-center bg-black/95 text-white rounded-2xl overflow-hidden relative shadow-2xl border ${theme.cardBorder} shrink-0`}>
        <div className="px-6 h-full flex items-center bg-emerald-600 text-white font-black text-[12px] uppercase tracking-widest shrink-0 z-10">
          Live Surveillance
        </div>
        <div className="flex-1 overflow-hidden h-full flex items-center relative whitespace-nowrap">
          <div className="flex animate-marquee gap-12 items-center">
            {[
              "Barkheda Bondar: 12 new scans synced (9 confirmed Wheat Rust)",
              "Emergency: Alert acknowledged by 245 farmers in Sukhi Sewaniya",
              "System: Aerial drone unit 04 deployed for high-res multispectral mapping",
              "Hub Alpha: 2,500L fungicide requested by District Agriculture Office",
              "Insight: AI confirms 88% humidity correlation with infection spikes",
              "Success: Spread halted in 4 villages after rapid 2-hour intervention",
            ].map((text, i) => (
              <div key={i} className="flex items-center gap-4">
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                <span className="text-[11px] font-bold text-gray-200 tracking-tight">{text}</span>
              </div>
            ))}
          </div>
          {/* Duplicate for seamless infinite scroll */}
          <div className="flex animate-marquee gap-12 items-center pl-12" aria-hidden="true">
            {[
              "Barkheda Bondar: 12 new scans synced (9 confirmed Wheat Rust)",
              "Emergency: Alert acknowledged by 245 farmers in Sukhi Sewaniya",
              "System: Aerial drone unit 04 deployed for high-res multispectral mapping",
              "Hub Alpha: 2,500L fungicide requested by District Agriculture Office",
              "Insight: AI confirms 88% humidity correlation with infection spikes",
              "Success: Spread halted in 4 villages after rapid 2-hour intervention",
            ].map((text, i) => (
              <div key={i} className="flex items-center gap-4">
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                <span className="text-[11px] font-bold text-gray-200 tracking-tight">{text}</span>
              </div>
            ))}
          </div>
        </div>
        <style jsx>{`
          @keyframes marquee { 0% { transform: translateX(0); } 100% { transform: translateX(-100%); } }
          .animate-marquee { animation: marquee 35s linear infinite; }
          .custom-scrollbar::-webkit-scrollbar { width: 4px; }
          .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
          .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(16,185,129,0.1); border-radius: 10px; }
          .custom-scrollbar:hover::-webkit-scrollbar-thumb { background: rgba(16,185,129,0.2); }
        `}</style>
      </div>
    </div>
  );
}

function ScanIcon(props: any) {
  return (
    <svg {...props} fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 7V5a2 2 0 0 1 2-2h2" /><path d="M17 3h2a2 2 0 0 1 2 2v2" /><path d="M21 17v2a2 2 0 0 1-2 2h-2" /><path d="M7 21H5a2 2 0 0 1-2-2v-2" /><path d="M7 12h10" /><path d="M12 7v10" />
    </svg>
  );
}
