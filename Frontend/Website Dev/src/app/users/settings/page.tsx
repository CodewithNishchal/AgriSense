"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Sidebar from "@/components/Sidebar";
import {
  User, Bell, Shield, Globe, Palette, Save, RotateCcw,
  Smartphone, Mail, Lock, Eye, Cpu
} from "lucide-react";

export default function SettingsPage() {
  const router = useRouter();
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [activeTab, setActiveTab] = useState("general");

  const glassCardStyle = "bg-white/60 dark:bg-[#1e293b]/60 rounded-[24px] p-8 shadow-[0_8px_30px_rgba(0,0,0,0.04)] backdrop-blur border border-white/80 dark:border-gray-800";
  const inputStyle = "w-full p-3 rounded-xl bg-white/70 dark:bg-[#0f172a]/50 border border-gray-200 dark:border-gray-700 text-slate-700 dark:text-slate-200 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-green-500/50 transition-all";
  const labelStyle = "block text-sm font-bold text-slate-600 dark:text-slate-400 mb-2";

  const tabs = [
    { id: "general",  label: "General",       icon: User    },
    { id: "alerts",   label: "Notifications",  icon: Bell    },
    { id: "display",  label: "Appearance",     icon: Palette },
    { id: "security", label: "Security",       icon: Shield  },
    { id: "system",   label: "System",         icon: Cpu     },
  ];

  return (
    <div className={`flex h-screen w-full overflow-hidden font-['Inter',sans-serif] bg-[#f6f8f6] dark:bg-[#0f172a] text-gray-800 dark:text-gray-200 transition-colors duration-500 ${isDarkMode ? 'dark' : ''}`}>
      <Sidebar isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} />

      <style jsx global>{`
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(8px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-fadeIn {
          animation: fadeIn 0.5s ease-out forwards;
        }
      `}</style>

      <main className="flex-1 overflow-y-auto px-8 py-6 no-scrollbar">
        <div className="mx-auto max-w-[1100px] flex flex-col min-h-full">

          {/* Page Header */}
          <div className="mb-8 flex items-center gap-4 animate-fadeIn">
            <button
              onClick={() => router.back()}
              title="Go back"
              className="w-10 h-10 flex items-center justify-center rounded-full bg-white dark:bg-[#1e293b] border border-gray-100 dark:border-gray-800 shadow-sm text-gray-400 hover:text-green-500 hover:border-green-200 dark:hover:border-green-800 transition-all active:scale-95"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
            </button>
            <div>
              <h1 className="text-3xl font-extrabold text-gray-800 dark:text-white tracking-tight">Settings</h1>
              <p className="mt-0.5 text-sm text-gray-500 dark:text-gray-400">Manage your profile, preferences, and security settings.</p>
            </div>
          </div>

          {/* Navigation Tabs */}
          <div className="flex gap-2 overflow-x-auto pb-2 mb-8 no-scrollbar animate-fadeIn [animation-delay:100ms] opacity-0">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-6 py-2.5 rounded-2xl text-sm font-bold transition-all duration-300 whitespace-nowrap ${
                  activeTab === tab.id
                    ? "bg-green-500 text-white shadow-lg shadow-green-500/30"
                    : "bg-white/70 dark:bg-[#1e293b]/70 text-slate-500 dark:text-slate-400 hover:bg-white dark:hover:bg-[#1e293b] hover:text-green-600 border border-gray-100 dark:border-gray-800"
                }`}
              >
                <tab.icon className="w-4 h-4" />
                {tab.label}
              </button>
            ))}
          </div>

          {/* Content Area */}
          <div className="flex-1 opacity-0 animate-fadeIn [animation-delay:200ms] key={activeTab}">
            {/* Using a key on the parent wrapper to trigger the animation when tab changes */}
            <div key={activeTab} className="animate-fadeIn">

              {/* GENERAL TAB */}
              {activeTab === "general" && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className={glassCardStyle}>
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-500/10 flex items-center justify-center text-green-600">
                        <User className="w-5 h-5" />
                      </div>
                      <h3 className="text-lg font-bold text-slate-800 dark:text-white">Profile Information</h3>
                    </div>
                    <div className="space-y-5">
                      <div>
                        <label className={labelStyle}>Full Name</label>
                        <input type="text" className={inputStyle} defaultValue="AgriSense Admin" />
                      </div>
                      <div>
                        <label className={labelStyle}>Role</label>
                        <input type="text" className={inputStyle} defaultValue="Fleet Manager" />
                      </div>
                      <div>
                        <label className={labelStyle}>Farm / Region ID</label>
                        <input type="text" className={inputStyle} defaultValue="AG-BUTIBORI-001" disabled />
                      </div>
                    </div>
                  </div>

                  <div className={glassCardStyle}>
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-500/10 flex items-center justify-center text-green-600">
                        <Globe className="w-5 h-5" />
                      </div>
                      <h3 className="text-lg font-bold text-slate-800 dark:text-white">Regional Settings</h3>
                    </div>
                    <div className="space-y-5">
                      <div>
                        <label className={labelStyle}>Time Zone</label>
                        <select className={inputStyle}>
                          <option>UTC +05:30 (India Standard Time)</option>
                          <option>UTC +00:00 (GMT)</option>
                          <option>UTC -05:00 (Eastern Time)</option>
                        </select>
                      </div>
                      <div>
                        <label className={labelStyle}>Language</label>
                        <select className={inputStyle}>
                          <option>English (India)</option>
                          <option>Hindi</option>
                          <option>Marathi</option>
                        </select>
                      </div>
                      <div>
                        <label className={labelStyle}>Distance Unit</label>
                        <select className={inputStyle}>
                          <option>Kilometres (km)</option>
                          <option>Miles (mi)</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* ALERTS TAB */}
              {activeTab === "alerts" && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className={glassCardStyle}>
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-500/10 flex items-center justify-center text-green-600">
                        <Mail className="w-5 h-5" />
                      </div>
                      <h3 className="text-lg font-bold text-slate-800 dark:text-white">Email Notifications</h3>
                    </div>
                    <div className="space-y-4">
                      <ToggleItem label="Maintenance Alerts" checked={true} />
                      <ToggleItem label="Weekly Fleet Reports" checked={true} />
                      <ToggleItem label="Low Fuel Warnings" checked={true} />
                      <ToggleItem label="System Downtime Notices" checked={false} />
                    </div>
                  </div>

                  <div className={glassCardStyle}>
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-500/10 flex items-center justify-center text-green-600">
                        <Smartphone className="w-5 h-5" />
                      </div>
                      <h3 className="text-lg font-bold text-slate-800 dark:text-white">Push Notifications</h3>
                    </div>
                    <div className="space-y-4">
                      <ToggleItem label="Asset Assigned / Released" checked={true} />
                      <ToggleItem label="Field Completion Alerts" checked={true} />
                      <ToggleItem label="Breakdown Reports" checked={true} />
                      <ToggleItem label="Weather Advisories" checked={false} />
                    </div>
                  </div>
                </div>
              )}

              {/* DISPLAY TAB */}
              {activeTab === "display" && (
                <div className={`w-full max-w-2xl ${glassCardStyle}`}>
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-500/10 flex items-center justify-center text-green-600">
                      <Eye className="w-5 h-5" />
                    </div>
                    <h3 className="text-lg font-bold text-slate-800 dark:text-white">Interface Customization</h3>
                  </div>
                  <div className="space-y-6">
                    <div className="flex items-center justify-between p-4 rounded-xl bg-white/50 dark:bg-[#0f172a]/40 border border-gray-100 dark:border-gray-800">
                      <span className="font-semibold text-slate-700 dark:text-slate-300">Theme Preference</span>
                      <div className="flex gap-2">
                        <button className="px-4 py-2 rounded-lg bg-gray-800 text-white text-xs font-bold">Dark</button>
                        <button className="px-4 py-2 rounded-lg bg-white text-slate-800 border shadow-sm text-xs font-bold">Light</button>
                        <button className="px-4 py-2 rounded-lg bg-green-100 text-green-700 border border-green-200 text-xs font-bold">System</button>
                      </div>
                    </div>
                    <div className="flex items-center justify-between p-4 rounded-xl bg-white/50 dark:bg-[#0f172a]/40 border border-gray-100 dark:border-gray-800">
                      <span className="font-semibold text-slate-700 dark:text-slate-300">Accent Color</span>
                      <div className="flex gap-2">
                        {['bg-green-500', 'bg-emerald-500', 'bg-teal-500', 'bg-lime-500'].map(c => (
                          <div key={c} className={`w-7 h-7 rounded-full cursor-pointer ${c} ring-2 ring-offset-2 ring-transparent hover:ring-current transition-all ${c === 'bg-green-500' ? 'ring-green-500' : ''}`} />
                        ))}
                      </div>
                    </div>
                    <ToggleItem label="High Contrast Mode" checked={false} />
                    <ToggleItem label="Reduce Motion" checked={false} />
                    <ToggleItem label="Compact Sidebar" checked={false} />
                  </div>
                </div>
              )}

              {/* SECURITY TAB */}
              {activeTab === "security" && (
                <div className={`w-full max-w-2xl ${glassCardStyle}`}>
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 rounded-xl bg-red-50 dark:bg-red-500/10 flex items-center justify-center text-red-500">
                      <Lock className="w-5 h-5" />
                    </div>
                    <h3 className="text-lg font-bold text-slate-800 dark:text-white">Security & Privacy</h3>
                  </div>
                  <div className="space-y-5">
                    <div>
                      <label className={labelStyle}>Current Password</label>
                      <input type="password" className={inputStyle} placeholder="••••••••" />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className={labelStyle}>New Password</label>
                        <input type="password" className={inputStyle} placeholder="••••••••" />
                      </div>
                      <div>
                        <label className={labelStyle}>Confirm Password</label>
                        <input type="password" className={inputStyle} placeholder="••••••••" />
                      </div>
                    </div>
                    <div className="pt-4 border-t border-gray-200/50 dark:border-gray-800">
                      <ToggleItem label="Two-Factor Authentication (2FA)" checked={true} />
                      <p className="text-xs text-slate-400 mt-1 ml-14">Secure your account with an extra layer of protection.</p>
                    </div>
                    <div className="pt-2">
                      <ToggleItem label="Login Activity Alerts" checked={true} />
                      <ToggleItem label="API Access Enabled" checked={false} />
                    </div>
                  </div>
                </div>
              )}

              {/* SYSTEM TAB */}
              {activeTab === "system" && (
                <div className={`w-full max-w-2xl ${glassCardStyle}`}>
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-500/10 flex items-center justify-center text-green-600">
                      <Cpu className="w-5 h-5" />
                    </div>
                    <h3 className="text-lg font-bold text-slate-800 dark:text-white">System Preferences</h3>
                  </div>
                  <div className="space-y-4">
                    <ToggleItem label="Auto-sync Fleet Data" checked={true} />
                    <ToggleItem label="Real-time GPS Tracking" checked={true} />
                    <ToggleItem label="Offline Mode Support" checked={false} />
                    <ToggleItem label="Analytics Data Sharing" checked={false} />
                    <div className="pt-2">
                      <label className={labelStyle}>Data Refresh Interval</label>
                      <select className={inputStyle}>
                        <option>Every 30 seconds</option>
                        <option>Every 1 minute</option>
                        <option>Every 5 minutes</option>
                      </select>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Sticky Action Bar */}
          <div className="sticky bottom-0 mt-8 p-4 rounded-2xl bg-white/80 dark:bg-[#1e293b]/80 backdrop-blur-xl border border-white/60 dark:border-gray-800 shadow-lg flex justify-end gap-4 animate-fadeIn [animation-delay:300ms] opacity-0">
            <button className="px-6 py-2.5 rounded-xl text-slate-600 dark:text-slate-300 font-semibold hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors flex items-center gap-2 text-sm">
              <RotateCcw className="w-4 h-4" /> Reset
            </button>
            <button className="px-8 py-2.5 rounded-xl bg-green-500 text-white font-bold shadow-lg shadow-green-500/30 hover:bg-green-600 transition-all flex items-center gap-2 text-sm">
              <Save className="w-4 h-4" /> Save Changes
            </button>
          </div>

        </div>
      </main>
    </div>
  );
}

const ToggleItem = ({ label, checked }: { label: string; checked: boolean }) => (
  <div className="flex items-center justify-between py-2 px-1">
    <span className="font-semibold text-slate-700 dark:text-slate-300 text-sm">{label}</span>
    <label className="relative inline-flex items-center cursor-pointer">
      <input type="checkbox" className="sr-only peer" defaultChecked={checked} />
      <div className="w-11 h-6 bg-gray-200 dark:bg-gray-700 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-green-500"></div>
    </label>
  </div>
);
