"use client";

import React, { useState, useEffect } from 'react';

export default function MyFarmDashboard() {
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDarkMode]);

  return (
    <div className={`h-screen flex p-4 gap-6 overflow-hidden box-border font-sans transition-colors duration-500 ${isDarkMode ? 'dark bg-slate-950 text-slate-100' : 'bg-[#f6f8f6] text-slate-800'}`}>
      
      {/* SIDEBAR */}
      <aside className={`w-16 flex flex-col items-center gap-8 py-6 rounded-3xl shrink-0 transition-colors ${isDarkMode ? 'bg-slate-900 border-slate-800 shadow-md' : 'bg-white shadow-sm border border-slate-100'}`}>
          <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold mb-4">
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M12 1.586l-4 4v12.828l4-4V1.586zM3.707 3.293A1 1 0 002 4v10a1 1 0 00.293.707L6 18.414V5.586L3.707 3.293zM17.707 5.293L14 1.586v12.828l2.293 2.293A1 1 0 0018 16V6a1 1 0 00-.293-.707z" clipRule="evenodd"></path>
              </svg>
          </div>
          <div className="w-10 h-10 rounded-xl bg-slate-900 flex items-center justify-center text-white cursor-pointer hover:scale-105 transition-transform">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
              </svg>
          </div>
          <div className="w-10 h-10 rounded-xl flex items-center justify-center text-slate-400 hover:text-slate-900 cursor-pointer">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
          </div>
          <div className="w-10 h-10 rounded-xl flex items-center justify-center text-slate-400 hover:text-slate-900 cursor-pointer">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
          </div>
          <button 
              onClick={() => setIsDarkMode(!isDarkMode)}
              className="mt-auto w-10 h-10 rounded-xl flex items-center justify-center text-slate-400 hover:text-slate-900 dark:hover:text-white cursor-pointer transition-colors"
          >
              {isDarkMode ? (
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" /></svg>
              ) : (
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" /></svg>
              )}
          </button>
      </aside>

      {/* MAIN CONTENT AREA */}
      <main className="flex-1 flex flex-col min-w-0 overflow-y-auto [&::-webkit-scrollbar]:hidden [-ms-overflow-style:'none'] [scrollbar-width:'none'] gap-6 pb-4">
          
          <header className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                  <h1 className={`text-2xl font-bold ${isDarkMode ? 'text-white' : 'text-slate-900'}`}>My Farm</h1>
                  <div className={`px-3 py-1 rounded-full text-sm font-medium flex items-center gap-2 cursor-pointer transition-colors ${isDarkMode ? 'bg-slate-800 border-slate-700 text-slate-200' : 'bg-white border-slate-200 shadow-sm border'}`}>
                      North Fields 
                      <svg className="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"></path>
                      </svg>
                  </div>
              </div>
              <div className="flex items-center gap-4">
                  <div className="relative">
                      <svg className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                      </svg>
                      <input 
                        type="text" 
                        placeholder="Search" 
                        className={`pl-10 pr-4 py-2 w-64 rounded-full transition-colors outline-none focus:ring-2 focus:ring-green-500/20 text-sm ${isDarkMode ? 'bg-slate-800 border border-slate-700 text-slate-200 placeholder-slate-500' : 'bg-white border border-slate-100 shadow-sm'}`}
                      />
                  </div>
                  <button className={`w-10 h-10 ring-0 transition-colors rounded-full flex items-center justify-center cursor-pointer ${isDarkMode ? 'bg-slate-800 hover:bg-slate-700 text-slate-300' : 'bg-white hover:bg-slate-50 text-slate-600 shadow-sm border border-slate-100'}`}>
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                      </svg>
                  </button>
                  <div className={`w-10 h-10 rounded-full overflow-hidden cursor-pointer ${isDarkMode ? 'bg-slate-700' : 'bg-slate-200 shadow-sm border border-slate-100'}`}>
                      <img src="https://api.dicebear.com/7.x/notionists/svg?seed=Felix" alt="Profile" className="w-full h-full object-cover" />
                  </div>
              </div>
          </header>

          <div className={`flex items-center gap-4 p-2 rounded-full transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
              <div className={`flex-1 flex rounded-full p-1 h-12 relative ${isDarkMode ? 'bg-slate-800' : 'bg-slate-100'}`}>
                  <div className="w-1/2 bg-[#528956] text-white rounded-full flex items-center justify-between px-4 text-sm font-medium z-10 shadow-md">
                      <span>Task Completed</span>
                      <span>10</span>
                  </div>
                  <div className={`w-1/2 flex items-center justify-between px-4 text-sm font-medium absolute right-0 top-0 h-full ${isDarkMode ? 'text-slate-400' : 'text-slate-500'}`}>
                      <span className="ml-4">Task Pending</span>
                      <span>12</span>
                  </div>
              </div>
              <button className={`px-6 py-3 rounded-full text-sm font-medium flex items-center gap-2 transition-colors shrink-0 ${isDarkMode ? 'bg-emerald-600 hover:bg-emerald-500 text-white' : 'bg-[#1a211b] hover:bg-black text-white'}`}>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"></path>
                  </svg> Add New Task
              </button>
          </div>

          <div className="grid grid-cols-3 gap-6">
              <div className="col-span-2 grid grid-cols-2 gap-4">
                  <div className={`p-4 rounded-3xl flex flex-col justify-between h-28 transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
                      <div className="flex justify-between text-slate-400 text-xs font-semibold">Total Plots <span className="text-lg leading-none">..</span></div>
                      <div className={`text-3xl font-bold flex items-baseline gap-1 ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>12 <span className="text-sm font-medium text-slate-400">Plots</span></div>
                  </div>
                  <div className={`p-4 rounded-3xl flex flex-col justify-between h-28 transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
                      <div className="flex justify-between text-slate-400 text-xs font-semibold">Total Crop <span className="text-lg leading-none">..</span></div>
                      <div className={`text-3xl font-bold flex items-baseline gap-1 ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>6 <span className="text-sm font-medium text-slate-400">Types</span></div>
                  </div>
                  <div className={`p-4 rounded-3xl flex flex-col justify-between h-28 transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
                      <div className="flex justify-between text-slate-400 text-xs font-semibold">Total Area <span className="text-lg leading-none">..</span></div>
                      <div className={`text-3xl font-bold flex items-baseline gap-1 ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>2.3 <span className="text-sm font-medium text-slate-400">Hectares</span></div>
                  </div>
                  <div className={`p-4 rounded-3xl flex flex-col justify-between h-28 transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
                      <div className="flex justify-between text-slate-400 text-xs font-semibold">Total Plants <span className="text-lg leading-none">..</span></div>
                      <div className={`text-3xl font-bold flex items-baseline gap-1 ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>4k <span className="text-sm font-medium text-slate-400">Plots</span></div>
                  </div>
              </div>
              
              <div className={`p-5 rounded-3xl flex flex-col justify-between h-[240px] transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
                  <div className="flex justify-between items-start">
                      <div className={`font-semibold ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>Weather</div>
                      <div className={`text-right text-xs font-medium space-y-1 ${isDarkMode ? 'text-slate-400' : 'text-slate-600'}`}>
                          <div className="flex items-center gap-1 justify-end">
                            <svg className="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path>
                            </svg> Cloudy
                          </div>
                          <div className="flex items-center gap-1 justify-end">
                            <svg className="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                            </svg> Wind
                          </div>
                          <div className="flex items-center gap-1 justify-end">
                            <svg className="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>
                            </svg> 62%
                          </div>
                      </div>
                  </div>
                  <div className="text-center mt-[-20px]">
                      <span className={`text-4xl font-bold ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>30°</span>
                  </div>
                  <div className="relative mt-2">
                      <div className="flex justify-between text-xs text-slate-500 mb-1">
                          <span>27°</span><span>28°</span><span>30°</span><span>31°</span>
                      </div>
                      <div className="h-6 flex gap-1 rounded-full overflow-hidden">
                          <div className="w-1/2 bg-gradient-to-r from-green-400 to-green-500 opacity-80 border-r border-white" style={{backgroundImage: 'repeating-linear-gradient(45deg, transparent, transparent 2px, rgba(255,255,255,0.2) 2px, rgba(255,255,255,0.2) 4px)'}}></div>
                          <div className="w-1/2 bg-gradient-to-r from-yellow-400 to-orange-400 opacity-80" style={{backgroundImage: 'repeating-linear-gradient(45deg, transparent, transparent 2px, rgba(255,255,255,0.2) 2px, rgba(255,255,255,0.2) 4px)'}}></div>
                      </div>
                  </div>
              </div>
          </div>

          <div className="grid grid-cols-2 gap-6">
              <div className={`p-6 rounded-3xl text-white shadow-md relative overflow-hidden h-[280px] transition-colors ${isDarkMode ? 'bg-gradient-to-br from-[#1e3420] to-[#122814]' : 'bg-gradient-to-br from-[#6b9d6c] to-[#457846]'}`}>
                  <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 blur-2xl rounded-full pointer-events-none"></div>
                  <div className="flex justify-between items-start mb-6 relative z-10">
                      <h3 className="font-semibold text-lg">Soil Health</h3>
                      <span className="text-xl leading-none">..</span>
                  </div>
                  <div className="space-y-5 relative z-10">
                      <div>
                          <div className="flex justify-between text-sm mb-1"><span>N Level</span><span>23 ppm</span></div>
                          <div className="w-full bg-white/20 h-4 rounded-full overflow-hidden flex">
                              <div className="w-[70%] bg-gradient-to-r from-white/60 to-white h-full shadow-inner rounded-r-full border-r border-white/50"></div>
                              <div className="flex-1" style={{backgroundImage: 'repeating-linear-gradient(90deg, transparent, transparent 2px, rgba(255,255,255,0.3) 2px, rgba(255,255,255,0.3) 4px)'}}></div>
                          </div>
                      </div>
                      <div>
                          <div className="flex justify-between text-sm mb-1"><span>P Level</span><span>9 ppm</span></div>
                          <div className="w-full bg-white/20 h-4 rounded-full overflow-hidden flex">
                              <div className="w-[30%] bg-gradient-to-r from-white/60 to-white h-full shadow-inner rounded-r-full border-r border-white/50"></div>
                              <div className="flex-1" style={{backgroundImage: 'repeating-linear-gradient(90deg, transparent, transparent 2px, rgba(255,255,255,0.3) 2px, rgba(255,255,255,0.3) 4px)'}}></div>
                          </div>
                      </div>
                      <div>
                          <div className="flex justify-between text-sm mb-1"><span>K Level</span><span>19 ppm</span></div>
                          <div className="w-full bg-white/20 h-4 rounded-full overflow-hidden flex">
                              <div className="w-[50%] bg-gradient-to-r from-white/60 to-white h-full shadow-inner rounded-r-full border-r border-white/50"></div>
                              <div className="flex-1" style={{backgroundImage: 'repeating-linear-gradient(90deg, transparent, transparent 2px, rgba(255,255,255,0.3) 2px, rgba(255,255,255,0.3) 4px)'}}></div>
                          </div>
                      </div>
                  </div>
              </div>

              <div className={`p-6 rounded-3xl flex flex-col h-[280px] transition-colors ${isDarkMode ? 'bg-slate-900 border border-slate-800' : 'bg-white shadow-sm border border-slate-100'}`}>
                  <div className="flex justify-between items-start mb-2">
                      <h3 className={`font-semibold text-lg ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>Farm Performance</h3>
                      <span className="text-xl leading-none text-slate-400">..</span>
                  </div>
                  <div className="flex-1 relative flex items-center justify-center">
                      <div className="w-36 h-36 rounded-full relative flex items-center justify-center" style={{background: 'conic-gradient(#5a945b 0% 61%, #d1d5db 61% 72%, #8ab98c 72% 100%)'}}>
                          <div className={`w-24 h-24 rounded-full flex flex-col items-center justify-center absolute shadow-inner z-10 ${isDarkMode ? 'bg-slate-900' : 'bg-white'}`}>
                              <span className="text-xs text-slate-400">Overall Score</span>
                              <span className={`text-2xl font-bold ${isDarkMode ? 'text-white' : 'text-slate-800'}`}>72%</span>
                          </div>
                          <div className={`absolute -top-3 left-10 text-xs text-slate-500 font-medium px-1 rounded ${isDarkMode ? 'bg-slate-800/80' : 'bg-white/80'}`}>61%</div>
                          <div className={`absolute top-4 -right-4 text-xs text-slate-500 font-medium px-1 rounded ${isDarkMode ? 'bg-slate-800/80' : 'bg-white/80'}`}>36%</div>
                          <div className={`absolute bottom-2 -right-2 text-xs text-slate-500 font-medium px-1 rounded ${isDarkMode ? 'bg-slate-800/80' : 'bg-white/80'}`}>79%</div>
                      </div>
                  </div>
                  <div className="flex justify-center gap-4 text-xs font-medium text-slate-500 mt-2">
                      <div className="flex items-center gap-1"><div className="w-2 h-2 rounded-full bg-[#5a945b]"></div> Utilization</div>
                      <div className="flex items-center gap-1"><div className="w-2 h-2 rounded-full bg-[#8ab98c]"></div> Health</div>
                      <div className="flex items-center gap-1"><div className="w-2 h-2 rounded-full bg-slate-300"></div> On Track</div>
                  </div>
              </div>
          </div>

          <div className="grid grid-cols-3 gap-6 mt-auto">
              {/* Card 1 */}
              <div className="relative h-32 rounded-3xl overflow-hidden group cursor-pointer shadow-sm">
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent z-10"></div>
                  <div className="absolute inset-0 bg-[#2a4530]"></div>
                  <div className="absolute top-3 left-3 z-20 px-3 py-1 bg-white/20 backdrop-blur-md border border-white/30 rounded-full text-[10px] uppercase tracking-wider font-bold text-white flex items-center gap-1.5 shadow-sm">
                      <div className="w-1.5 h-1.5 rounded-full bg-green-400"></div> Complete
                  </div>
                  <div className="absolute bottom-3 left-4 z-20 text-white font-medium text-sm leading-tight pr-4 drop-shadow-md">
                      Irrigation System<br/>Maintenance
                  </div>
              </div>
              {/* Card 2 */}
              <div className="relative h-32 rounded-3xl overflow-hidden group cursor-pointer shadow-sm">
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent z-10"></div>
                  <div className="absolute inset-0 bg-[#6d5b3d]"></div>
                  <div className="absolute top-3 left-3 z-20 px-3 py-1 bg-white/20 backdrop-blur-md border border-white/30 rounded-full text-[10px] uppercase tracking-wider font-bold text-white flex items-center gap-1.5 shadow-sm">
                      <div className="w-1.5 h-1.5 rounded-full bg-yellow-400"></div> Progress
                  </div>
                  <div className="absolute bottom-3 left-4 z-20 text-white font-medium text-sm leading-tight pr-4 drop-shadow-md">
                      Soil Nutrient<br/>Testing
                  </div>
              </div>
              {/* Card 3 */}
              <div className="relative h-32 rounded-3xl overflow-hidden group cursor-pointer shadow-sm">
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent z-10"></div>
                  <div className="absolute inset-0 bg-[#8b3a32]"></div>
                  <div className="absolute top-3 left-3 z-20 px-3 py-1 bg-white/20 backdrop-blur-md border border-white/30 rounded-full text-[10px] uppercase tracking-wider font-bold text-white flex items-center gap-1.5 shadow-sm">
                      <div className="w-1.5 h-1.5 rounded-full bg-white"></div> Waiting
                  </div>
                  <div className="absolute bottom-3 left-4 z-20 text-white font-medium text-sm leading-tight pr-4 drop-shadow-md">
                      Harvesting<br/>Tomatoes
                  </div>
              </div>
          </div>
      </main>

      {/* RIGHT SIDE MAP PANEL */}
      <aside className={`w-[450px] relative rounded-[32px] overflow-hidden shadow-lg border-4 shrink-0 transition-colors ${isDarkMode ? 'border-slate-800' : 'border-white'}`}>
          <div className="absolute inset-0 bg-gradient-to-br from-[#3c7821] via-[#2f6317] to-[#1e440e]">
              <div className="absolute inset-0 opacity-40 mix-blend-overlay" style={{backgroundImage: 'repeating-linear-gradient(15deg, transparent, transparent 10px, rgba(0,0,0,0.1) 10px, rgba(0,0,0,0.1) 12px)'}}></div>
              <div className="absolute inset-0 opacity-30 mix-blend-screen" style={{backgroundImage: 'repeating-linear-gradient(-75deg, transparent, transparent 20px, rgba(255,255,255,0.05) 20px, rgba(255,255,255,0.05) 22px)'}}></div>
              <div className="absolute top-0 bottom-0 left-1/3 w-3 bg-[#18360b] opacity-80 shadow-[0_0_15px_rgba(0,0,0,0.5)] border-x border-[#598b3c]"></div>
          </div>

          <div className="absolute top-4 left-4 z-20">
              <div className={`px-4 py-2 rounded-full shadow-md text-sm font-semibold flex items-center gap-2 cursor-pointer transition-colors ${isDarkMode ? 'bg-slate-800 hover:bg-slate-700 text-slate-200' : 'bg-white hover:bg-slate-50 text-slate-800'}`}>
                  Map 
                  <svg className="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"></path>
                  </svg>
              </div>
          </div>
          
          <button className={`absolute top-4 right-4 z-20 w-10 h-10 transition-colors rounded-full shadow-md flex items-center justify-center cursor-pointer ${isDarkMode ? 'bg-slate-800 hover:bg-slate-700' : 'bg-white hover:bg-slate-50'}`}>
              <svg className={`w-5 h-5 ${isDarkMode ? 'text-slate-300' : 'text-slate-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"></path>
              </svg>
          </button>

          {/* Map Marker 1 (Red) */}
          <div className="absolute top-[20%] left-[45%] z-20 group">
              <div className="w-6 h-6 rounded-full bg-red-100 flex items-center justify-center absolute -top-10 left-1/2 -translate-x-1/2 shadow-[0_0_15px_rgba(239,68,68,0.5)]">
                  <div className="w-2.5 h-2.5 rounded-full bg-red-500"></div>
              </div>
              <div className="px-4 py-2.5 bg-white/40 backdrop-blur-md border border-white/50 rounded-2xl shadow-lg text-sm font-semibold text-slate-900 whitespace-nowrap">
                  2 plots need attention
              </div>
          </div>

          {/* Map Marker 2 (Yellow) */}
          <div className="absolute top-[50%] left-[10%] z-20 group">
              <div className="w-6 h-6 rounded-full bg-yellow-100 flex items-center justify-center absolute -top-8 left-1/2 -translate-x-1/2 shadow-[0_0_15px_rgba(234,179,8,0.5)]">
                  <div className="w-2.5 h-2.5 rounded-full bg-yellow-500"></div>
              </div>
              <div className="px-4 py-2.5 bg-white/40 backdrop-blur-md border border-white/50 rounded-2xl shadow-lg text-sm font-semibold text-slate-900 whitespace-nowrap">
                  Moisture: <span className="font-bold">68%</span>
              </div>
          </div>

          {/* Map Marker 3 (Green) */}
          <div className="absolute bottom-[25%] right-[10%] z-20 group">
              <div className="px-4 py-2.5 bg-white/40 backdrop-blur-md border border-white/50 rounded-2xl shadow-lg text-sm font-semibold text-slate-900 whitespace-nowrap mb-2">
                  Healthy: <span className="font-bold">92%</span>
              </div>
              <div className="w-6 h-6 rounded-full bg-green-100 flex items-center justify-center absolute -bottom-4 left-1/2 -translate-x-1/2 shadow-[0_0_15px_rgba(34,197,94,0.5)]">
                  <div className="w-2.5 h-2.5 rounded-full bg-green-500 border-2 border-white"></div>
              </div>
          </div>

          {/* Bottom Left Sync Icon */}
          <div className="absolute bottom-6 left-6 z-20 w-24 h-24 rounded-2xl border-[2.5px] border-white/80 overflow-hidden shadow-lg bg-[#2f6317]">
              <div className="absolute inset-0 opacity-60 mix-blend-overlay" style={{backgroundImage: 'repeating-linear-gradient(45deg, transparent, transparent 5px, rgba(0,0,0,0.2) 5px, rgba(0,0,0,0.2) 6px)'}}></div>
              <div className="absolute bottom-2 left-2 text-white">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                  </svg>
              </div>
          </div>

          {/* Bottom Right Controls */}
          <div className="absolute bottom-6 right-6 z-20 flex flex-col gap-3">
              <button className={`w-10 h-10 rounded-full shadow-md flex items-center justify-center cursor-pointer transition-colors ${isDarkMode ? 'bg-slate-800 hover:bg-slate-700' : 'bg-white hover:bg-slate-50'}`}>
                  <svg className={`w-5 h-5 ${isDarkMode ? 'text-slate-300' : 'text-slate-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
              </button>
              <div className={`rounded-full shadow-md flex flex-col overflow-hidden transition-colors ${isDarkMode ? 'bg-slate-800' : 'bg-white'}`}>
                  <button className={`w-10 h-10 flex items-center justify-center cursor-pointer transition-colors ${isDarkMode ? 'hover:bg-slate-700 border-b border-slate-700' : 'hover:bg-slate-50 border-b border-slate-100'}`}>
                      <svg className={`w-5 h-5 ${isDarkMode ? 'text-slate-300' : 'text-slate-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                      </svg>
                  </button>
                  <button className={`w-10 h-10 flex items-center justify-center cursor-pointer transition-colors ${isDarkMode ? 'hover:bg-slate-700' : 'hover:bg-slate-50'}`}>
                      <svg className={`w-5 h-5 ${isDarkMode ? 'text-slate-300' : 'text-slate-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M20 12H4"></path>
                      </svg>
                  </button>
              </div>
          </div>

      </aside>

    </div>
  );
}
