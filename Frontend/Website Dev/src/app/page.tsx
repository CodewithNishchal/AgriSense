"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { 
  Database, Tractor, Play, Leaf, Map,
  ChevronDown, Hexagon, Star, Droplet, Sprout, ArrowRight, ScanLine
} from "lucide-react";

export default function LandingPage() {
  const [mounted, setMounted] = useState(false);
  const [hoveredSide, setHoveredSide] = useState<'left' | 'right' | null>(null);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  return (
    <div className="min-h-screen relative overflow-hidden font-['Poppins',sans-serif] text-[#1a231f]">
      
      {/* BACKGROUND SPLIT */}
      <div className="absolute inset-0 flex z-[0]">
        {/* Left Side Mint to deeper green bottom */}
        <div className="w-1/2 relative overflow-hidden bg-gradient-to-b from-[#cae9e3] via-[#bae1da] to-[#85d8be]">
            {/* Vibrant Green glow behind the button area */}
            <div className="absolute bottom-[20%] left-[80%] w-[800px] h-[800px] bg-[#53f0b2]/50 rounded-full blur-[120px] transform -translate-x-1/2 translate-y-1/4"></div>
        </div>
        {/* Right Side Warm Peach to muted beige */}
        <div className="w-1/2 relative overflow-hidden bg-gradient-to-b from-[#fae0cb] via-[#ebd2c0] to-[#d8c7ba]">
            {/* Subtle warm glow at bottom */}
            <div className="absolute bottom-[20%] right-[80%] w-[700px] h-[700px] bg-[#faebd7]/60 rounded-full blur-[100px] transform translate-x-1/2 translate-y-1/4"></div>
        </div>
      </div>

      {/* HERO SPLIT IMAGE */}
      <div className="absolute inset-0 flex justify-center pointer-events-none z-[1]">
        <img 
          src="/split_hero_perfect.png" 
          alt="Split Hero" 
          className="h-[105%] w-auto object-cover max-w-none opacity-95 transition-all duration-1000 mix-blend-multiply" 
          style={{ 
            objectPosition: '50% 50%', 
            minWidth: '1000px',
            WebkitMaskImage: 'radial-gradient(ellipse at 50% 40%, black 35%, transparent 75%)',
            maskImage: 'radial-gradient(ellipse at 50% 40%, black 35%, transparent 75%)'
          }}
        />
        {/* Midline precise split line */}
        <div className="absolute inset-y-0 left-1/2 w-[2px] bg-gradient-to-b from-transparent via-white/50 to-transparent transform -translate-x-1/2 z-[2]"></div>
      </div>

      {/* DYNAMIC SCENE LIGHTING OVERLAYS */}
      {/* Dims the right side when left is hovered */}
      <div className={`absolute inset-0 left-1/2 w-1/2 bg-black/40 backdrop-blur-[4px] transition-all duration-700 pointer-events-none z-[3] ${hoveredSide === 'left' ? 'opacity-100' : 'opacity-0'}`}></div>
      {/* Dims the left side when right is hovered */}
      <div className={`absolute inset-0 w-1/2 bg-black/40 backdrop-blur-[4px] transition-all duration-700 pointer-events-none z-[3] ${hoveredSide === 'right' ? 'opacity-100' : 'opacity-0'}`}></div>


      {/* OVERLAY / FOREGROUND UI */}
      <div className="relative z-10 flex flex-col h-screen max-w-[1600px] mx-auto px-4 xl:px-8 pt-8 pb-0">
        
        {/* TOP NAVBAR */}
        <nav className="grid grid-cols-3 items-center mb-auto animate-in slide-in-from-top duration-700 relative z-40">
          {/* Left: Logo */}
          <div className="flex justify-start">
            <div className="flex items-center gap-4 bg-white/90 backdrop-blur-md px-6 py-3 rounded-full shadow-sm border border-white/50">
              <div className="w-14 h-14 flex items-center justify-center overflow-hidden shrink-0">
                 <img src="/agrisense_logo.png" alt="AgriSense Logo" className="w-full h-full object-contain scale-125 hover:scale-110 transition-transform cursor-pointer" />
              </div>
              <span className="text-3xl font-black tracking-tighter text-[#1a231f]">AgriSense<span className="text-green-600 drop-shadow-sm">°</span></span>
            </div>
          </div>

          {/* Center: Nav Links */}
          <div className="hidden md:flex justify-center">
            <div className="flex items-center gap-10 font-semibold text-sm text-[#1a231f] bg-white/90 backdrop-blur-md px-10 py-3.5 rounded-full shadow-sm border border-white/50">
              <div className="flex items-center gap-1 cursor-pointer hover:text-green-700 transition-colors">Portals <ChevronDown className="w-4 h-4" /></div>
              <div className="cursor-pointer hover:text-green-700 transition-colors">Help</div>
              <div className="flex items-center gap-1 cursor-pointer hover:text-green-700 transition-colors">Pricing <ChevronDown className="w-4 h-4" /></div>
              <div className="cursor-pointer hover:text-green-700 transition-colors">Partners</div>
            </div>
          </div>

          {/* Right: CTA Button */}
          <div className="flex justify-end">
            <Link href="/login" className="px-8 py-3.5 bg-white/90 rounded-full border border-white/50 font-bold text-sm flex items-center gap-2 hover:bg-white hover:scale-105 backdrop-blur-md transition-all shadow-md">
              Get the App <Play className="w-4 h-4 fill-[#1a231f]" />
            </Link>
          </div>
        </nav>

        {/* HERO CONTENT */}
        <div className="relative flex-1 w-full mt-12 flex">
          
          {/* LEFT SIDE (Inspector UI) */}
          <div 
             className={`w-1/2 relative h-full transition-transform duration-700 ${hoveredSide === 'left' ? 'scale-[1.02] z-30' : 'z-20'}`}
             onMouseEnter={() => setHoveredSide('left')}
             onMouseLeave={() => setHoveredSide(null)}
          >
             {/* Hitbox */}
             <div className="absolute inset-0 cursor-default" />
             
             {/* HUGE TEXT BLOCK */}
            <div className="absolute left-0 top-[8%] z-20 pointer-events-none min-w-[600px] hidden lg:hidden">
              <div className="flex gap-2 mb-6">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-8 h-8 fill-[#FFD700] text-[#FFD700] drop-shadow-md" />
                ))}
              </div>
              <h1 className="text-[5.5rem] leading-[0.95] font-black text-white drop-shadow-2xl tracking-tighter"
                  style={{ WebkitTextStroke: '1.5px rgba(26, 35, 31, 0.1)' }}>
                The New <br />
                Level of Care <br />
                for Your <br />
                Harvest.
              </h1>
            </div>

            {/* Top Left Badge */}
            <div className="absolute top-[8%] right-[10%] bg-white/40 backdrop-blur-sm px-5 py-3 rounded-full border border-white/30 shadow-sm flex items-center gap-3 transform -rotate-1 opacity-50 animate-in fade-in duration-1000 delay-300">
               <Leaf className="w-5 h-5 text-green-700/60" />
               <span className="text-sm font-bold text-gray-800/60">Tough Pathogens? We'll spot them instantly!</span>
            </div>

            {/* Drone/Scan Icon */}
            <div className="absolute top-[35%] right-[25%] w-16 h-16 bg-white/40 backdrop-blur-sm border border-white/40 rounded-full flex items-center justify-center shadow-lg transform rotate-12 opacity-40 hover:opacity-100 transition-all cursor-pointer">
               <ScanLine className="w-7 h-7 text-gray-800/50" />
            </div>

            {/* Map Icon Box */}
            <div className="absolute top-[60%] left-[8%] w-16 h-16 pointer-events-auto cursor-pointer hover:scale-110 opacity-30 hover:opacity-100 transition-all bg-gradient-to-tr from-green-500/50 to-emerald-300/50 rounded-3xl flex items-center justify-center shadow-lg skew-y-3">
               <Map className="w-8 h-8 text-white/70" />
            </div>

            {/* BUTTON / Inspector CTA */}
            <div className="absolute bottom-[20%] right-[10%] pointer-events-auto z-30">
               <Link href="/login?role=inspector" className="group flex items-center gap-3 bg-white/95 hover:bg-white text-green-600 px-6 py-4 rounded-3xl shadow-[0_0_40px_rgba(40,209,140,0.5)] transition-all hover:scale-[1.03] border border-green-200">
                  <div className="bg-green-100 p-2 rounded-xl">
                    <Database className="w-6 h-6 text-green-700" />
                  </div>
                  <span className="font-extrabold tracking-widest text-green-700 uppercase text-sm">Analyze Fields <ArrowRight className="inline w-5 h-5 ml-1 group-hover:translate-x-1 transition-transform" /></span>
               </Link>
            </div>
          </div>

          {/* RIGHT SIDE (Farmer UI) */}
          <div 
             className={`w-1/2 relative h-full hidden lg:block transition-transform duration-700 ${hoveredSide === 'right' ? 'scale-[1.02] z-30' : 'z-20'}`}
             onMouseEnter={() => setHoveredSide('right')}
             onMouseLeave={() => setHoveredSide(null)}
          >
             {/* Hitbox */}
             <div className="absolute inset-0 cursor-default" />
            
            {/* Top Right Mini Icons */}
            <div className="absolute top-[18%] left-[10%] w-12 h-12 bg-white/30 backdrop-blur border border-white/30 rounded-full flex items-center justify-center shadow-sm opacity-40">
               <Hexagon className="w-5 h-5 text-orange-600/50" />
            </div>
            
            {/* Right Badge */}
            <div className="absolute top-[40%] right-[15%] bg-[#efdcd0]/40 backdrop-blur-sm px-5 py-3 rounded-full border border-white/30 shadow-sm flex items-center gap-3 transform rotate-2 opacity-50 animate-in fade-in duration-1000 delay-500">
               <span className="text-sm font-bold text-gray-800/60">We'll Handle Any Terrain — Guaranteed</span>
               <Sprout className="w-5 h-5 text-[#885a3a]/60" />
            </div>

            <div className="absolute top-[60%] right-[32%] w-12 h-12 bg-white/20 backdrop-blur border border-white/30 rounded-full flex items-center justify-center shadow-sm opacity-30">
               <Droplet className="w-5 h-5 text-gray-700/50" />
            </div>

             {/* BUTTON / Farmer CTA */}
            <div className="absolute bottom-[20%] left-[8%] pointer-events-auto z-30">
               <Link href="/login?role=farmer" className="group flex items-center gap-3 bg-white/60 hover:bg-white text-orange-800 border-2 border-white/50 backdrop-blur-md px-6 py-4 rounded-3xl transition-all hover:scale-[1.03] shadow-[0_0_30px_rgba(255,255,255,0.3)] hover:shadow-[0_0_40px_rgba(255,255,255,0.8)]">
                  <div className="bg-orange-100 p-2 rounded-xl group-hover:bg-orange-200 transition-colors">
                    <Tractor className="w-6 h-6 text-orange-700" />
                  </div>
                  <span className="font-extrabold tracking-widest text-orange-900 uppercase text-sm">Manage Fleet <ArrowRight className="inline w-5 h-5 ml-1 group-hover:translate-x-1 transition-transform" /></span>
               </Link>
            </div>
          </div>
        </div>

      </div>
      
    </div>
  );
}
