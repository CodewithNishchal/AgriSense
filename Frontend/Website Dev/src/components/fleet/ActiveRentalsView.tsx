"use client";

import { useState, useRef } from 'react';
import Map, { Marker } from 'react-map-gl/maplibre';
import 'maplibre-gl/dist/maplibre-gl.css';
import useSWR from 'swr';

const fetcher = (url: string) => fetch(url).then(res => res.json());

const SATELLITE_STYLE = {
  version: 8,
  sources: { 'sat': { type: 'raster', tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'], tileSize: 256 } },
  layers: [{ id: 'sat', type: 'raster', source: 'sat', minzoom: 0, maxzoom: 20 }]
};

const TERRAIN_STYLE = {
  version: 8,
  sources: { 'ter': { type: 'raster', tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}'], tileSize: 256 } },
  layers: [{ id: 'ter', type: 'raster', source: 'ter', minzoom: 0, maxzoom: 20 }]
};

const STREET_STYLE = {
  version: 8,
  sources: { 'voy': { type: 'raster', tiles: ['https://basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}{r}.png'], tileSize: 256 } },
  layers: [{ id: 'voy', type: 'raster', source: 'voy', minzoom: 0, maxzoom: 20 }]
};

const getSessionProgress = (start: string, end: string) => {
  const startTime = new Date(start).getTime();
  const endTime = new Date(end).getTime();
  const now = Date.now();
  const total = endTime - startTime;
  const elapsed = now - startTime;
  const progress = Math.min(Math.max((elapsed / total) * 100, 0), 100);
  const formatDiff = (ms: number) => {
      const h = Math.floor(ms / 3600000);
      const m = Math.floor((ms % 3600000) / 60000);
      return `${h}h ${m}m`;
  };
  return { progress: Math.round(progress), elapsed: formatDiff(elapsed), remaining: formatDiff(Math.max(endTime - now, 0)) };
};

export function ActiveRentalsContent({ sessions, telematics }: { sessions: any[], telematics: any }) {
  const activeEarningRate = sessions.reduce((sum, s) => sum + parseFloat(s.hourly_rate_usd || 0), 0);
  const upcomingReturns = sessions.filter(s => (new Date(s.expected_end_time).getTime() - Date.now()) < 3600000).length;
  const boundaryAlerts = telematics.activeAlerts.filter((a: any) => a.alert_type.includes('Geofence')).length;
  const engineWarning = telematics.activeAlerts.find((a: any) => a.alert_type.includes('Temp'));

  return (
    <div className="flex flex-col gap-4">
      {/* Live Ledger */}
      <div className="bg-white dark:bg-[#1e293b] rounded-[20px] border border-gray-100 dark:border-gray-800 shadow-sm flex-shrink-0">
        <div className="flex items-center justify-between px-5 pt-4 pb-3 border-b border-gray-50 dark:border-gray-800">
          <h3 className="font-bold text-[14px] text-gray-800 dark:text-white uppercase tracking-wider">Live Ledger: Current Sessions <span className="text-gray-400 font-semibold">({sessions.length} Active)</span></h3>
        </div>
        <div className="px-5 pb-4">
          <div className="grid grid-cols-[1.2fr_1fr_2fr_1fr] gap-3 text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-3 mb-2 px-1">
            <span>Asset Tag</span><span>Renter Name</span><span>Time Progress Bar</span><span>Live Status</span>
          </div>
          {sessions.map((s, i) => {
            const { progress, elapsed, remaining } = getSessionProgress(s.start_time, s.expected_end_time);
            const statusType = telematics.activeAlerts.some((a:any) => a.asset_tag === s.asset_tag) ? 'err' : (progress > 80 ? 'warn' : 'ok');
            return (
              <div key={s.session_id} className={`grid grid-cols-[1.2fr_1fr_2fr_1fr] gap-3 items-center py-2.5 px-1 ${i < sessions.length - 1 ? 'border-b border-gray-50 dark:border-gray-800/60' : ''}`}>
                <div>
                    <div className="text-[12px] font-bold text-gray-700 dark:text-gray-200">{s.category}</div>
                    <div className="text-[11px] text-gray-400 font-semibold">{s.asset_tag}</div>
                </div>
                <div className="text-[12px] font-bold text-blue-500">{s.renter_name}</div>
                <div>
                  <div className="flex items-center gap-2 text-[11px] text-gray-500 mb-1">
                    <span className="font-bold text-gray-700 dark:text-gray-200">{elapsed}</span>
                    <div className="flex-1 h-1.5 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
                      <div className={`h-full rounded-full transition-all ${statusType === 'ok' ? 'bg-green-500' : statusType === 'warn' ? 'bg-orange-400' : 'bg-red-500'}`} style={{ width: `${progress}%` }}></div>
                    </div>
                    <span className="text-gray-400">{remaining}</span>
                  </div>
                </div>
                <div className={`text-[11px] font-bold flex items-center gap-1.5 ${statusType === 'ok' ? 'text-green-600' : 'text-red-500'}`}>
                    <span className={`w-2 h-2 rounded-full ${statusType === 'ok' ? 'bg-green-500' : 'bg-red-500 animate-pulse'}`}></span>
                    {statusType === 'ok' ? 'Operating smoothly' : (telematics.activeAlerts.find((a:any) => a.asset_tag === s.asset_tag)?.alert_type || 'Error')}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* KPI 4-Grid */}
      <div className="grid grid-cols-2 gap-3 flex-shrink-0">
        {[
          { label: 'Active Earning Rate', val: `$${activeEarningRate}`, unit: '/ hr', sub: `(${sessions.length} Rented Units)`, color: 'text-gray-800' },
          { label: 'Avg. Rental Duration', val: '3h', unit: '45m', sub: '(Sessions Running Today)', color: 'text-gray-800' },
          { label: 'Upcoming Returns', val: upcomingReturns, unit: 'Units', sub: '(In Next 60 Mins)', color: 'text-gray-800' },
          { label: 'Geofence Alerts', val: boundaryAlerts, unit: 'Boundary Alerts', sub: '(Operational Zone Violations)', color: 'text-red-500' },
        ].map((k, i) => (
          <div key={i} className="bg-white dark:bg-[#1e293b] rounded-[18px] p-4 border border-gray-100 dark:border-gray-800 shadow-sm min-h-[90px] flex flex-col justify-between">
            <div>
              <div className="text-[11px] font-bold text-gray-400 uppercase tracking-widest mb-1">{k.label}</div>
              <div className={`text-2xl font-extrabold ${k.color}`}>{k.val} <span className="text-sm font-semibold text-gray-500">{k.unit}</span></div>
            </div>
            <div className="text-[11px] text-gray-400 font-medium">{k.sub}</div>
          </div>
        ))}
      </div>

      {/* Real-Time Telematics Gauge Area */}
      <div className="bg-white dark:bg-[#1e293b] rounded-[20px] border border-gray-100 dark:border-gray-800 shadow-sm flex-shrink-0">
        <div className="flex items-center justify-between px-5 pt-4 pb-3 border-b border-gray-50 dark:border-gray-800">
          <h3 className="font-bold text-[14px] text-gray-800 dark:text-white uppercase tracking-wider">Real-Time Telematics</h3>
        </div>
        <div className="grid grid-cols-2 divide-x divide-gray-50 dark:divide-gray-800">
          <div className="p-5 flex items-center gap-6">
            <div className="relative w-24 h-14">
              <svg viewBox="0 0 100 55" className="w-full h-full">
                <path d="M10 50 A40 40 0 0 1 90 50" fill="none" stroke="#fee2e2" strokeWidth="9" strokeLinecap="round"/>
                <path d="M10 50 A40 40 0 0 1 90 50" fill="none" stroke="url(#fuelGrad)" strokeWidth="9" strokeLinecap="round" strokeDasharray="126" strokeDashoffset={126 - (126 * telematics.averageBattery / 100)}/>
                <defs><linearGradient id="fuelGrad" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#ef4444"/><stop offset="100%" stopColor="#22c55e"/></linearGradient></defs>
                <text x="50" y="52" textAnchor="middle" className="fill-gray-800 dark:fill-white font-black" style={{ fontSize: '13px' }}>{telematics.averageBattery}%</text>
              </svg>
            </div>
            <div className="flex flex-col">
                <span className="text-[12px] font-bold text-gray-400 uppercase">Avg. Fuel/Battery</span>
                <span className="text-[11px] text-gray-500">Fleet machine health</span>
            </div>
          </div>
          <div className="p-5 flex flex-col justify-center">
            <div className="text-[12px] font-extrabold text-red-600 uppercase mb-0.5">Engine Stress Warnings</div>
            <div className="text-[11px] text-red-500 font-bold overflow-hidden text-ellipsis whitespace-nowrap">
              {engineWarning ? `${engineWarning.asset_tag}: ${engineWarning.message}` : 'All Engines Normal'}
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Alert Banners */}
      <div className="grid grid-cols-2 gap-3 pb-2">
        {telematics.activeAlerts.slice(0, 2).map((a: any) => (
          <div key={a.id} className="p-4 bg-white dark:bg-[#1e293b] border border-gray-100 dark:border-gray-800 rounded-[18px] border-l-4 border-l-orange-500 shadow-sm">
            <div className="text-[12px] font-extrabold text-gray-800 dark:text-white uppercase tracking-tight">{a.alert_type}</div>
            <div className="text-[11px] text-gray-500 font-medium leading-relaxed mt-1">{a.message}</div>
          </div>
        ))}
      </div>
    </div>
  );
}


export function ActiveRentalsMap({ telematics, isExpanded, setIsExpanded }: { telematics: any, isExpanded: boolean, setIsExpanded: (v: boolean) => void }) {
  const mapRef = useRef<any>(null);
  const HOME_LOCATION = { longitude: 11.3705, latitude: 43.3220, zoom: 13.5 };
  const [viewState, setViewState] = useState(HOME_LOCATION);
  const [currentStyle, setCurrentStyle] = useState<any>(SATELLITE_STYLE);
  const [styleName, setStyleName] = useState('Satellite');
  const [showLayers, setShowLayers] = useState(false);

  const handleZoom = (delta: number) => {
    mapRef.current?.flyTo({
      center: [viewState.longitude, viewState.latitude],
      zoom: viewState.zoom + delta,
      duration: 1000,
      essential: true
    });
    setViewState(v => ({ ...v, zoom: v.zoom! + delta }));
  };

  const handleRecenter = () => {
    mapRef.current?.flyTo({
      center: [HOME_LOCATION.longitude, HOME_LOCATION.latitude],
      zoom: HOME_LOCATION.zoom,
      duration: 1500,
      essential: true
    });
    setViewState(HOME_LOCATION);
  };

  return (
    <div className="w-full h-full relative rounded-[32px] overflow-hidden shadow-lg border-4 border-white transition-all duration-500">
      <Map 
        ref={mapRef}
        {...viewState} 
        onMove={evt => setViewState(evt.viewState)} 
        mapStyle={currentStyle} 
        style={{ width: '100%', height: '100%' }} 
        attributionControl={false}
      >
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-10 px-5 py-2 bg-[#1c2432]/50 backdrop-blur-xl rounded-full border border-white/10 shadow-xl">
          <span className="text-[12px] font-bold text-white uppercase tracking-widest">Contextual Map</span>
        </div>
        <div className="absolute top-4 right-4 z-10">
          <button 
            onClick={() => setIsExpanded(!isExpanded)}
            className={`p-2.5 backdrop-blur shadow-xl border rounded-xl transition-all overflow-hidden relative group active:scale-95 ${isExpanded ? 'bg-orange-500 border-orange-400 text-white shadow-orange-500/20' : 'bg-white/90 border-gray-100/50 text-gray-700 shadow-xl'}`}
          >
            {isExpanded ? (
               <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M6 18L18 6M6 6l12 12" /></svg>
            ) : (
               <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" /></svg>
            )}
          </button>
        </div>

        <div className="absolute bottom-6 left-6 z-[60] flex flex-col items-center gap-2 group/layers">
            {showLayers && (
              <div className="bg-white/90 backdrop-blur-xl p-2 rounded-2xl shadow-2xl border border-gray-100 flex flex-col gap-1 mb-2 animate-in fade-in slide-in-from-bottom-2 duration-300">
                {[
                  { name: 'Satellite', style: SATELLITE_STYLE },
                  { name: 'Terrain', style: TERRAIN_STYLE },
                  { name: 'Plain', style: STREET_STYLE },
                ].map((s) => (
                  <button 
                    key={s.name}
                    onClick={() => { setCurrentStyle(s.style); setStyleName(s.name); setShowLayers(false); }}
                    className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${styleName === s.name ? 'bg-orange-500 text-white shadow-lg' : 'text-gray-500 hover:bg-gray-100'}`}
                  >
                    {s.name}
                  </button>
                ))}
              </div>
            )}
            <button 
              onClick={() => setShowLayers(!showLayers)}
              className={`p-3 backdrop-blur-2xl shadow-2xl border transition-all active:scale-90 rounded-2xl ${showLayers ? 'bg-orange-500 border-orange-400 rotate-90' : 'bg-gray-900/40 border-white/20 hover:bg-gray-900/60'}`}
            >
                <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
            </button>
            {!showLayers && <span className="text-[10px] font-black text-white/40 group-hover/layers:text-white transition-colors uppercase tracking-[0.2em] mt-1 shadow-sm">Layers</span>}
        </div>

        <div className="absolute bottom-6 right-6 z-10 flex flex-col gap-3">
          <button onClick={handleRecenter} className="w-12 h-12 bg-white backdrop-blur shadow-xl border border-gray-100 rounded-2xl flex items-center justify-center text-gray-600 hover:text-green-600 transition-all hover:shadow-green-500/10 active:scale-90">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
          </button>
          
          <div className="bg-white backdrop-blur shadow-xl border border-gray-100 rounded-2xl p-1 flex flex-col divide-y divide-gray-100">
            <button onClick={() => handleZoom(1)} className="w-10 h-10 flex items-center justify-center text-gray-600 hover:text-black transition-all group active:scale-90">
                <svg className="w-5 h-5 group-hover:scale-125 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M12 4v16m8-8H4" /></svg>
            </button>
            <button onClick={() => handleZoom(-1)} className="w-10 h-10 flex items-center justify-center text-gray-600 hover:text-black transition-all group active:scale-90">
                <svg className="w-5 h-5 group-hover:scale-125 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M20 12H4" /></svg>
            </button>
          </div>
        </div>

        {telematics.fleetLocations.map((m: any) => (
          <Marker key={m.id} longitude={m.longitude} latitude={m.latitude} anchor="bottom">
            <div className="group relative cursor-pointer">
              {/* Marker Dot */}
              <div className={`w-4 h-4 rounded-full border-2 border-white shadow-xl transition-all group-hover:scale-150 ${m.current_status === 'Rented' ? 'bg-orange-500' : 'bg-green-500'} ${telematics.activeAlerts.some((a:any) => a.asset_tag === m.asset_tag) ? 'ring-4 ring-red-500 animate-pulse' : ''}`}></div>
              
              {/* Hover Label */}
              <div className="absolute left-1/2 -translate-x-1/2 top-4 pointer-events-none transition-all duration-300 group-hover:top-8 opacity-0 group-hover:opacity-100 z-50">
                 <div className="bg-[#1c2432]/80 backdrop-blur-xl px-4 py-2 rounded-full border border-white/20 shadow-2xl flex items-center gap-2 whitespace-nowrap">
                    <div className={`w-2.5 h-2.5 rounded-full ${m.current_status === 'Rented' ? 'bg-orange-500' : 'bg-green-500'}`}></div>
                    <span className="text-[11px] font-black text-white uppercase tracking-widest">
                      {m.current_status} • {m.asset_tag}
                    </span>
                 </div>
              </div>

              {/* Always Visible Text Tag (to match image style) */}
              <div className="absolute left-6 top-1/2 -translate-y-1/2">
                <div className="bg-black/50 backdrop-blur-md px-3 py-1.5 rounded-xl border border-white/10 shadow-lg flex items-center gap-2.5 whitespace-nowrap">
                    <div className={`w-2 h-2 rounded-full ${m.current_status === 'Rented' ? 'bg-orange-500' : 'bg-green-500'} ${telematics.activeAlerts.some((a:any) => a.asset_tag === m.asset_tag) ? 'bg-red-500 ring-2 ring-red-500/50' : ''}`}></div>
                    <span className="text-[10px] font-extrabold text-white/90 uppercase tracking-tight">
                        {telematics.activeAlerts.some((a:any) => a.asset_tag === m.asset_tag) ? `ALERT • ${m.asset_tag}` : `${m.current_status} • ${m.asset_tag}`}
                    </span>
                </div>
              </div>
            </div>
          </Marker>
        ))}
      </Map>
    </div>
  );
}

export default function ActiveRentalsView() {
  const { data: sessions } = useSWR('/api/fleet/live-sessions', fetcher, { refreshInterval: 5000 });
  const { data: telematics } = useSWR('/api/fleet/telematics', fetcher, { refreshInterval: 5000 });
  const [isExpanded, setIsExpanded] = useState(false);

  if (!sessions || !telematics) return null;

  return (
    <div className="flex-1 flex gap-6 overflow-hidden mt-6 relative">
      <main className={`flex-col min-w-0 overflow-y-auto no-scrollbar gap-4 pb-4 transition-all duration-500 ease-in-out ${isExpanded ? 'hidden w-0 opacity-0 translate-x-[-100%]' : 'flex-1 flex opacity-100 translate-x-0'}`}>
        <ActiveRentalsContent sessions={sessions} telematics={telematics} />
      </main>
      <div className={`h-full relative transition-all duration-500 ease-in-out ${isExpanded ? 'w-full grow' : 'w-[40%] min-w-[480px]'}`}>
        <ActiveRentalsMap telematics={telematics} isExpanded={isExpanded} setIsExpanded={setIsExpanded} />
      </div>
    </div>
  );
}
