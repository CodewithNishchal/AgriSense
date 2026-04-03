"use client";

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Map, { Marker } from 'react-map-gl/maplibre';
import 'maplibre-gl/dist/maplibre-gl.css';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import FleetNavTabs from '@/components/FleetNavTabs';

const SATELLITE_STYLE = {
  version: 8,
  sources: {
    'esri-satellite': {
      type: 'raster',
      tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'],
      tileSize: 256
    }
  },
  layers: [{ id: 'satellite', type: 'raster', source: 'esri-satellite', minzoom: 0, maxzoom: 20 }]
};

const TERRAIN_STYLE = {
  version: 8,
  sources: {
    'esri-terrain': {
      type: 'raster',
      tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}'],
      tileSize: 256
    }
  },
  layers: [{ id: 'terrain', type: 'raster', source: 'esri-terrain', minzoom: 0, maxzoom: 20 }]
};

const VOYAGER_STYLE = 'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json';

export default function AvailableAssets() {
  const [isMapExpanded, setIsMapExpanded] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [mapStyle, setMapStyle] = useState<any>(SATELLITE_STYLE);
  const [isStyleDropdownOpen, setIsStyleDropdownOpen] = useState(false);
  const [viewState, setViewState] = useState({ longitude: 11.3705, latitude: 43.3194, zoom: 15 });

  const zoomIn = () => setViewState(prev => ({ ...prev, zoom: Math.min(prev.zoom + 1, 20) }));
  const zoomOut = () => setViewState(prev => ({ ...prev, zoom: Math.max(prev.zoom - 1, 1) }));

  return (
    <div className={`h-screen flex p-4 gap-6 text-gray-800 dark:text-gray-200 overflow-hidden box-border font-['Inter',sans-serif] bg-[#f6f8f6] dark:bg-[#0f172a] transition-colors duration-500 ${isDarkMode ? 'dark' : ''}`}>
      <Sidebar isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} />

      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <Header />

        <div className="flex-1 flex gap-6 overflow-hidden mt-6">
          <main className="flex-1 flex flex-col min-w-0 overflow-y-auto no-scrollbar gap-6 pb-4">

            {/* — Tab Navigator — */}
            <FleetNavTabs />

            {/* — Stats Grid — */}
            <div className="grid grid-cols-2 gap-6">
              <div className="grid grid-cols-2 gap-5">
                {[
                  { label: 'Total Fleet', value: '22', unit: 'Units' },
                  { label: 'Asset Categories', value: '4', unit: 'Types' },
                  { label: 'Daily Revenue', value: '$2.3k', unit: 'Est.' },
                  { label: 'Usage Time', value: '4k', unit: 'Hours' },
                ].map(({ label, value, unit }) => (
                  <div key={label} className="bg-white dark:bg-[#1e293b] p-5 rounded-[24px] shadow-[0_4px_20px_-4px_rgba(0,0,0,0.03)] border border-gray-50 dark:border-gray-800 flex flex-col justify-between h-32 transition-colors">
                    <div className="flex justify-between text-gray-400 text-xs font-bold uppercase tracking-wider">{label} <span className="text-xl text-gray-300 dark:text-gray-600">..</span></div>
                    <div className="text-4xl font-extrabold flex items-baseline gap-1 text-[#1c2432] dark:text-white">{value} <span className="text-sm font-semibold text-gray-400">{unit}</span></div>
                  </div>
                ))}
              </div>

              {/* Weather Card */}
              <div className="bg-white dark:bg-[#1e293b] p-8 rounded-[24px] shadow-[0_4px_20px_-4px_rgba(0,0,0,0.03)] border border-gray-50 dark:border-gray-800 flex flex-col justify-between h-[280px] transition-colors">
                <div className="flex justify-between items-start">
                  <div className="font-bold text-gray-800 dark:text-gray-100 text-[15px]">Weather</div>
                  <div className="text-right text-xs font-bold text-gray-600 dark:text-gray-300 space-y-2">
                    <div className="flex items-center gap-2 justify-end"><svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" /></svg> Cloudy</div>
                    <div className="flex items-center gap-2 justify-end"><svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg> Wind</div>
                    <div className="flex items-center gap-2 justify-end"><svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" /></svg> 62%</div>
                  </div>
                </div>
                <div className="text-center mt-[-10px]"><span className="text-[42px] font-extrabold text-gray-800 dark:text-white">30°</span></div>
                <div className="relative mt-2">
                  <div className="flex justify-between text-[11px] font-bold text-gray-400 mb-2 px-1"><span>27°</span><span>28°</span><span>30°</span><span>31°</span></div>
                  <div className="h-9 flex rounded-full overflow-hidden shadow-inner border border-gray-100/50 dark:border-gray-700/50 p-1 bg-white dark:bg-[#0f172a] gap-1 relative transition-colors">
                    <div className="w-1/2 h-full rounded-l-full opacity-90 drop-shadow-md" style={{ background: 'repeating-linear-gradient(45deg, #4ade80, #4ade80 4px, #22c55e 4px, #22c55e 8px)' }}></div>
                    <div className="w-1/2 h-full rounded-r-full opacity-90 drop-shadow-md" style={{ background: 'repeating-linear-gradient(45deg, #facc15, #facc15 4px, #eab308 4px, #eab308 8px)' }}></div>
                  </div>
                </div>
              </div>
            </div>

            {/* — Charts Row — */}
            <div className="grid grid-cols-2 gap-6">
              {/* Asset Distribution */}
              <div className="bg-[#6b9d6c] p-8 rounded-[28px] text-white shadow-lg relative overflow-hidden h-[300px]">
                <div className="absolute top-[-30%] right-[-10%] w-[130%] h-[130%] bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-white/30 via-transparent to-transparent opacity-90 mix-blend-overlay"></div>
                <div className="absolute inset-0 bg-gradient-to-br from-black/0 via-black/0 to-black/10"></div>
                <div className="flex justify-between items-start mb-4 relative z-10">
                  <h3 className="font-semibold text-[17px] leading-tight w-2/3">Asset Distribution &<br />Maintenance Conditions</h3>
                  <span className="text-xl font-bold tracking-widest leading-none mt-1">..</span>
                </div>
                <div className="space-y-4 relative z-10 w-full mt-2">
                  {[
                    { label: 'Standard Tractors', count: '12 Units', fill: 70, dot: '#4ade80' },
                    { label: 'Heavy Duty', count: '6 Units', fill: 40, dot: '#facc15' },
                    { label: 'Compact', count: '4 Units', fill: 20, dot: '#facc15' },
                  ].map(({ label, count, fill, dot }) => (
                    <div key={label}>
                      <div className="flex justify-between text-[13px] font-medium mb-2"><span>{label}</span><span>{count}</span></div>
                      <div className="w-full bg-black/15 h-[22px] rounded-xl flex items-center overflow-hidden pr-2 gap-2 shadow-[inset_0_1px_4px_rgba(0,0,0,0.15)]">
                        <div className="h-full bg-gradient-to-r from-white/0 via-white/50 to-white/95 rounded-r-lg" style={{ width: `${fill}%` }}></div>
                        <div className="h-1.5 rounded-full w-[20%] drop-shadow-[0_0_4px_rgba(74,222,128,0.8)]" style={{ backgroundColor: dot }}></div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Fleet Utilization */}
              <div className="bg-white dark:bg-[#1e293b] p-8 rounded-[28px] shadow-[0_4px_20px_-4px_rgba(0,0,0,0.03)] border border-gray-50 dark:border-gray-800 flex flex-col h-[300px] transition-colors">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="font-bold text-[17px] text-gray-800 dark:text-gray-100">Fleet Utilization</h3>
                  <span className="text-xl font-bold tracking-widest leading-none mt-1 text-gray-400">..</span>
                </div>
                <div className="flex-1 relative flex items-center justify-center">
                  <div className="w-40 h-40 rounded-full relative flex items-center justify-center" style={{ background: 'conic-gradient(#6b9d6c 0% 61%, #d1dec2 61% 72%, #8ab98c 72% 100%)' }}>
                    <div className="w-[104px] h-[104px] bg-white dark:bg-[#1e293b] rounded-full flex flex-col items-center justify-center absolute shadow-inner z-10 transition-colors">
                      <span className="text-[10px] text-gray-400 font-bold uppercase tracking-wide">Overall Score</span>
                      <span className="text-3xl font-extrabold text-gray-800 dark:text-white mt-1">72%</span>
                    </div>
                    <div className="absolute -top-3 left-6 bg-white dark:bg-gray-800 shadow-sm rounded-lg px-2.5 py-1.5 text-xs text-gray-600 dark:text-gray-200 font-bold border border-gray-100 dark:border-gray-700 z-20">61%</div>
                    <div className="absolute top-2 -right-4 bg-white dark:bg-gray-800 shadow-sm rounded-lg px-2.5 py-1.5 text-xs text-gray-600 dark:text-gray-200 font-bold border border-gray-100 dark:border-gray-700 z-20">36%</div>
                    <div className="absolute bottom-1 -right-4 bg-white dark:bg-gray-800 shadow-sm rounded-lg px-2.5 py-1.5 text-xs text-gray-600 dark:text-gray-200 font-bold border border-gray-100 dark:border-gray-700 z-20">79%</div>
                  </div>
                </div>
                <div className="flex justify-center gap-5 text-xs font-bold text-gray-500 mt-2">
                  {[['#6b9d6c', 'Rented'], ['#8ab98c', 'Idle'], ['#d1dec2', 'Service']].map(([c, l]) => (
                    <div key={l} className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: c }}></div>{l}</div>
                  ))}
                </div>
              </div>
            </div>

            {/* — Activity Cards — */}
            <div className="grid grid-cols-3 gap-6 mt-auto">
              {[
                { img: '/images/dashboard/tractor_maintenance.png', badge: 'Done', badgeBg: 'bg-white', dot: 'bg-green-500', dotGlow: 'rgba(34,197,94,0.8)', title: 'Tractor TRC-05', sub: 'Maintenance' },
                { img: '/images/dashboard/harvester_dispatch.png', badge: 'Progress', badgeBg: 'bg-[#fef08a]', dot: 'bg-yellow-500', dotGlow: 'rgba(234,179,8,0.8)', title: 'Dispatching Harvester', sub: 'BKH-08 to South Field' },
                { img: '/images/dashboard/combine_waiting.png', badge: 'Waiting', badgeBg: 'bg-white', dot: 'bg-gray-500', dotGlow: 'rgba(107,114,128,0.8)', title: 'Harvesting & Return', sub: 'Combine BKH-#4' },
              ].map(({ img, badge, badgeBg, dot, dotGlow, title, sub }) => (
                <div key={title} className="relative h-[150px] rounded-[24px] overflow-hidden group cursor-pointer shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] flex items-end">
                  <img src={img} className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent z-10"></div>
                  <div className={`absolute top-3 left-3 z-20 px-3 py-1.5 ${badgeBg} shadow-sm rounded-full text-[11px] font-extrabold text-gray-800 flex items-center gap-2`}>
                    <div className={`w-2 h-2 rounded-full ${dot}`} style={{ boxShadow: `0 0 6px ${dotGlow}` }}></div>{badge}
                  </div>
                  <div className="relative z-20 text-white font-medium text-[15px] leading-tight p-4">{title}<br />{sub}</div>
                </div>
              ))}
            </div>
          </main>

          {/* — Map Panel — */}
          <aside className={isMapExpanded ? 'fixed inset-4 z-[100] rounded-[32px] overflow-hidden shadow-2xl border-4 border-white transition-all duration-500 bg-gray-100 flex flex-col' : 'w-[40%] min-w-[500px] h-full relative rounded-[32px] overflow-hidden shadow-lg border-4 border-white flex-shrink-0 transition-all duration-500 bg-gray-100 flex flex-col'}>
            <div className="absolute inset-0 z-0">
              <Map {...viewState} onMove={evt => setViewState(evt.viewState)} mapStyle={mapStyle} style={{ width: '100%', height: '100%' }} attributionControl={false}>

                {/* Floating Top Indicator */}
                <div className="absolute top-4 left-1/2 -translate-x-1/2 z-10 flex gap-1 bg-[#1c2432]/40 backdrop-blur-xl p-1.5 rounded-[24px] border border-white/10 shadow-2xl">
                  <div className="px-6 py-2 flex flex-col items-center border-r border-white/10">
                    <span className="text-[10px] text-white/70 font-bold uppercase tracking-wider">Available</span>
                    <span className="text-xl font-extrabold text-white">14</span>
                  </div>
                  <div className="px-6 py-2 flex flex-col items-center">
                    <span className="text-[10px] text-white/70 font-bold uppercase tracking-wider">Rented</span>
                    <span className="text-xl font-extrabold text-white">8</span>
                  </div>
                </div>

                <Marker longitude={11.3705} latitude={43.3194} anchor="center">
                  <div className="flex items-center gap-2 px-4 py-2.5 bg-[#6b9d6c]/80 backdrop-blur-md border border-white/30 rounded-full shadow-xl">
                    <div className="w-3 h-3 rounded-full bg-white animate-ping absolute opacity-70"></div>
                    <div className="w-3 h-3 rounded-full bg-white relative"></div>
                    <span className="text-sm font-bold text-white whitespace-nowrap">Current Location</span>
                  </div>
                </Marker>
                <Marker longitude={11.3600} latitude={43.3122} anchor="center">
                  <div className="flex items-center gap-2 px-4 py-2.5 bg-[#1c2432]/60 backdrop-blur-md border border-white/20 rounded-full shadow-xl">
                    <div className="w-2.5 h-2.5 rounded-full bg-yellow-400"></div>
                    <span className="text-sm font-bold text-white whitespace-nowrap">Rented · Tractor #A1</span>
                  </div>
                </Marker>
                <Marker longitude={11.3820} latitude={43.3268} anchor="center">
                  <div className="flex items-center gap-2 px-4 py-2.5 bg-[#1c2432]/60 backdrop-blur-md border border-white/20 rounded-full shadow-xl">
                    <div className="w-2.5 h-2.5 rounded-full bg-yellow-400"></div>
                    <span className="text-sm font-bold text-white whitespace-nowrap">Rented · Tractor #B3</span>
                  </div>
                </Marker>
                <Marker longitude={11.3610} latitude={43.3262} anchor="center">
                  <div className="flex items-center gap-2 px-4 py-2.5 bg-[#1c2432]/60 backdrop-blur-md border border-white/20 rounded-full shadow-xl">
                    <div className="w-2.5 h-2.5 rounded-full bg-green-400"></div>
                    <span className="text-sm font-bold text-white whitespace-nowrap">Available · Tractor #C2</span>
                  </div>
                </Marker>
                <Marker longitude={11.3810} latitude={43.3122} anchor="center">
                  <div className="flex flex-col items-center gap-2 cursor-pointer">
                    <div className="w-4 h-4 rounded-full bg-red-500 shadow-[0_0_15px_rgba(239,68,68,0.8)] animate-pulse relative">
                      <div className="absolute inset-0 rounded-full bg-red-500 animate-ping opacity-75"></div>
                    </div>
                    <div className="px-4 py-2.5 bg-[#1c2432]/60 backdrop-blur-md border border-white/20 rounded-full shadow-xl">
                      <span className="text-sm font-bold text-white whitespace-nowrap">Rented · Needs Maintenance</span>
                    </div>
                  </div>
                </Marker>

                {/* Zoom + Recenter Controls */}
                <div className="absolute bottom-6 right-6 z-20 flex flex-col gap-3">
                  <div onClick={() => setViewState(prev => ({ ...prev, longitude: 11.3705, latitude: 43.3194, zoom: 15 }))} className="w-11 h-11 bg-white dark:bg-[#1e293b] rounded-full shadow-xl flex items-center justify-center cursor-pointer hover:bg-gray-50 border border-gray-100 dark:border-gray-800 transition-transform active:scale-95">
                    <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
                  </div>
                  <div className="flex flex-col bg-white dark:bg-[#1e293b] rounded-[22px] shadow-xl border border-gray-100 dark:border-gray-800 overflow-hidden">
                    <div onClick={zoomIn} className="w-11 h-11 flex items-center justify-center cursor-pointer hover:bg-gray-50 border-b border-gray-50 group"><span className="text-2xl font-bold text-gray-400 group-hover:text-green-500">+</span></div>
                    <div onClick={zoomOut} className="w-11 h-11 flex items-center justify-center cursor-pointer hover:bg-gray-50 group"><span className="text-2xl font-bold text-gray-400 group-hover:text-green-500">-</span></div>
                  </div>
                </div>

                {/* Layers / Style Switcher */}
                <div className="absolute bottom-6 left-6 z-20">
                  {isStyleDropdownOpen && (
                    <div className="absolute bottom-[100px] left-0 bg-[#1c2432]/80 backdrop-blur-xl rounded-2xl border border-white/10 shadow-2xl overflow-hidden animate-in mb-1">
                      <div className="px-3 pt-3 pb-1"><span className="text-[9px] font-bold text-white/40 uppercase tracking-widest">View Mode</span></div>
                      <div className="flex flex-col pb-2">
                        {[
                          { label: 'Map', style: VOYAGER_STYLE, img: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=48&auto=format&fit=crop' },
                          { label: 'Terrain', style: TERRAIN_STYLE, img: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=48&auto=format&fit=crop' },
                          { label: 'Satellite', style: SATELLITE_STYLE, img: 'https://images.unsplash.com/photo-1446776858070-70c3d5ed8758?q=80&w=48&auto=format&fit=crop' },
                        ].map(({ label, style, img }) => (
                          <button key={label} onClick={() => { setMapStyle(style); setIsStyleDropdownOpen(false); }}
                            className={`flex items-center gap-3 mx-2 mb-1 px-3 py-2 rounded-xl text-[12px] font-bold transition-all text-left ${mapStyle === style ? 'bg-green-500/30 text-white ring-1 ring-green-500/60' : 'text-white/60 hover:text-white hover:bg-white/10'}`}>
                            <img src={img} className="w-8 h-8 rounded-lg object-cover flex-shrink-0" alt={label} />
                            {label}
                            {mapStyle === style && <span className="ml-auto w-1.5 h-1.5 rounded-full bg-green-400"></span>}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                  <div onClick={() => setIsStyleDropdownOpen(!isStyleDropdownOpen)}
                    className={`w-[80px] h-[80px] rounded-[18px] shadow-2xl cursor-pointer flex flex-col items-center justify-center gap-1.5 transition-all active:scale-95 border backdrop-blur-xl ${isStyleDropdownOpen ? 'bg-[#2a3444]/90 border-green-500/40' : 'bg-[#1c2838]/80 border-white/10 hover:border-white/20'}`}>
                    <svg className="w-7 h-7 text-white/80" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M12 2L2 7l10 5 10-5-10-5z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M2 12l10 5 10-5" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M2 17l10 5 10-5" />
                    </svg>
                    <span className="text-[10px] font-bold text-white/70">Layers</span>
                  </div>
                </div>

                {/* Expand Toggle */}
                <div onClick={() => setIsMapExpanded(!isMapExpanded)} className="absolute top-4 right-4 z-20 w-11 h-11 bg-white shadow-xl rounded-full flex items-center justify-center cursor-pointer hover:bg-gray-50 border border-gray-100 transition-all active:scale-95">
                  {isMapExpanded
                    ? <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M6 18L18 6M6 6l12 12" /></svg>
                    : <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" /></svg>
                  }
                </div>
              </Map>
            </div>
          </aside>
        </div>
      </div>
    </div>
  );
}
