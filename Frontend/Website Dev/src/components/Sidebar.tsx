"use client";

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import { toast } from 'react-hot-toast';

interface SidebarProps {
  isDarkMode: boolean;
  setIsDarkMode: (val: boolean) => void;
}

export default function Sidebar({ isDarkMode, setIsDarkMode }: SidebarProps) {
  const router = useRouter();

  const onLogout = async () => {
    try {
      await axios.get("/api/users/logout");
      toast.success("Logged out successfully");
      router.push("/");
    } catch (error: any) {
      console.log("Logout failed", error.message);
      toast.error("Logout failed");
    }
  };
  return (
    <div className="relative group z-[100] flex items-start h-full shrink-0">
      {/* Transparent shadow overlay when sidebar expands */}
      <div className="fixed inset-0 bg-black/30 backdrop-blur-[2px] opacity-0 group-hover:opacity-100 pointer-events-none transition-all duration-300 z-[90] delay-75"></div>

      {/* Spacer to maintain flex layout volume */}
      <div className="w-16 h-full shrink-0"></div>

      {/* Expanding Sidebar */}
      <aside className="absolute left-0 top-0 bottom-0 w-16 group-hover:w-[260px] transition-all duration-300 ease-in-out flex flex-col py-6 bg-white dark:bg-[#1e293b] rounded-3xl shadow-sm border border-gray-100 dark:border-gray-800 overflow-hidden group-hover:shadow-2xl z-[100]">
        {/* Logo */}
        <div className="flex items-center mb-10 relative">
          <div className="w-16 flex items-center justify-center shrink-0">
            <div className="w-14 h-14 flex items-center justify-center overflow-hidden transition-transform group-hover:scale-110">
              <img src="/agrisense_logo.png" alt="AgriSense Logo" className="w-full h-full object-contain scale-125" />
            </div>
          </div>
          <span className="font-black tracking-tighter text-gray-900 dark:text-white text-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap ml-3">AgriSense</span>
        </div>

        {/* Nav Items */}
        <nav className="flex flex-col gap-2 relative">
          <Link href="/users/fleetDashboard">
            <div className="flex items-center text-gray-900 dark:text-white whitespace-nowrap cursor-pointer relative group/item">
              <div className="absolute inset-y-0 left-2 right-2 rounded-xl group-hover/item:bg-gray-50 dark:group-hover/item:bg-gray-800/50 transition-colors z-0"></div>
              <div className="w-16 h-12 flex items-center justify-center shrink-0 relative z-10">
                <div className="w-10 h-10 rounded-xl bg-gray-900 dark:bg-green-500 text-white flex items-center justify-center shadow-lg transform transition-transform group-hover/item:scale-110">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                  </svg>
                </div>
              </div>
              <span className="font-bold text-[15px] opacity-0 group-hover:opacity-100 transition-opacity duration-300 pr-4 relative z-10">Dashboard</span>
            </div>
          </Link>

          <Link href="/users/inspectionDashboard">
            <div className="flex items-center text-gray-400 hover:text-gray-900 dark:hover:text-white whitespace-nowrap cursor-pointer relative group/item">
              <div className="absolute inset-y-0 left-2 right-2 rounded-xl group-hover/item:bg-gray-50 dark:group-hover/item:bg-gray-800 transition-colors z-0"></div>
              <div className="w-16 h-12 flex items-center justify-center shrink-0 relative z-10">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                </div>
              </div>
              <span className="font-semibold text-[15px] opacity-0 group-hover:opacity-100 transition-opacity duration-300 pr-4 relative z-10">Inspection</span>
            </div>
          </Link>

          <div className="flex items-center text-gray-400 hover:text-gray-900 dark:hover:text-white whitespace-nowrap cursor-pointer relative group/item">
            <div className="absolute inset-y-0 left-2 right-2 rounded-xl group-hover/item:bg-gray-50 dark:group-hover/item:bg-gray-800 transition-colors z-0"></div>
            <div className="w-16 h-12 flex items-center justify-center shrink-0 relative z-10">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
            </div>
            <span className="font-semibold text-[15px] opacity-0 group-hover:opacity-100 transition-opacity duration-300 pr-4 relative z-10">Analytics</span>
          </div>

          <div className="flex items-center text-gray-400 hover:text-gray-900 dark:hover:text-white whitespace-nowrap cursor-pointer relative group/item">
            <div className="absolute inset-y-0 left-2 right-2 rounded-xl group-hover/item:bg-gray-50 dark:group-hover/item:bg-gray-800 transition-colors z-0"></div>
            <div className="w-16 h-12 flex items-center justify-center shrink-0 relative z-10">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
            </div>
            <span className="font-semibold text-[15px] opacity-0 group-hover:opacity-100 transition-opacity duration-300 pr-4 relative z-10">Schedules</span>
          </div>
        </nav>

        {/* Bottom Section */}
        <div className="mt-auto pb-4">
          <div className="w-full px-3 h-0 group-hover:h-[200px] rounded-2xl mb-4 transition-all duration-300 overflow-hidden flex flex-col justify-end opacity-0 group-hover:opacity-100 relative items-center">
            <div className="w-full h-full bg-[#f3faf4] dark:bg-green-950/20 border border-green-100/50 dark:border-green-900/50 rounded-2xl flex flex-col justify-end pt-6 relative items-center pb-3 px-3 shadow-inner">
              <div className="w-24 h-24 mb-2 z-10">
                <img src="https://api.dicebear.com/7.x/notionists/svg?seed=Farm" alt="Farm" className="w-full h-full object-contain drop-shadow-sm" />
              </div>
              <button className="w-full py-2 bg-white dark:bg-green-900/40 text-green-700 dark:text-green-300 text-xs font-bold rounded-xl mt-auto z-10 shadow-sm border border-green-200 dark:border-green-800 hover:bg-green-50 dark:hover:bg-green-900/60 transition-colors">
                + Add form
              </button>
            </div>
          </div>

          {/* Logout Item */}
          <div className="border-t border-gray-100 dark:border-gray-800 pt-2">
            <div 
              onClick={onLogout}
              className="flex items-center text-gray-400 hover:text-red-500 whitespace-nowrap cursor-pointer relative group/item"
            >
              <div className="absolute inset-y-0 left-2 right-2 rounded-xl group-hover/item:bg-red-50 dark:group-hover/item:bg-red-900/10 transition-colors z-0"></div>
              <div className="w-16 h-12 flex items-center justify-center shrink-0 relative z-10">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                </div>
              </div>
              <span className="font-bold text-sm opacity-0 group-hover:opacity-100 transition-opacity duration-300 uppercase tracking-widest pr-4 relative z-10">Log out</span>
            </div>
          </div>

          {/* Theme Toggle Item */}
          <div className="pt-2">
            <div onClick={() => setIsDarkMode(!isDarkMode)} className="flex items-center text-gray-400 hover:text-green-500 whitespace-nowrap cursor-pointer relative group/item transition-colors">
              <div className="absolute inset-y-0 left-2 right-2 rounded-xl group-hover/item:bg-gray-50 dark:group-hover/item:bg-gray-800 transition-colors z-0"></div>
              <div className="w-16 h-12 flex items-center justify-center shrink-0 relative z-10">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center">
                  {isDarkMode ? (
                    <svg className="w-5 h-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                  ) : (
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                    </svg>
                  )}
                </div>
              </div>
              <span className="font-bold text-sm opacity-0 group-hover:opacity-100 transition-opacity duration-300 uppercase tracking-widest pr-4 relative z-10">{isDarkMode ? 'Light Mode' : 'Dark Mode'}</span>
            </div>
          </div>
        </div>
      </aside>
    </div>
  );
}
