"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { UserCheck, Tractor, ArrowRight, ShieldCheck, Database, Sun, Moon, Sparkles, Leaf } from "lucide-react";

/**
 * AGRISENSE V2.0 - Premium Landing Page
 * ─────────────────────────────────────────────────────────────────────────────
 * Palette: 
 * - Mint Cream (#F1FAF6)
 * - Deep Forest-Charcoal (#1F382E)
 * - Spring Green (#28D18C)
 * - Hunter Green (#4C7B65)
 */

export default function LandingPage() {
  const [isDark, setIsDark] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  return (
    <div className={`min-h-screen relative overflow-hidden font-['Poppins',sans-serif] transition-colors duration-700 
      ${isDark ? "bg-[#0b1410] text-[#E6F5EC]" : "bg-[#F1FAF6] text-[#1F382E]"}`}>

      {/* ── DYNAMIC SVG BACKGROUND PATTERN ── */}
      <div className="absolute inset-0 opacity-[0.15] pointer-events-none" 
        style={{ 
          backgroundImage: `url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNTAiIGhlaWdodD0iNzUiIHZpZXdCb3g9IjAgMCAxNTAgNzUiPiA8ZyBmaWxsPSJub25lIiBzdHJva2U9IiMyOEQxOEMyOCIgc3Ryb2tlLXdpZHRoPSIwLjciPiA8cGF0aCBkPSJNLTAuNSwzMS41IEMtMC41LDMxLjUgNzQsMTQgMTUwLDM0LjUiIC8+IDxwYXRoIGQ9Ik0tMC41LDY5LjUgQy0wLjUsNjkuNSAzOC4yLDYwIDEwNC43LDU4LjIiIC8+IDxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDUwLDYwKSBzY2FsZSgwLjI1KSI+PHBhdGggZD0iTTUwLDEwIEM1MCw1MCAxMDAsNTAgMTAwLDEwIE0xMDAsMTAgQzEwMCwtMzAgNTAsLTMwIDUwLDEwIi8+PC9nPjwvZz48L3N2Zz4=")`,
          backgroundSize: '300px 150px'
        }} 
      />

      {/* ── FLOATING PARTICLES (Dynamism) ── */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {[...Array(6)].map((_, i) => (
          <div key={i} 
            className="absolute animate-float opacity-20"
            style={{
              top: `${Math.random() * 100}%`,
              left: `${Math.random() * 100}%`,
              animationDelay: `${i * 1.5}s`,
              animationDuration: `${10 + Math.random() * 10}s`
            }}
          >
            <Leaf className={`text-[#28D18C] w-${4 + (i%4)} h-${4 + (i%4)}`} />
          </div>
        ))}
      </div>

      <div className="container mx-auto px-6 py-8 relative z-10 flex flex-col min-h-screen">
        
        {/* ── HEADER ── */}
        <header className="flex justify-between items-center mb-16 animate-in slide-in-from-top duration-700">
          <div className="flex items-center gap-4">
            <div className="grid grid-cols-2 gap-1 bg-[#E6F5EC] p-2 rounded-xl shadow-sm border border-[#28D18C20]">
              <div className="w-2.5 h-2.5 rounded-sm bg-[#28D18C]" />
              <div className="w-2.5 h-2.5 rounded-sm bg-[#B2EFD2]" />
              <div className="w-2.5 h-2.5 rounded-sm bg-[#28D18C]" />
              <div className="w-2.5 h-2.5 rounded-sm bg-[#B2EFD2]" />
            </div>
            <span className="text-lg font-bold tracking-tight uppercase">AgriSense V2.0</span>
          </div>

          <div className="flex items-center gap-4">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm border shadow-sm
              ${isDark ? "bg-[#1F382E] border-[#28D18C40] text-white" : "bg-[#2A3C32] border-white text-white"}`}>
              N
            </div>
          </div>
        </header>

        {/* ── HERO SECTION ── */}
        <main className="flex-1 flex flex-col items-center justify-center text-center">
          <div className="max-w-4xl mx-auto mb-20 animate-in fade-in zoom-in duration-1000">
             <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full mb-6 bg-[#28D18C15] border border-[#28D18C25]">
               <Sparkles className="w-4 h-4 text-[#28D18C]" />
               <span className="text-xs font-black text-[#28D18C] uppercase tracking-widest">Next-Gen Surveillance</span>
             </div>
             
             <h1 className={`text-6xl md:text-8xl font-black mb-8 tracking-tighter leading-[0.9] 
               ${isDark ? "text-white" : "text-[#1F382E]"}`}>
               The Future of <br /> 
               <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#28D18C] to-[#1FAF7A] animate-gradient-x">
                 Agriculture.
               </span>
             </h1>
             
             <p className={`text-lg md:text-xl max-w-2xl mx-auto font-medium leading-relaxed opacity-80
               ${isDark ? "text-[#E6F5EC]" : "text-[#4C7B65]"}`}>
               Choose your portal to access specialized tools for field inspection 
               or high-performance machinery rental.
             </p>
          </div>

          {/* ── PORTAL CARDS ── */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-10 w-full max-w-5xl px-4 pb-20">
            {/* Card 1: Official Inspector */}
            <Link 
              href="/login?role=inspector"
              className={`group relative p-8 rounded-[38px] transition-all duration-700 border hover:scale-[1.03] hover:-translate-y-2
                ${isDark 
                  ? "bg-[#16251f]/80 border-[#28D18C20] shadow-[0_20px_50px_rgba(0,0,0,0.5)]" 
                  : "bg-white border-white shadow-[0_25px_60px_rgba(40,209,140,0.08)] hover:shadow-[0_45px_100px_rgba(40,209,140,0.15)]"
                }`}
            >
              <div className="absolute top-6 right-8 opacity-[0.05] group-hover:opacity-10 transition-opacity">
                <Database size={120} strokeWidth={1} />
              </div>

              <div className="flex flex-col h-full gap-6">
                <div className="w-14 h-14 rounded-2xl bg-[#E6F5EC] flex items-center justify-center p-3 group-hover:rotate-12 transition-transform duration-500">
                  <UserCheck className="text-[#28D18C] w-full h-full" />
                </div>
                
                <div className="text-left">
                  <h2 className="text-3xl font-extrabold mb-3 tracking-tight">Official Inspector</h2>
                  <p className="opacity-70 font-medium leading-relaxed">
                    Diagnose pathogens, monitor heatmaps, and analyze national crop health metrics in real-time.
                  </p>
                </div>

                <div className="flex items-center gap-2 text-[#28D18C] font-black uppercase text-sm tracking-widest mt-auto group-hover:gap-4 transition-all">
                  Analyze Fields <ArrowRight className="w-5 h-5" />
                </div>
              </div>
            </Link>

            {/* Card 2: Rental Farmer */}
            <Link 
              href="/login?role=farmer"
              className={`group relative p-8 rounded-[38px] transition-all duration-700 border hover:scale-[1.03] hover:-translate-y-2
                ${isDark 
                  ? "bg-[#16251f]/80 border-[#28D18C20] shadow-[0_20px_50px_rgba(0,0,0,0.5)]" 
                  : "bg-white border-white shadow-[0_25px_60px_rgba(40,209,140,0.08)] hover:shadow-[0_45px_100px_rgba(40,209,140,0.15)]"
                }`}
            >
              <div className="absolute top-6 right-8 opacity-[0.05] group-hover:opacity-10 transition-opacity">
                <Tractor size={120} strokeWidth={1} />
              </div>

              <div className="flex flex-col h-full gap-6">
                <div className="w-14 h-14 rounded-2xl bg-[#E6F5EC] flex items-center justify-center p-3 group-hover:-rotate-12 transition-transform duration-500">
                  <Tractor className="text-[#2A6B43] w-full h-full" />
                </div>
                
                <div className="text-left">
                  <h2 className="text-3xl font-extrabold mb-3 tracking-tight">Rental Farmer</h2>
                  <p className="opacity-70 font-medium leading-relaxed">
                    Rent machinery, track active sessions, and monitor your fleet’s telemetry via PostGIS tracking.
                  </p>
                </div>

                <div className="flex items-center gap-2 text-[#28D18C] font-black uppercase text-sm tracking-widest mt-auto group-hover:gap-4 transition-all">
                  Manage Fleet <ArrowRight className="w-5 h-5" />
                </div>
              </div>
            </Link>
          </div>
        </main>

        {/* ── FOOTER ── */}
        <footer className="py-10 border-t border-[#28D18C15] flex flex-col md:flex-row justify-center items-center gap-6 animate-in slide-in-from-bottom duration-700">
          <div className="flex items-center gap-3">
             <div className="bg-[#28D18C15] p-2 rounded-lg">
               <ShieldCheck className="w-5 h-5 text-[#28D18C]" />
             </div>
             <p className="text-sm font-bold tracking-tight opacity-60">Enterprise Grade Security</p>
          </div>
          <div className="hidden md:block w-1.5 h-1.5 rounded-full bg-[#28D18C40]" />
          <p className="text-sm font-bold tracking-tight opacity-60">Build v2.1.0-Release</p>
        </footer>

      </div>

      {/* ── THEME TOGGLE ── */}
      <button 
        onClick={() => setIsDark(!isDark)}
        className={`fixed bottom-8 right-8 w-14 h-14 rounded-full border-2 border-[#28D18C] flex items-center justify-center transition-all duration-300 z-[100] group
          ${isDark ? "bg-[#1F382E] text-white hover:bg-[#2A3C32]" : "bg-white text-[#1F382E] hover:bg-[#F1FAF6] shadow-xl"}`}
      >
        {isDark ? <Sun className="w-6 h-6 animate-spin-slow" /> : <Moon className="w-6 h-6 animate-pulse" />}
      </button>

      {/* Custom Keyframe Animations */}
      <style jsx global>{`
        @keyframes float {
          0%, 100% { transform: translate(0, 0) rotate(0deg); }
          33% { transform: translate(30px, -50px) rotate(120deg); }
          66% { transform: translate(-20px, 20px) rotate(240deg); }
        }
        .animate-float {
          animation: float linear infinite;
        }
        .animate-spin-slow {
          animation: spin 8s linear infinite;
        }
        @keyframes gradient-x {
          0%, 100% { background-size: 200% 200%; background-position: left center; }
          50% { background-size: 200% 200%; background-position: right center; }
        }
        .animate-gradient-x {
          animation: gradient-x 5s ease infinite;
        }
      `}</style>
    </div>
  );
}


