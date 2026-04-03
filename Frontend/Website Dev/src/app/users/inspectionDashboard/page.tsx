"use client";

/**
 * Inspection Dashboard — Page Orchestrator
 * ─────────────────────────────────────────────────────────────────────────────
 * Layout:
 *   [Sidebar] | [Header + {Map(55→25%) | MacroPanel(45%→0%→DistrictPanel(75%)]}]
 *
 * Map features:
 *   – Focused on India (zoom 4.5)
 *   – Discrete circular hotspot Markers (not heatmap) coloured orange→red
 *   – Bottom-right: Layer switcher (Map / Terrain / Satellite) — same style as fleet page
 *   – Top-left (post-transition only): disease summary card
 *   – On hotspot click: flyTo the clicked hotspot + swap right panel
 */

import { useState, useMemo, useRef, useEffect } from 'react';
import Map, { Marker } from 'react-map-gl/maplibre';
import 'maplibre-gl/dist/maplibre-gl.css';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import MacroSidePanel from '@/components/inspection/MacroSidePanel';
import DistrictAnalyticsPanel from '@/components/inspection/DistrictAnalyticsPanel';
import { T } from '@/components/inspection/themeTokens';

// ─── MAP STYLE DEFINITIONS (same pattern as fleet page) ──────────────────────
const SATELLITE_STYLE: any = {
  version: 8,
  sources: {
    'esri-satellite': {
      type: 'raster',
      tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'],
      tileSize: 256,
    },
  },
  layers: [{ id: 'satellite', type: 'raster', source: 'esri-satellite', minzoom: 0, maxzoom: 20 }],
};

const TERRAIN_STYLE: any = {
  version: 8,
  sources: {
    'esri-terrain': {
      type: 'raster',
      tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}'],
      tileSize: 256,
    },
  },
  layers: [{ id: 'terrain', type: 'raster', source: 'esri-terrain', minzoom: 0, maxzoom: 20 }],
};

const PLAIN_LIGHT = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json';
const PLAIN_DARK = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

// ─── HOTSPOT DATA ─────────────────────────────────────────────────────────────
// Each hotspot is a clickable marker. Severity 1–5 drives circle colour.
interface Hotspot {
  id: string;
  name: string;
  state: string;
  lng: number;
  lat: number;
  severity: 1 | 2 | 3 | 4 | 5;   // 1 = low (orange) … 5 = critical (red)
  disease: string;
  farmersAffected: number;
  cropLoss: string;
  status: string;
  zoom: number;  // target zoom on flyTo
}

// Severity → colour (yellow → red)
const SEVERITY_COLOR: Record<number, string> = {
  1: '#facc15',   // Yellow (1-3 scans)
  2: '#f59e0b',   // Amber (4-6 scans)
  3: '#f97316',   // Orange (7-14 scans)
  4: '#ef4444',   // Bright Red (15+ scans)
  5: '#dc2626',   // Deep Red (Severe outbreak / 20+ scans)
};
const SEVERITY_GLOW: Record<number, string> = {
  1: 'rgba(250, 204, 21, 0.4)',
  2: 'rgba(245, 158, 11, 0.5)',
  3: 'rgba(249, 115, 22, 0.6)',
  4: 'rgba(239, 68, 68, 0.65)',
  5: 'rgba(220, 38, 38, 0.7)',
};
// Size scales with severity (px diameter)
const SEVERITY_SIZE: Record<number, number> = { 1: 14, 2: 18, 3: 22, 4: 28, 5: 32 };
// Pulse opacity scales with severity
const SEVERITY_PULSE_OPACITY: Record<number, string> = { 1: 'opacity-10', 2: 'opacity-20', 3: 'opacity-30', 4: 'opacity-40', 5: 'opacity-60' };

// ─── PAGE ─────────────────────────────────────────────────────────────────────
export default function MacroInspectionDashboard() {
  const [isNightVision, setIsNightVision] = useState(false);
  const [isDistrictView, setIsDistrictView] = useState(false);
  const [activeHotspot, setActiveHotspot] = useState<Hotspot | null>(null);
  const [isStyleOpen, setIsStyleOpen] = useState(false);
  const [isMapExpanded, setIsMapExpanded] = useState(false);
  const [secondaryPoints, setSecondaryPoints] = useState<{ lng: number, lat: number, severity: number }[]>([]);
  const [hotspots, setHotspots] = useState<Hotspot[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch dynamic hotspots from the backend
  useEffect(() => {
    setIsLoading(true);
    fetch('/api/map-data')
      .then(res => res.json())
      .then(result => {
        if (result.status === "success") {
          const mappedHotspots: Hotspot[] = result.data.map((item: any) => {
            let calcSeverity: 1|2|3|4|5 = 1; // Default
            const count = item.intensity_count || 1;

            if (count >= 15) calcSeverity = 5;      
            else if (count >= 10) calcSeverity = 4; 
            else if (count >= 7) calcSeverity = 3;  
            else if (count >= 4) calcSeverity = 2;  

            return {
              id: item.id,
              name: item.district,
              state: "India",
              lng: item.lng,
              lat: item.lat,
              severity: calcSeverity,
              disease: item.disease,
              farmersAffected: count * 10,
              cropLoss: "Est. 10-20%",
              status: item.status,
              zoom: 10
            };
          });
          setHotspots(mappedHotspots);
        }
        setIsLoading(false);
      })
      .catch(err => {
        console.error(err);
        setIsLoading(false);
      });
  }, []);

  const [mapStyle, setMapStyle] = useState<any>(TERRAIN_STYLE);

  const mapRef = useRef<any>(null);
  const theme = isNightVision ? T.night : T.light;

  // ── Hotspot click ──────────────────────────────────────────────────────────
  const handleHotspotClick = (hs: Hotspot) => {
    setActiveHotspot(hs);
    setIsDistrictView(true);

    const points = Array.from({ length: 36 }).map(() => ({
      lng: hs.lng + (Math.random() - 0.5) * 0.45,
      lat: hs.lat + (Math.random() - 0.5) * 0.45,
      severity: Math.floor(Math.random() * 3) + 1 as any, 
    }));
    setSecondaryPoints(points);

    if (mapRef.current) {
      const map = mapRef.current.getMap();
      const offsetPixels = -window.innerWidth * 0.15;
      map.flyTo({
        center: [hs.lng, hs.lat],
        zoom: hs.zoom,
        offset: [offsetPixels, 0],
        duration: 2600,
        essential: true,
      });
    }
  };

  const handleBack = () => {
    setIsDistrictView(false);
    setActiveHotspot(null);
    setSecondaryPoints([]);
    
    if (mapRef.current) {
      const map = mapRef.current.getMap();
      // Incremental resize to catch layout shifts
      map.resize();
      
      // Delay flyTo until the transition is far enough along for accurate centering
      setTimeout(() => {
        map.resize(); // Final geometry sync
        map.flyTo({
          center: [78.9629, 23.5937],
          zoom: 4.2,
          offset: [0, 0],
          duration: 1500,
          essential: true,
        });
      }, 300);
    }
  };

  // ── Layer options ──────────────────────────────────────────────────────────
  const layerOptions = [
    {
      label: 'Map',
      style: isNightVision ? PLAIN_DARK : PLAIN_LIGHT,
      img: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=48&auto=format&fit=crop',
    },
    {
      label: 'Terrain',
      style: TERRAIN_STYLE,
      img: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=48&auto=format&fit=crop',
    },
    {
      label: 'Satellite',
      style: SATELLITE_STYLE,
      img: 'https://images.unsplash.com/photo-1446776858070-70c3d5ed8758?q=80&w=48&auto=format&fit=crop',
    },
  ];

  if (isLoading) return (
    <div className="p-6 bg-[#f6f8f6] min-h-screen flex gap-6 w-full font-['Inter',sans-serif]">
      {/* MAP PLACEHOLDER (Left) */}
      <div className="w-[55%] h-[calc(100vh-3rem)] bg-gray-200 rounded-[32px] animate-pulse relative overflow-hidden border-4 border-white shadow-lg">
         <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/40 to-transparent animate-[pulse_2s_ease-in-out_infinite] transform -skew-y-12"></div>
         {/* Floating Map UI Placeholders */}
         <div className="absolute top-8 left-1/2 transform -translate-x-1/2 h-12 w-56 bg-white/40 rounded-full backdrop-blur-md border border-white/20"></div>
         <div className="absolute bottom-10 left-10 h-16 w-48 bg-white/40 rounded-2xl backdrop-blur-md border border-white/20"></div>
         <div className="absolute bottom-10 right-10 h-32 w-14 bg-white/40 rounded-2xl backdrop-blur-md border border-white/20"></div>
      </div>

      {/* PANEL PLACEHOLDER (Right) */}
      <div className="flex-1 flex flex-col gap-6">
        {/* Header Skeleton */}
        <div className="flex justify-between items-center mb-2">
           <div className="h-10 w-64 bg-gray-200 rounded-xl animate-pulse"></div>
           <div className="h-10 w-10 bg-gray-800 rounded-full animate-pulse"></div>
        </div>
        {/* Detailed KPI Skeletons */}
        <div className="grid grid-cols-2 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-32 bg-white rounded-[24px] shadow-sm border border-gray-100 p-6 flex flex-col justify-between animate-pulse">
              <div className="h-3 w-24 bg-gray-100 rounded"></div>
              <div className="h-10 w-24 bg-gray-200 rounded-xl"></div>
            </div>
          ))}
        </div>
        {/* Graph Area */}
        <div className="flex-1 bg-white rounded-[24px] border border-gray-100 p-6 animate-pulse flex flex-col justify-center">
           <div className="h-4 w-48 bg-gray-100 rounded mb-8"></div>
           <div className="space-y-6">
              <div className="h-3 w-full bg-gray-50 rounded-full"></div>
              <div className="h-3 w-4/5 bg-gray-50 rounded-full"></div>
              <div className="h-3 w-3/4 bg-gray-50 rounded-full"></div>
              <div className="h-3 w-full bg-gray-50 rounded-full"></div>
           </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className={`h-screen flex overflow-hidden font-['Inter',sans-serif] transition-colors duration-500 ${theme.pageBg} ${isNightVision ? 'dark' : ''}`}>

      {/* ── SIDEBAR — always visible ────────────────────────────────────────── */}
      <div className="h-full w-[72px] shrink-0 z-[60]">
        <Sidebar isDarkMode={isNightVision} setIsDarkMode={setIsNightVision} />
      </div>

      {/* ── MAIN COLUMN ─────────────────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden relative">

        {/* HEADER — always visible */}
        <div className="px-4 pt-4 shrink-0 z-50 relative">
          <Header title="AgriSense Health & Outbreak Radar" />
        </div>

        {/* ── CONTENT ROW ─────────────────────────────────────────────────────── */}
        <div className="flex-1 flex overflow-hidden p-4 pt-3 gap-4 min-h-0">

          {/* ══ MAP ════════════════════════════════════════════════════════════ */}
          <div
            className={`relative overflow-hidden rounded-[24px] border transition-all duration-700 ease-[cubic-bezier(0.16,1,0.3,1)]
              ${theme.cardBorder} shadow-[0_4px_30px_rgba(16,185,129,0.08)]
              ${isMapExpanded ? 'w-full grow' : (isDistrictView ? 'w-[25%]' : 'w-[55%]')} shrink-0`}
          >
            <Map
              ref={mapRef}
              initialViewState={{ longitude: 78.9629, latitude: 23.5937, zoom: 4.2 }}
              mapStyle={mapStyle}
              style={{ width: '100%', height: '100%' }}
              attributionControl={false}
              onIdle={() => mapRef.current?.getMap().resize()}
            >

              {/* ── HOTSPOT MARKERS ── */}
              {hotspots.map(hs => {
                const size = SEVERITY_SIZE[hs.severity];
                const color = SEVERITY_COLOR[hs.severity];
                const glow = SEVERITY_GLOW[hs.severity];
                const pulseOpacity = SEVERITY_PULSE_OPACITY[hs.severity];
                const isActive = activeHotspot?.id === hs.id;

                return (
                  <Marker key={hs.id} longitude={hs.lng} latitude={hs.lat} anchor="center">
                    <button
                      onClick={() => handleHotspotClick(hs)}
                      className="relative flex items-center justify-center cursor-pointer focus:outline-none group"
                      style={{ width: size + 16, height: size + 16 }}
                      title={`${hs.name} — ${hs.disease}`}
                    >
                      <span
                        className={`absolute inset-0 rounded-full animate-ping ${pulseOpacity}`}
                        style={{ backgroundColor: color }}
                      />
                      <span
                        className={`relative rounded-full transition-all duration-300 group-hover:scale-110 ${isActive ? 'ring-2 ring-white ring-offset-1' : ''}`}
                        style={{
                          width: size, height: size,
                          backgroundColor: color,
                          boxShadow: `0 0 ${hs.severity * 5}px ${glow}`,
                        }}
                      />
                      <span className={`absolute -top-8 left-1/2 -translate-x-1/2 whitespace-nowrap text-[10px] font-black px-2 py-0.5 rounded-full pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-200 backdrop-blur-md shadow-lg
                        ${isNightVision ? 'bg-black/80 text-[#39ff5e]' : 'bg-white/90 text-gray-800'}`}
                      >
                        {hs.name}
                      </span>
                    </button>
                  </Marker>
                );
              })}

              {/* ── SECONDARY HEATMAP CLUSTERS ── */}
              {isDistrictView && activeHotspot && secondaryPoints.map((p: any, i: number) => {
                const size = SEVERITY_SIZE[p.severity as 1 | 2 | 3 | 4 | 5] * 0.8;
                const color = SEVERITY_COLOR[p.severity as 1 | 2 | 3 | 4 | 5];
                const glow = SEVERITY_GLOW[p.severity as 1 | 2 | 3 | 4 | 5];

                return (
                  <Marker key={`secondary-${i}`} longitude={p.lng} latitude={p.lat} anchor="center">
                    <div
                      className="rounded-full blur-[10px] opacity-40 transition-all duration-1000 animate-in fade-in zoom-in-50"
                      style={{
                        width: size, height: size,
                        background: `radial-gradient(circle, ${color} 0%, transparent 70%)`,
                        boxShadow: `0 0 24px ${glow}`,
                      }}
                    />
                  </Marker>
                );
              })}

              {/* ── DISEASE SUMMARY CARD ── */}
              {isDistrictView && activeHotspot && (
                <div className="absolute top-3 left-3 z-30 animate-in" style={{ animationDuration: '0.5s' }}>
                  <div className={`${theme.cardBg} ${theme.cardBorder} rounded-[16px] p-3.5 shadow-xl w-52 border`}>
                    <div className="flex items-center gap-2 mb-2">
                      <span
                        className="w-2.5 h-2.5 rounded-full shrink-0 animate-pulse"
                        style={{ backgroundColor: SEVERITY_COLOR[activeHotspot!.severity] }}
                      />
                      <p className={`text-[9px] font-black uppercase tracking-widest ${theme.sectionLabel} leading-tight`}>
                        {activeHotspot!.state} · {activeHotspot!.status}
                      </p>
                    </div>
                    <p className={`text-sm font-extrabold ${theme.value} leading-tight mb-0.5`}>
                      {activeHotspot!.name} District
                    </p>
                    <p className={`text-[11px] font-bold ${theme.accent} mb-3`}>
                      {activeHotspot!.disease}
                    </p>
                    <div className={`flex gap-3 pt-2.5 border-t ${theme.accentBorder}`}>
                      <div>
                        <p className={`text-xs font-black ${theme.value}`}>
                          {activeHotspot!.farmersAffected.toLocaleString()}
                        </p>
                        <p className={`text-[9px] ${theme.subText}`}>Farmers</p>
                      </div>
                      <div className={`w-px ${theme.accentBorder} border-l`} />
                      <div>
                        <p className={`text-xs font-black ${theme.accent}`}>{activeHotspot!.cropLoss}</p>
                        <p className={`text-[9px] ${theme.subText}`}>Crop Loss</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* ── LOCATION LABEL ── */}
              {!isDistrictView && (
                <div className="absolute top-3 left-3 z-10">
                  <div className={`${theme.cardBg} ${theme.cardBorder} rounded-[14px] px-3 py-2 shadow-lg`}>
                    <p className={`text-sm font-extrabold ${theme.value} leading-tight`}>India Disease Map</p>
                    <p className={`text-[10px] font-semibold ${theme.subText} mt-0.5`}>
                      {hotspots.length} active hotspots · Click to inspect
                    </p>
                  </div>
                </div>
              )}

              {/* ── MAP CONTROLS ── */}
              <div className="absolute top-3 right-3 z-10 flex flex-col gap-1.5">
                {/* Expand Toggle */}
                <button
                  onClick={() => setIsMapExpanded(!isMapExpanded)}
                  className={`w-8 h-8 rounded-xl ${theme.cardBg} ${theme.cardBorder} shadow flex items-center justify-center font-bold text-base ${theme.accent} hover:opacity-80 transition`}
                  title={isMapExpanded ? "Restore View" : "Expand Map"}
                >
                  {isMapExpanded ? (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5v-4m0 4h-4m4 0l-5-5" />
                    </svg>
                  ) : (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5v-4m0 4h-4m4 0l-5-5" />
                    </svg>
                  )}
                </button>
                {/* Zoom Controls */}
                <button
                  onClick={() => mapRef.current?.getMap().zoomIn()}
                  className={`w-8 h-8 rounded-xl ${theme.cardBg} ${theme.cardBorder} shadow flex items-center justify-center font-bold text-base ${theme.accent} hover:opacity-80 transition`}
                >+</button>
                <button
                  onClick={() => mapRef.current?.getMap().zoomOut()}
                  className={`w-8 h-8 rounded-xl ${theme.cardBg} ${theme.cardBorder} shadow flex items-center justify-center font-bold text-base ${theme.subText} hover:opacity-80 transition`}
                >−</button>
                {/* Recenter */}
                <button
                  onClick={handleBack}
                  className={`w-8 h-8 rounded-xl ${theme.cardBg} ${theme.cardBorder} shadow flex items-center justify-center ${theme.accent} hover:opacity-80 transition`}
                  title="Reset view"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                      d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
                  </svg>
                </button>
              </div>

              {/* ── LAYER SWITCHER ── */}
              <div className="absolute bottom-5 right-5 z-20">
                {isStyleOpen && (
                  <div className="absolute bottom-[96px] right-0 bg-[#1c2432]/85 backdrop-blur-xl rounded-2xl border border-white/10 shadow-2xl overflow-hidden animate-in mb-1"
                    style={{ animationDuration: '0.2s' }}
                  >
                    <div className="px-3 pt-3 pb-1">
                      <span className="text-[9px] font-bold text-white/40 uppercase tracking-widest">View Mode</span>
                    </div>
                    <div className="flex flex-col pb-2">
                       {layerOptions.map(({ label, style, img }) => {
                        const isSelected = JSON.stringify(mapStyle) === JSON.stringify(style);
                        return (
                          <button
                            key={label}
                            onClick={() => { setMapStyle(style); setIsStyleOpen(false); }}
                            className={`flex items-center gap-3 mx-2 mb-1 px-3 py-2 rounded-xl text-[12px] font-bold transition-all text-left ${isSelected ? 'bg-green-500/30 text-white ring-1 ring-green-500/60' : 'text-white/60 hover:text-white hover:bg-white/10'}`}
                          >
                            <img src={img} className="w-8 h-8 rounded-lg object-cover shrink-0" alt={label} />
                            {label}
                            {isSelected && <span className="ml-auto w-1.5 h-1.5 rounded-full bg-green-400" />}
                          </button>
                        );
                      })}
                    </div>
                  </div>
                )}
                <div
                  onClick={() => setIsStyleOpen(v => !v)}
                  className={`w-[72px] h-[72px] rounded-[18px] shadow-2xl cursor-pointer flex flex-col items-center justify-center gap-1.5 transition-all active:scale-95 border backdrop-blur-xl ${isStyleOpen ? 'bg-[#2a3444]/90 border-green-500/40' : 'bg-[#1c2838]/80 border-white/10 hover:border-white/20'}`}
                >
                  <svg className="w-6 h-6 text-white/80" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M12 2L2 7l10 5 10-5-10-5z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M2 12l10 5 10-5" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M2 17l10 5 10-5" />
                  </svg>
                  <span className="text-[9px] font-bold text-white/70">Layers</span>
                </div>
              </div>

              {/* Severity legend */}
              {!isDistrictView && (
                <div className="absolute bottom-5 left-4 z-10">
                  <div className={`${theme.cardBg} ${theme.cardBorder} rounded-[14px] px-3 py-2.5 shadow-lg`}>
                    <p className={`text-[8px] font-black uppercase tracking-widest ${theme.sectionLabel} mb-2`}>Outbreak Severity</p>
                    <div className="flex items-center gap-1.5">
                      {[1, 2, 3, 4, 5].map(s => (
                        <div key={s} className="flex flex-col items-center gap-1">
                          <div className="rounded-full" style={{ width: SEVERITY_SIZE[s] * 0.45, height: SEVERITY_SIZE[s] * 0.45, backgroundColor: SEVERITY_COLOR[s] }} />
                        </div>
                      ))}
                      <div className={`flex justify-between w-full ml-1 text-[8px] font-bold ${theme.subText}`}>
                        <span>Low</span><span className="ml-4">High</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </Map>
          </div>

          {/* ══ PANEL CONTAINERS ═══════════════════════════════════════════════ */}
          <div className={`transition-all duration-700 ease-[cubic-bezier(0.16,1,0.3,1)] overflow-hidden flex flex-col gap-4
            ${isMapExpanded ? 'w-0 opacity-0 pointer-events-none' : 'flex-1 opacity-100'}`}
          >
            {isDistrictView ? (
              <div className={`h-full rounded-[24px] border ${theme.cardBorder} ${theme.sidePanel} shadow-[0_4px_30px_rgba(16,185,129,0.06)] overflow-hidden`}>
                <DistrictAnalyticsPanel
                  theme={theme}
                  isNightVision={isNightVision}
                  districtName={activeHotspot?.name ?? 'District'}
                  lat={activeHotspot?.lat}
                  lng={activeHotspot?.lng}
                  onBack={handleBack}
                />
              </div>
            ) : (
              <MacroSidePanel theme={theme} isNightVision={isNightVision} />
            )}
          </div>

        </div>
      </div>
    </div>
  );
}
