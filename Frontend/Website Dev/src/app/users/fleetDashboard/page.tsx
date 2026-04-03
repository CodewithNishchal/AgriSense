"use client";

import { useState, useEffect } from 'react';
import useSWR from 'swr';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import FleetNavTabs from '@/components/FleetNavTabs';
import { AvailableAssetsContent, AvailableAssetsMap } from '@/components/fleet/AvailableAssetsView';
import { ActiveRentalsContent, ActiveRentalsMap } from '@/components/fleet/ActiveRentalsView';

const fetcher = (url: string) => fetch(url).then(res => res.json());

export default function FleetDashboard() {
  const [activeTab, setActiveTab] = useState<'available' | 'active'>('available');
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false);
  // Global data fetching for the entire dashboard
  const { data: overview } = useSWR('/api/fleet/overview', fetcher, { refreshInterval: 10000 });
  const { data: sessions } = useSWR('/api/fleet/live-sessions', fetcher, { refreshInterval: 5000 });
  const { data: telematics } = useSWR('/api/fleet/telematics', fetcher, { refreshInterval: 5000 });

  const isLoading = !overview || !sessions || !telematics;
  const isScreenLoading = isLoading;
  const hasError = overview?.error || sessions?.error || telematics?.error;

  if (hasError) return (
    <div className={`h-screen flex items-center justify-center font-['Inter',sans-serif] bg-[#f6f8f6] dark:bg-[#0f172a] ${isDarkMode ? 'dark' : ''}`}>
      <div className="flex flex-col items-center gap-5 max-w-md text-center p-8 bg-white dark:bg-gray-800 rounded-3xl shadow-xl border border-red-50 dark:border-red-900/30">
        <div className="w-16 h-16 bg-red-50 dark:bg-red-500/10 rounded-full flex items-center justify-center text-red-500 mb-2">
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
        </div>
        <h4 className="text-xl font-extrabold text-[#1c2432] dark:text-white uppercase tracking-tighter">Connection Interrupted</h4>
        <p className="text-sm font-medium text-gray-500 dark:text-gray-400">The fleet matrix could not established a secure link with the telematics core. Please check your database uplink or try manually refreshing.</p>
        <button onClick={() => window.location.reload()} className="mt-4 px-6 py-2.5 bg-green-500 hover:bg-green-600 text-white font-bold rounded-full transition-all active:scale-95 shadow-lg shadow-green-500/20">RETRY UPLINK</button>
      </div>
    </div>
  );

  if (isScreenLoading) return (
    <div className="p-6 bg-[#f6f8f6] min-h-screen flex gap-6 w-full font-['Inter',sans-serif]">
      {/* LEFT COLUMN - Metrics & Charts */}
      <div className="w-7/12 flex flex-col gap-6">

        {/* Header Area */}
        <div className="flex justify-between items-center mb-2">
          <div className="flex items-center gap-4">
            <div className="h-10 w-64 bg-gray-200 rounded-xl animate-pulse"></div>
            <div className="h-6 w-24 bg-gray-200 rounded-full animate-pulse"></div>
          </div>
          <div className="h-12 w-40 bg-gray-800 rounded-full animate-pulse"></div>
        </div>

        {/* 4 KPI Cards (Total Fleet, Categories, Revenue, Usage) */}
        <div className="grid grid-cols-2 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-32 bg-white rounded-[24px] shadow-sm border border-gray-100 p-6 flex flex-col justify-between animate-pulse">
              <div className="flex justify-between items-center">
                <div className="h-3 w-24 bg-gray-100 rounded"></div>
                <div className="h-4 w-4 bg-gray-100 rounded-full"></div>
              </div>
              <div className="h-10 w-24 bg-gray-200 rounded-xl"></div>
            </div>
          ))}
        </div>

        {/* Middle Row (Asset Distribution & Donut Chart) */}
        <div className="flex gap-4 h-64">
          {/* Asset Distribution (Green Card Vibe) */}
          <div className="w-1/2 bg-green-50/50 rounded-[24px] p-6 border border-green-100/50 animate-pulse flex flex-col justify-center">
            <div className="h-4 w-48 bg-green-200/50 rounded mb-8"></div>
            <div className="space-y-6">
              <div className="h-3 w-full bg-green-200/50 rounded-full"></div>
              <div className="h-3 w-4/5 bg-green-200/50 rounded-full"></div>
              <div className="h-3 w-3/4 bg-green-200/50 rounded-full"></div>
            </div>
          </div>

          {/* Fleet Utilization (Donut Chart Placeholder) */}
          <div className="w-1/2 bg-white rounded-[24px] border border-gray-100 p-6 animate-pulse flex flex-col items-center justify-center relative overflow-hidden">
            <div className="h-4 w-32 bg-gray-100 rounded absolute top-8 left-8"></div>
            <div className="h-40 w-40 rounded-full border-[16px] border-gray-50 flex items-center justify-center">
              <div className="h-8 w-16 bg-gray-200 rounded-lg"></div>
            </div>
          </div>
        </div>

        {/* Bottom Action Cards (Done, Progress, Waiting) */}
        <div className="grid grid-cols-3 gap-4 mt-2">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-36 bg-gray-200 rounded-[24px] animate-pulse relative overflow-hidden">
              {/* Simulating the dark gradient over the images */}
              <div className="absolute inset-0 bg-gradient-to-t from-gray-300 to-transparent opacity-60"></div>
              <div className="absolute bottom-6 left-6 h-4 w-2/3 bg-gray-100/40 rounded-lg"></div>
            </div>
          ))}
        </div>
      </div>

      {/* RIGHT COLUMN - The Contextual Map */}
      <div className="w-5/12 h-[calc(100vh-3rem)] bg-gray-200 rounded-[32px] animate-pulse relative overflow-hidden border-4 border-white shadow-lg">
        {/* Sweeping Map Radar Effect */}
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/40 to-transparent animate-[pulse_2s_ease-in-out_infinite] transform -skew-y-12"></div>

        {/* Floating Map UI Placeholders */}
        <div className="absolute top-8 left-1/2 transform -translate-x-1/2 h-12 w-56 bg-white/40 rounded-full backdrop-blur-md border border-white/20"></div>
        <div className="absolute bottom-8 right-8 h-28 w-14 bg-white/40 rounded-[20px] backdrop-blur-md border border-white/20"></div>
      </div>
    </div>
  );

  return (
    <div className={`h-screen flex p-4 gap-6 text-gray-800 dark:text-gray-200 overflow-hidden box-border font-['Inter',sans-serif] bg-[#f6f8f6] dark:bg-[#0f172a] transition-colors duration-500 ${isDarkMode ? 'dark' : ''}`}>
      <div className="h-full shrink-0 z-[60]">
        <Sidebar isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} />
      </div>

      <div className="flex-1 flex flex-col min-w-0 overflow-hidden relative">
        <div className="z-50 relative">
          <Header />
        </div>

        <div className="flex-1 flex gap-6 overflow-hidden mt-3 relative">
          {/* Main Content Column (Left) */}
          <main className={`flex-col min-w-0 overflow-y-auto no-scrollbar pb-4 transition-all duration-500 ease-in-out ${isExpanded ? 'hidden w-0 opacity-0 translate-x-[-100%]' : 'flex-1 flex opacity-100 translate-x-0'} ${activeTab === 'available' ? 'gap-6' : 'gap-4'}`}>
            <FleetNavTabs activeTab={activeTab} onTabChange={setActiveTab} />

            <div className="flex-1 min-h-0">
              {activeTab === 'available' ? (
                <AvailableAssetsContent overview={overview} telematics={telematics} />
              ) : (
                <ActiveRentalsContent sessions={sessions} telematics={telematics} />
              )}
            </div>
          </main>

          {/* Map Column (Right) */}
          <aside className={`h-full relative transition-all duration-500 ease-in-out shrink-0 ${isExpanded ? 'w-full grow' : 'w-[40%] min-w-[500px]'}`}>
            {activeTab === 'available' ? (
              <AvailableAssetsMap telematics={telematics} isExpanded={isExpanded} setIsExpanded={setIsExpanded} />
            ) : (
              <ActiveRentalsMap telematics={telematics} isExpanded={isExpanded} setIsExpanded={setIsExpanded} />
            )}
          </aside>
        </div>
      </div>
    </div>
  );
}
