import React, { useState, useRef, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const randomNotifications = [
  { id: 1, text: "TRC-08 fuel level dropped below 12%", time: "2 min ago", type: "critical" },
  { id: 2, text: "Harvester BKH-04 maintenance due in 48h", time: "1 hour ago", type: "warning" },
  { id: 3, text: "New booking request: TRC-A9 Compact", time: "3 hours ago", type: "info" },
  { id: 4, text: "Luca M. completed session with TRC-02", time: "5 hours ago", type: "success" },
];

interface HeaderProps {
  title?: string;
}

export default function Header({ title = "AgriSense Marketplace Fleet" }: HeaderProps) {
  const pathname = usePathname();
  const isInspectionPage = pathname.includes('inspectionDashboard');

  const [showNotifications, setShowNotifications] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [showAccount, setShowAccount] = useState(false);
  
  const notifRef = useRef<HTMLDivElement>(null);
  const filterRef = useRef<HTMLDivElement>(null);
  const accountRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (notifRef.current && !notifRef.current.contains(event.target as Node)) {
        setShowNotifications(false);
      }
      if (filterRef.current && !filterRef.current.contains(event.target as Node)) {
        setShowFilters(false);
      }
      if (accountRef.current && !accountRef.current.contains(event.target as Node)) {
        setShowAccount(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <header className="flex items-center justify-between bg-white/50 dark:bg-[#1e293b]/50 p-2 rounded-full backdrop-blur-md transition-colors shrink-0 z-50">
      <div className="flex items-center gap-4 pl-4">
        <h1 className="text-2xl font-extrabold text-black dark:text-white tracking-tight">{title}</h1>
        <div className="ml-2 px-3 py-1 bg-white dark:bg-[#1e293b] border border-gray-100 dark:border-gray-800 rounded-full text-[13px] font-bold text-gray-600 dark:text-gray-300 flex items-center gap-1.5 cursor-pointer shadow-sm hover:border-green-200 transition-colors">
          North Fields <svg className="w-3 h-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M19 9l-7 7-7-7" /></svg>
        </div>
      </div>
      <div className="flex items-center gap-3 pr-2">
        {/* Filter button */}
        <div className="relative" ref={filterRef}>
          <div 
            onClick={() => setShowFilters(!showFilters)}
            className={`w-10 h-10 rounded-full flex items-center justify-center shadow-sm border cursor-pointer transition-all ${showFilters ? 'bg-green-500 text-white border-green-400 shadow-green-500/20 scale-95' : 'bg-white dark:bg-[#1e293b] border-gray-50 dark:border-gray-800 text-gray-400 hover:text-gray-600'}`}
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
          </div>

          {showFilters && (
            <div className="absolute top-12 right-0 w-64 bg-white dark:bg-[#1e293b] border border-gray-100 dark:border-gray-800 rounded-2xl shadow-2xl p-4 animate-in fade-in slide-in-from-top-2 duration-200 z-[100]">
              <div className="text-[12px] font-bold text-gray-400 uppercase tracking-widest mb-4">Filter Assets</div>
              <div className="space-y-3">
                <div className="flex flex-col gap-1.5">
                  <span className="text-[11px] font-bold text-gray-500 dark:text-gray-400">Machine Status</span>
                  <div className="flex flex-wrap gap-1.5">
                    {['Active', 'Idle', 'Off'].map(s => (
                      <span key={s} className="px-2.5 py-1 rounded-lg bg-gray-50 dark:bg-gray-800 border border-gray-100 dark:border-gray-700 text-[10px] font-bold text-gray-600 dark:text-gray-300 hover:border-green-400 cursor-pointer">{s}</span>
                    ))}
                  </div>
                </div>
                <div className="flex flex-col gap-1.5 pt-2 border-t border-gray-50 dark:border-gray-800">
                  <span className="text-[11px] font-bold text-gray-500 dark:text-gray-400">Asset Type</span>
                  <div className="flex flex-col gap-1">
                    {['Heavy Duty Tractors', 'Grain Harvesters', 'Compact Equipment'].map(t => (
                      <label key={t} className="flex items-center gap-2 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800 p-1.5 rounded-lg transition-colors">
                        <input type="checkbox" className="w-3.5 h-3.5 rounded border-gray-300 text-green-500 focus:ring-green-500" />
                        <span className="text-[11px] font-semibold text-gray-600 dark:text-gray-300">{t}</span>
                      </label>
                    ))}
                  </div>
                </div>
                <button className="w-full mt-2 py-2 bg-green-500 text-white text-[11px] font-bold rounded-xl shadow-lg shadow-green-500/20 hover:bg-green-600 transition-all">Apply Filters</button>
              </div>
            </div>
          )}
        </div>

        <div className="relative group">
          <svg className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-hover:text-green-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input 
            type="text" 
            placeholder={isInspectionPage ? "Search diseases, regions, or outbreaks..." : "Search machine or renter..."} 
            className="pl-11 pr-4 py-2 w-64 rounded-full bg-white dark:bg-[#1e293b] border border-gray-50 dark:border-gray-800 shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500/20 text-sm font-semibold placeholder-gray-400 text-gray-800 dark:text-white transition-all" 
          />
        </div>

        {/* Settings — links to /users/settings */}
        <Link href="/users/settings" title="Settings">
          <div className="w-10 h-10 bg-white dark:bg-[#1e293b] rounded-full flex items-center justify-center shadow-sm border border-gray-50 dark:border-gray-800 cursor-pointer text-gray-400 hover:text-green-500 transition-colors hover:scale-110 active:scale-95">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </div>
        </Link>

        {/* Notifications bell */}
        <div className="relative" ref={notifRef}>
          <div 
            onClick={() => setShowNotifications(!showNotifications)}
            className={`w-10 h-10 rounded-full flex items-center justify-center shadow-sm border cursor-pointer transition-all ${showNotifications ? 'bg-orange-500 text-white border-orange-400 shadow-orange-500/20 scale-95' : 'bg-white dark:bg-[#1e293b] border-gray-50 dark:border-gray-800 text-gray-400 hover:text-gray-600'}`}
          >
            <div className={`absolute top-2 right-2.5 w-1.5 h-1.5 bg-red-500 rounded-full ${showNotifications ? 'hidden' : 'animate-pulse'}`}></div>
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
          </div>

          {showNotifications && (
            <div className="absolute top-12 right-0 w-80 bg-white dark:bg-[#1e293b] border border-gray-100 dark:border-gray-800 rounded-2xl shadow-2xl overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200 z-[100]">
              <div className="flex items-center justify-between px-4 py-3 bg-gray-50/50 dark:bg-gray-800/50 border-b border-gray-100 dark:border-gray-800">
                <span className="text-[12px] font-extrabold text-gray-700 dark:text-gray-200 uppercase tracking-widest">Recent Activity</span>
                <span className="text-[10px] font-bold text-green-500 cursor-pointer hover:underline">Mark all read</span>
              </div>
              <div className="max-h-[350px] overflow-y-auto no-scrollbar">
                {randomNotifications.map((n) => (
                  <div key={n.id} className="p-3 border-b border-gray-50 dark:border-gray-800/50 hover:bg-gray-50 dark:hover:bg-gray-800/80 transition-colors cursor-pointer group">
                    <div className="flex gap-3">
                      <div className={`w-8 h-8 rounded-full flex-shrink-0 flex items-center justify-center ${
                        n.type === 'critical' ? 'bg-red-50 text-red-500' :
                        n.type === 'warning' ? 'bg-orange-50 text-orange-500' :
                        n.type === 'success' ? 'bg-green-50 text-green-500' : 'bg-blue-50 text-blue-500'
                      }`}>
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <circle cx="12" cy="12" r="10" strokeWidth="2" />
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01" />
                        </svg>
                      </div>
                      <div className="flex-1">
                        <div className="text-[11px] font-bold text-gray-700 dark:text-gray-200 leading-tight group-hover:text-gray-900 dark:group-hover:text-white transition-colors">{n.text}</div>
                        <div className="text-[9px] text-gray-400 font-bold mt-1 uppercase tracking-tighter">{n.time}</div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
              <div className="p-2 border-t border-gray-100 dark:border-gray-800 text-center">
                <button className="text-[10px] font-bold text-gray-500 hover:text-green-500 py-1 transition-colors uppercase tracking-widest">View all activity history</button>
              </div>
            </div>
          )}
        </div>

        {/* Profile avatar */}
        <div className="relative" ref={accountRef}>
          <div 
            onClick={() => setShowAccount(!showAccount)}
            className={`w-10 h-10 rounded-full border-2 shadow-sm cursor-pointer overflow-hidden transition-all active:scale-95 ${showAccount ? 'border-green-500 ring-4 ring-green-500/10' : 'border-white dark:border-gray-800 hover:border-green-400'}`}
          >
            <img src="https://api.dicebear.com/7.x/notionists/svg?seed=Felix" alt="Profile" className="w-full h-full object-cover" />
          </div>

          {showAccount && (
            <div className="absolute top-12 right-0 w-64 bg-white dark:bg-[#1e293b] border border-gray-100 dark:border-gray-800 rounded-[24px] shadow-2xl overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200 z-[100]">
              {/* Dropdown Header */}
              <div className="p-4 bg-gray-50/50 dark:bg-gray-800/30 border-b border-gray-50 dark:border-gray-800/60">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full border border-gray-200 dark:border-gray-700 overflow-hidden">
                    <img src="https://api.dicebear.com/7.x/notionists/svg?seed=Felix" alt="Felix" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[13px] font-black text-gray-800 dark:text-white truncate">Felix V. O'Connell</div>
                    <div className="text-[10px] font-bold text-gray-400 truncate">felix.agri@nexus.com</div>
                  </div>
                </div>
                <div className="mt-3 py-1.5 px-3 bg-green-500/10 rounded-xl border border-green-500/20 flex items-center justify-between">
                  <span className="text-[10px] font-bold text-green-600 dark:text-green-400 uppercase tracking-widest">Wallet</span>
                  <span className="text-[12px] font-black text-green-600 dark:text-green-400">$1,248.50</span>
                </div>
              </div>

              {/* Menu Items */}
              <div className="p-2">
                {(isInspectionPage ? [
                  { label: 'My Health Certs', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                  )},
                  { label: 'Outbreak Reports', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5.882V19.297A1.707 1.707 0 019.293 21H4a1 1 0 01-1-1V5a1 1 0 011-1h5.385c.842 0 1.554.544 1.808 1.332zM11 5.882V19.297A1.707 1.707 0 0012.707 21H18a1 1 0 001-1V5a1 1 0 00-1-1h-5.385c-.842 0-1.554.544-1.808 1.332z" /></svg>
                  )},
                  { label: 'Diagnostic History', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" /></svg>
                  )},
                  { label: 'Region Alerts', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
                  )},
                ] : [
                  { label: 'My Profile', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                  )},
                  { label: 'My Agri-Bookings', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                  )},
                  { label: 'Equipment Inventory', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
                  )},
                  { label: 'Support & Help', icon: (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z" /></svg>
                  )},
                ]).map((item) => (
                  <div key={item.label} className="flex items-center gap-3 px-3 py-2 rounded-xl text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 hover:text-green-600 dark:hover:text-green-400 transition-colors cursor-pointer group">
                    <div className="text-gray-400 group-hover:text-green-500 transition-colors">{item.icon}</div>
                    <span className="text-[12px] font-bold">{item.label}</span>
                  </div>
                ))}
              </div>

              {/* Logout Footer */}
              <div className="p-2 border-t border-gray-50 dark:border-gray-800/60 bg-gray-50/20">
                <div className="flex items-center gap-3 px-3 py-2 rounded-xl text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 transition-colors cursor-pointer group">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" /></svg>
                  <span className="text-[12px] font-black uppercase tracking-widest">Logout</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
