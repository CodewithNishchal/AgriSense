"use client";

import React, { useState } from 'react';
import Link from 'next/link';
import { 
  ArrowLeft, 
  Plus, 
  Search, 
  MapPin, 
  Clock, 
  Minus, 
  ChevronRight, 
  CheckCircle2, 
  Info,
  Navigation
} from 'lucide-react';

export default function NewBooking() {
  const [duration, setDuration] = useState(3);
  const [selectedAsset, setSelectedAsset] = useState('TRC-108');

  return (
    <div className="h-screen w-screen overflow-hidden flex flex-col bg-[#f0f4f1] dark:bg-[#0f172a] text-[#1a211b] dark:text-gray-100 transition-colors duration-500">
      
      {/* Navigation Header */}
      <nav className="h-20 px-8 flex items-center justify-between bg-white/70 dark:bg-[#1e293b]/70 backdrop-blur-xl border-b border-white/20 dark:border-gray-800/20 z-50 flex-shrink-0">
        <div className="flex items-center gap-6">
          <Link href="/users/fleetDashboard"
            className="w-10 h-10 rounded-full bg-white dark:bg-[#1e293b] border border-gray-200 dark:border-gray-800 flex items-center justify-center text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all shadow-sm active:scale-95">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div className="h-8 w-px bg-gray-300 dark:bg-gray-700"></div>
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-[#5a945b] flex items-center justify-center text-white font-bold shadow-md">
              <Plus className="w-4 h-4" />
            </div>
            <div>
              <h1 className="text-lg font-bold tracking-tight text-gray-900 dark:text-white leading-none">Create New Booking</h1>
              <p className="text-[10px] font-bold text-gray-400 dark:text-gray-500 mt-1 uppercase tracking-widest">Manual Dispatch System</p>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <button className="px-5 py-2 rounded-xl text-[12px] font-bold bg-white dark:bg-[#1e293b] border border-gray-200 dark:border-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all shadow-sm active:scale-95">
            Save Draft
          </button>
        </div>
      </nav>

      <main className="flex-1 flex w-full p-6 gap-6 overflow-hidden max-w-[1600px] mx-auto">
        
        {/* Left Column: Form Sections */}
        <div className="w-[60%] h-full overflow-y-auto no-scrollbar pr-2 pb-10 flex flex-col gap-6">
          
          {/* Section 1: Renter Details */}
          <section className="bg-white/70 dark:bg-[#1e293b]/70 backdrop-blur-xl p-6 rounded-[28px] border border-white dark:border-gray-800 shadow-sm">
            <div className="flex items-center gap-3 mb-6 border-b border-gray-100 dark:border-gray-800 pb-4 text-gray-900 dark:text-white">
              <div className="w-8 h-8 rounded-full bg-green-100 dark:bg-green-500/20 text-[#5a945b] font-black flex items-center justify-center text-sm shadow-inner">1</div>
              <h2 className="text-xl font-extrabold tracking-tight">Renter Details</h2>
            </div>

            <div className="grid grid-cols-2 gap-6">
              <div className="col-span-2 relative">
                <label className="block text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mb-2 px-1">Search Existing Farmer (Phone / Name)</label>
                <div className="relative group">
                  <Search className="w-5 h-5 absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#5a945b] transition-colors" />
                  <input type="text" placeholder="e.g., Suresh Patel or +91 98765..." 
                    className="w-full pl-11 pr-4 py-3.5 bg-white dark:bg-[#0f172a] border border-gray-200 dark:border-gray-800 rounded-2xl text-sm font-semibold focus:outline-none focus:ring-2 focus:ring-[#5a945b]/20 transition-all shadow-sm" />
                </div>
              </div>
              <div>
                <label className="block text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mb-2 px-1">Destination Field / Village</label>
                <select className="w-full px-4 py-3.5 bg-white dark:bg-[#0f172a] border border-gray-200 dark:border-gray-800 rounded-2xl text-sm font-semibold focus:outline-none focus:ring-2 focus:ring-[#5a945b]/20 text-gray-900 dark:text-white appearance-none transition-all shadow-sm">
                  <option>Borkhedi (North Sector)</option>
                  <option>Borkhedi (South Sector)</option>
                  <option>Nagpur Outskirts</option>
                  <option>+ Add New Location</option>
                </select>
              </div>
              <div>
                <label className="block text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mb-2 px-1">Estimated Distance</label>
                <div className="w-full px-4 py-3.5 bg-gray-50 dark:bg-[#0f172a] border border-gray-100 dark:border-gray-800 rounded-2xl text-sm font-bold text-gray-700 dark:text-gray-300 flex items-center gap-2 shadow-inner">
                  <MapPin className="w-4 h-4 text-[#5a945b]" />
                  4.2 km from Hub
                </div>
              </div>
            </div>
          </section>

          {/* Section 2: Equipment Selection */}
          <section className="bg-white/70 dark:bg-[#1e293b]/70 backdrop-blur-xl p-6 rounded-[28px] border border-white dark:border-gray-800 shadow-sm">
            <div className="flex items-center gap-3 mb-6 border-b border-gray-100 dark:border-gray-800 pb-4 justify-between">
              <div className="flex items-center gap-3 text-gray-900 dark:text-white">
                <div className="w-8 h-8 rounded-full bg-green-100 dark:bg-green-500/20 text-[#5a945b] font-black flex items-center justify-center text-sm shadow-inner">2</div>
                <h2 className="text-xl font-extrabold tracking-tight">Select Available Equipment</h2>
              </div>
              <span className="text-[10px] font-bold bg-[#1a211b] dark:bg-green-500 text-white dark:text-white px-3 py-1 rounded-full uppercase tracking-tighter">14 Available</span>
            </div>

            <div className="flex gap-2 mb-6 overflow-x-auto no-scrollbar pb-2">
              {['Tractors (Standard)', 'Harvesters', 'Backhoes', 'Attachments Only'].map((cat, i) => (
                <button key={cat} className={`px-5 py-2 whitespace-nowrap text-[11px] font-bold rounded-full transition-all active:scale-95 ${i === 0 ? 'bg-[#5a945b] text-white shadow-lg shadow-green-500/20' : 'bg-white dark:bg-[#0f172a] border border-gray-100 dark:border-gray-800 text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800'}`}>
                  {cat}
                </button>
              ))}
            </div>

            <div className="grid grid-cols-2 gap-5">
              {[
                { id: 'TRC-108', type: '50 HP Tractor', fuel: 92, rate: 600, color: 'text-green-500' },
                { id: 'TRC-045', type: '40 HP Tractor', fuel: 45, rate: 500, color: 'text-yellow-500' }
              ].map((asset) => (
                <div 
                  key={asset.id}
                  onClick={() => setSelectedAsset(asset.id)}
                  className={`relative cursor-pointer group p-5 rounded-[24px] border-2 transition-all flex flex-col h-full bg-white dark:bg-[#0f172a] ${selectedAsset === asset.id ? 'border-[#5a945b] shadow-xl shadow-green-500/5 bg-[#f0fdf4] dark:bg-green-950/10' : 'border-gray-100 dark:border-gray-800 hover:border-gray-200 dark:hover:border-gray-700'}`}
                >
                  <div className={`absolute top-4 right-4 w-7 h-7 bg-[#5a945b] rounded-full text-white flex items-center justify-center transition-all ${selectedAsset === asset.id ? 'opacity-100 scale-100' : 'opacity-0 scale-50'}`}>
                    <CheckCircle2 className="w-5 h-5" strokeWidth={3} />
                  </div>
                  
                  <div className="mb-4">
                    <h3 className="font-black text-gray-900 dark:text-white text-xl">{asset.id}</h3>
                    <p className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mt-1">{asset.type}</p>
                  </div>
                  
                  <div className="text-[11px] font-bold text-gray-600 dark:text-gray-400 space-y-2 mb-6 flex-1">
                    <div className="flex items-center gap-2">
                       <div className={`w-1.5 h-1.5 rounded-full ${asset.fuel > 50 ? 'bg-green-500' : 'bg-orange-500'} shadow-[0_0_8px_rgba(0,0,0,0.1)]`}></div>
                       Fuel: <span className="font-extrabold">{asset.fuel}%</span>
                    </div>
                    <div className="flex items-center gap-2">
                       <div className="w-1.5 h-1.5 rounded-full bg-blue-500 shadow-[0_0_8px_rgba(0,0,0,0.1)]"></div>
                       GPS Status: <span className="font-extrabold">Active</span>
                    </div>
                  </div>

                  <div className="border-t border-gray-100 dark:border-gray-800 pt-4 flex justify-between items-end">
                    <span className="text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest">Base Rate</span>
                    <div className="text-xl font-black text-gray-900 dark:text-white">₹{asset.rate}<span className="text-xs font-bold text-gray-400">/hr</span></div>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Section 3: Logistics */}
          <section className="bg-white/70 dark:bg-[#1e293b]/70 backdrop-blur-xl p-6 rounded-[28px] border border-white dark:border-gray-800 shadow-sm">
            <div className="flex items-center gap-3 mb-6 border-b border-gray-100 dark:border-gray-800 pb-4 text-gray-900 dark:text-white">
              <div className="w-8 h-8 rounded-full bg-green-100 dark:bg-green-500/20 text-[#5a945b] font-black flex items-center justify-center text-sm shadow-inner">3</div>
              <h2 className="text-xl font-extrabold tracking-tight">Logistics & Attachments</h2>
            </div>

            <div className="grid grid-cols-2 gap-6 mb-8">
              <div>
                <label className="block text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mb-2 px-1">Duration Needed</label>
                <div className="flex items-center border border-gray-200 dark:border-gray-800 rounded-[18px] bg-white dark:bg-[#0f172a] overflow-hidden shadow-sm">
                  <button onClick={() => setDuration(Math.max(1, duration - 1))} className="px-5 py-3.5 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 font-bold border-r border-gray-200 dark:border-gray-800 transition-colors active:bg-gray-100">
                    <Minus className="w-4 h-4" />
                  </button>
                  <div className="w-full py-3.5 text-center text-sm font-black text-gray-900 dark:text-white">
                    {duration} Hours
                  </div>
                  <button onClick={() => setDuration(duration + 1)} className="px-5 py-3.5 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 font-bold border-l border-gray-200 dark:border-gray-800 transition-colors active:bg-gray-100">
                    <Plus className="w-4 h-4" />
                  </button>
                </div>
              </div>
              <div>
                <label className="block text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mb-2 px-1">Dispatch Timing</label>
                <select className="w-full px-5 py-3.5 bg-white dark:bg-[#0f172a] border border-gray-200 dark:border-gray-800 rounded-[18px] text-sm font-black text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-[#5a945b]/20 appearance-none shadow-sm transition-all">
                  <option>Immediate (Now)</option>
                  <option>Schedule for Later Today</option>
                  <option>Schedule for Tomorrow</option>
                </select>
              </div>
            </div>

            <label className="block text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest mb-4 px-1">Add Attachments (Optional)</label>
            <div className="space-y-3">
              {[
                { name: 'Rotavator (Heavy Duty)', desc: 'Required for initial soil tilling', price: 200, checked: true },
                { name: 'Seed Drill', desc: 'Precision sowing across 2 hectares', price: 150, checked: false }
              ].map((item) => (
                <label key={item.name} className={`flex items-center justify-between p-4 border rounded-2xl cursor-pointer transition-all ${item.checked ? 'border-[#5a945b] bg-[#f0fdf4]/50 dark:bg-green-950/5' : 'border-gray-100 dark:border-gray-800 bg-white dark:bg-[#0f172a] hover:border-gray-300 dark:hover:border-gray-700'}`}>
                  <div className="flex items-center gap-4">
                    <div className={`w-5 h-5 rounded border flex items-center justify-center transition-all ${item.checked ? 'bg-[#5a945b] border-[#5a945b]' : 'border-gray-300 dark:border-gray-600'}`}>
                      {item.checked && <CheckCircle2 className="w-3.5 h-3.5 text-white" strokeWidth={4} />}
                    </div>
                    <div>
                      <div className="text-[13px] font-bold text-gray-900 dark:text-white leading-tight">{item.name}</div>
                      <div className="text-[11px] text-gray-400 dark:text-gray-500 font-bold mt-1 tracking-tight">{item.desc}</div>
                    </div>
                  </div>
                  <div className="text-sm font-black text-gray-700 dark:text-gray-300">+₹{item.price}<span className="text-[10px] text-gray-400 font-bold ml-0.5">/hr</span></div>
                </label>
              ))}
            </div>
          </section>
        </div>

        {/* Right Column: Map & Summary */}
        <div className="w-[40%] h-full flex flex-col gap-6">
          
          <div className="bg-white/70 dark:bg-[#1e293b]/70 backdrop-blur-xl rounded-[40px] overflow-hidden flex flex-col h-full border-[4px] border-white dark:border-gray-800 shadow-2xl relative">
            
            {/* Minimal Map UI */}
            <div className="h-[40%] relative bg-[#e4efe5] dark:bg-[#1e293b] overflow-hidden">
               <div className="absolute inset-0 opacity-40" style={{ 
                 backgroundImage: `linear-gradient(#5a945b 1px, transparent 1px), linear-gradient(90deg, #5a945b 1px, transparent 1px)`,
                 backgroundSize: '30px 30px'
               }}></div>
               
               {/* Animated Path Placeholder */}
               <svg className="absolute inset-0 w-full h-full p-10 overflow-visible">
                 <path d="M 40 100 Q 150 20 280 80" fill="none" stroke="#5a945b" strokeWidth="4" strokeDasharray="8 8" className="animate-pulse" />
               </svg>

               <div className="absolute top-[80px] right-[10%] z-20 flex flex-col items-center group">
                 <div className="w-5 h-5 rounded-full bg-red-500 border-[3px] border-white shadow-lg animate-bounce"></div>
                 <div className="bg-white dark:bg-gray-800 px-3 py-1.5 rounded-xl text-[9px] font-extrabold mt-2 shadow-xl border border-gray-100 dark:border-gray-700 text-red-600 uppercase tracking-widest">Farmer Location</div>
               </div>

               <div className="absolute bottom-[20px] left-[10%] z-20 flex flex-col items-center">
                 <div className="w-6 h-6 rounded-full bg-[#1a211b] border-[3px] border-white shadow-lg flex items-center justify-center">
                    <div className="w-1.5 h-1.5 bg-green-500 rounded-full animate-ping"></div>
                 </div>
                 <div className="bg-white dark:bg-gray-800 px-3 py-1.5 rounded-xl text-[9px] font-extrabold mt-2 shadow-xl border border-gray-100 dark:border-gray-700 text-gray-800 dark:text-white uppercase tracking-widest">Fleet Hub</div>
               </div>

               <div className="absolute top-6 left-6 z-20">
                 <div className="bg-white/90 dark:bg-gray-900/90 backdrop-blur-md px-4 py-2 rounded-2xl shadow-xl text-[11px] font-black text-gray-800 dark:text-gray-100 border border-white dark:border-gray-700 flex items-center gap-2">
                   <Navigation className="w-3.5 h-3.5 text-[#5a945b] fill-[#5a945b]/20" />
                   Optimized: 4.2 km
                 </div>
               </div>
            </div>

            {/* Summary Panel */}
            <div className="flex-1 bg-white dark:bg-[#1e293b] p-8 flex flex-col">
              <div className="mb-8">
                <h3 className="font-extrabold text-gray-900 dark:text-white text-2xl tracking-tight mb-1">Booking Summary</h3>
                <div className="flex items-center gap-2 text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-widest">
                  <div className="px-2 py-0.5 bg-gray-100 dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-700">{selectedAsset}</div>
                  <span className="opacity-50">•</span> 
                  Heavy Duty Tractor
                </div>
              </div>

              <div className="space-y-5 flex-1 overflow-y-auto no-scrollbar pb-6">
                <div className="flex justify-between items-center group">
                  <span className="text-gray-500 dark:text-gray-400 font-bold text-[13px]">Base Rate ({duration} hrs × ₹600)</span>
                  <span className="font-black text-gray-900 dark:text-white text-sm">₹{duration * 600}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-gray-500 dark:text-gray-400 font-bold text-[13px]">Rotavator ({duration} hrs × ₹200)</span>
                  <span className="font-black text-gray-900 dark:text-white text-sm">₹{duration * 200}</span>
                </div>
                <div className="flex justify-between items-center group">
                  <span className="text-gray-500 dark:text-gray-400 font-bold text-[13px] flex items-center gap-1.5">
                    Delivery & Logistics
                    <Info className="w-3 h-3 text-gray-300 cursor-help group-hover:text-[#5a945b] transition-colors" />
                  </span>
                  <span className="font-black text-gray-900 dark:text-white text-sm">₹150</span>
                </div>
                <div className="pt-4 border-t border-gray-50 dark:border-gray-800 flex justify-between items-center">
                  <span className="text-gray-400 dark:text-gray-500 font-bold text-[12px] uppercase tracking-widest">Platform Tax (GST 18%)</span>
                  <span className="font-black text-gray-900 dark:text-white text-sm">₹{Math.round((duration * 800 + 150) * 0.18)}</span>
                </div>
              </div>

              <div className="pt-8 border-t border-gray-100 dark:border-gray-800">
                <div className="flex justify-between items-end mb-6">
                  <div>
                    <span className="text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-[0.2em] mb-1.5 block">Total Estimated Fare</span>
                    <span className="text-4xl font-black text-[#5a945b] tracking-tighter">₹{Math.round((duration * 800 + 150) * 1.18)}</span>
                  </div>
                </div>

                <button className="group w-full py-5 rounded-[24px] text-base font-black bg-[#5a945b] text-white shadow-2xl shadow-green-500/30 hover:bg-[#457846] transition-all transform hover:-translate-y-1 active:scale-95 flex justify-center items-center gap-3">
                  <CheckCircle2 className="w-6 h-6 group-hover:scale-110 transition-transform" />
                  Confirm & Dispatch Fleet
                </button>
                <p className="text-center text-[9px] font-extrabold text-gray-400 dark:text-gray-500 mt-4 uppercase tracking-widest leading-relaxed">
                  By dispatching, you confirm asset readiness,<br/>maintenance validation & safety checks.
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
