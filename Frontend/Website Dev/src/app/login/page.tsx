"use client";

import React, { useState, Suspense, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { toast } from "react-hot-toast";
import {
  Tractor,
  UserCheck,
  Mail,
  Lock,
  Loader2,
  Eye,
  EyeOff,
  ChevronRight,
  Leaf,
  Wheat,
  CheckCircle2,
  MapPin,
  Activity,
  Satellite,
  Wrench,
  Key,
  IndianRupee,
  BadgeCheck,
  Handshake,
} from "lucide-react";

// ─── Slider Data ──────────────────────────────────────────────────────────────
const inspectorSlides = [
  {
    src: "/agri-bg.png",
    badge: "Inspection Network Live",
    title: "Precision Agriculture Diagnostics",
    desc: "Real-time field health, pathogen detection & national analytics.",
    stats: [
      { icon: Leaf, label: "Crop Health", value: "94.2%" },
      { icon: Wheat, label: "Fields Scanned", value: "128" },
      { icon: CheckCircle2, label: "Alerts Resolved", value: "97%" },
    ],
  },
  {
    src: "/agri-bg2.png",
    badge: "Fleet Aerial Survey",
    title: "Harvesting Intelligence, Field by Field",
    desc: "Golden-harvest drone tracking & yield estimation models.",
    stats: [
      { icon: Satellite, label: "Drones Active", value: "14" },
      { icon: Activity, label: "Yield Accuracy", value: "98.1%" },
      { icon: MapPin, label: "Districts", value: "22" },
    ],
  },
  {
    src: "/agri-bg3.png",
    badge: "Crop Pattern Analysis",
    title: "Geometric Precision, Infinite Scale",
    desc: "Segmentation models identify crop borders & irrigation zones.",
    stats: [
      { icon: Wheat, label: "Zones Mapped", value: "340" },
      { icon: Leaf, label: "Soil Quality", value: "Good" },
      { icon: CheckCircle2, label: "Coverage", value: "87%" },
    ],
  },
  {
    src: "/agri-bg4.png",
    badge: "Harvest Season Operations",
    title: "Dusk-to-Dawn Harvest Monitoring",
    desc: "Machine vision ensures zero crop wastage across paddy fields.",
    stats: [
      { icon: Activity, label: "Efficiency", value: "96.4%" },
      { icon: Wheat, label: "Tons Tracked", value: "2,400" },
      { icon: CheckCircle2, label: "Fields Done", value: "84" },
    ],
  },
];

const farmerSlides = [
  {
    src: "/agri-bg.png",
    badge: "Fleet Operations Live",
    title: "Smart Machinery Rental Network",
    desc: "Manage your fleet, track live rentals & maximize field revenue.",
    stats: [
      { icon: Tractor, label: "Available", value: "12 / 21" },
      { icon: Activity, label: "Active Rentals", value: "7" },
      { icon: Wheat, label: "Revenue Today", value: "₹24,800" },
    ],
  },
  {
    src: "/agri-bg2.png",
    badge: "Heavy Duty Tractors",
    title: "Power Where You Need It",
    desc: "Dispatch your heaviest machinery instantly across all districts.",
    stats: [
      { icon: Tractor, label: "Tractors", value: "8 Ready" },
      { icon: MapPin, label: "Districts", value: "5" },
      { icon: Activity, label: "Utilisation", value: "78%" },
    ],
  },
  {
    src: "/agri-bg3.png",
    badge: "Aerial Asset Tracking",
    title: "Know Where Every Machine Is",
    desc: "Live GPS telematics for your full fleet — always in the picture.",
    stats: [
      { icon: MapPin, label: "GPS Pinged", value: "21 / 21" },
      { icon: Activity, label: "On Time", value: "94%" },
      { icon: Wrench, label: "Maintenance", value: "2" },
    ],
  },
  {
    src: "/agri-bg4.png",
    badge: "Harvest Season Rush",
    title: "Scale Up for Peak Season",
    desc: "Auto-queue rentals and keep every harvester earning through dusk.",
    stats: [
      { icon: Tractor, label: "Harvesters", value: "6 Active" },
      { icon: Activity, label: "Bookings", value: "17" },
      { icon: Wheat, label: "Revenue ETA", value: "₹58k" },
    ],
  },
];

const lenderSlides = [
  {
    src: "/agri-bg5.png",
    badge: "Lender Network Live",
    title: "Your Fleet, Your Business",
    desc: "List your tractors, track bookings & earn passive income every season.",
    stats: [
      { icon: Tractor, label: "Listed Assets", value: "21" },
      { icon: IndianRupee, label: "Monthly Earn", value: "₹1.2L" },
      { icon: BadgeCheck, label: "Verified Lender", value: "Yes" },
    ],
  },
  {
    src: "/agri-bg6.png",
    badge: "Rental Agreements",
    title: "Seamless Deals, Every Time",
    desc: "Digital rental agreements, auto-invoicing & secure payment tracking.",
    stats: [
      { icon: Handshake, label: "Deals Closed", value: "340" },
      { icon: Key, label: "Active Keys", value: "7" },
      { icon: Activity, label: "Avg Duration", value: "3.4 days" },
    ],
  },
  {
    src: "/agri-bg2.png",
    badge: "Asset Performance",
    title: "Maximum Uptime, Zero Gaps",
    desc: "Track utilisation per asset — know which machines to service or retire.",
    stats: [
      { icon: Activity, label: "Utilisation", value: "82%" },
      { icon: Wrench, label: "Serviced", value: "3 / 21" },
      { icon: IndianRupee, label: "ROI per Unit", value: "₹5,800" },
    ],
  },
  {
    src: "/agri-bg4.png",
    badge: "Peak Season Earnings",
    title: "Harvest Season, Peak Profits",
    desc: "Demand surges 3× — auto-price your fleet for maximum seasonal revenue.",
    stats: [
      { icon: IndianRupee, label: "Season Revenue", value: "₹4.8L" },
      { icon: Tractor, label: "Rented Out", value: "19 / 21" },
      { icon: BadgeCheck, label: "On-Time Rate", value: "96%" },
    ],
  },
];

// ─── Right Panel with Image Slider ───────────────────────────────────────────
function RightPanel({ role }: { role: string }) {
  const slides = role === "inspector" ? inspectorSlides : role === "lender" ? lenderSlides : farmerSlides;
  const accent = role === "inspector" ? "#10b981" : role === "lender" ? "#f59e0b" : "#3b82f6";
  const [current, setCurrent] = useState(0);
  const [textVisible, setTextVisible] = useState(true);

  // Auto-advance every 4 s: fade text out → swap data → fade back in
  useEffect(() => {
    const timer = setInterval(() => {
      setTextVisible(false);
      setTimeout(() => {
        setCurrent(prev => (prev + 1) % slides.length);
        setTextVisible(true);
      }, 350);
    }, 4000);
    return () => clearInterval(timer);
  }, [slides.length]);

  const goTo = (i: number) => {
    if (i === current) return;
    setTextVisible(false);
    setTimeout(() => { setCurrent(i); setTextVisible(true); }, 350);
  };

  const slide = slides[current];
  const textStyle = { opacity: textVisible ? 1 : 0, transition: "opacity 0.35s ease" };

  return (
    <div className="relative flex-1 h-full overflow-hidden">
      {/* Crossfade image layers */}
      {slides.map((s, i) => (
        <div
          key={s.src + i}
          className="absolute inset-0 transition-opacity duration-500"
          style={{ opacity: i === current && textVisible ? 1 : i === current ? 0.5 : 0 }}
        >
          <Image src={s.src} alt="Agriculture" fill className="object-cover" priority={i === 0} />
        </div>
      ))}

      {/* Persistent overlays */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-black/10 z-10" />
      <div className="absolute inset-0 z-10" style={{ background: `linear-gradient(135deg, ${accent}1a 0%, transparent 60%)` }} />

      {/* All content — layout always present, only values fade */}
      <div className="absolute inset-0 z-20 flex flex-col justify-between p-10">

        {/* Top row — badge + dots (always visible structure) */}
        <div className="flex items-center justify-between">
          {/* Badge — structure constant, text fades */}
          <div
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full backdrop-blur-md"
            style={{ background: "rgba(255,255,255,0.12)", border: "1px solid rgba(255,255,255,0.25)" }}
          >
            <span className="w-1.5 h-1.5 rounded-full animate-pulse" style={{ background: accent }} />
            <span className="text-[10px] font-bold tracking-[0.2em] uppercase text-white" style={textStyle}>
              {slide.badge}
            </span>
          </div>

          {/* Dot indicators */}
          <div className="flex gap-1.5">
            {slides.map((_, i) => (
              <button
                key={i}
                onClick={() => goTo(i)}
                className="rounded-full transition-all duration-300"
                style={{
                  width: i === current ? 20 : 6,
                  height: 6,
                  background: i === current ? "#ffffff" : "rgba(255,255,255,0.35)",
                }}
              />
            ))}
          </div>
        </div>

        {/* Bottom — title, desc, stat cards */}
        <div>
          {/* Title + desc (fade on slide change) */}
          <div style={textStyle}>
            <h2 className="text-[26px] font-extrabold text-white tracking-tight leading-tight mb-2">
              {slide.title}
            </h2>
            <p className="text-white/60 text-sm font-medium mb-5">{slide.desc}</p>
          </div>

          {/* Stat cards — always 3, always visible. Only inner text fades */}
          <div className="flex gap-3">
            {[0, 1, 2].map(idx => {
              const stat = slide.stats[idx];
              const Icon = stat?.icon;
              return (
                <div
                  key={idx}
                  className="flex-1 rounded-2xl p-3 backdrop-blur-md"
                  style={{ background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.14)" }}
                >
                  {/* Icon always same accent color, just changes type */}
                  <div className="w-4 h-4 mb-2">
                    {Icon && <Icon className="w-4 h-4" style={{ color: accent }} />}
                  </div>
                  <div className="text-sm font-extrabold text-white" style={textStyle}>
                    {stat?.value ?? "—"}
                  </div>
                  <div className="text-[9px] text-white/50 font-bold uppercase tracking-wider mt-0.5" style={textStyle}>
                    {stat?.label ?? ""}
                  </div>
                </div>
              );
            })}
          </div>

          {/* Copyright */}
          <p className="text-white/25 text-[10px] font-semibold mt-5 tracking-widest uppercase">
            © 2026 AgriSense. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
}


// ─── Login Form ───────────────────────────────────────────────────────────────
function LoginContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const role = searchParams.get("role") || "farmer";

  const [user, setUser] = useState({ 
    username: "", email: "", password: "", confirmPassword: "",
    phone_number: "", kyc_document_type: "Aadhar", kyc_number: "",
    base_pincode: "", service_radius_km: 10, total_fleet_size: 1,
    primary_equipment_type: "Tractors", upi_id: ""
  });
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);
  const [showConfirmPass, setShowConfirmPass] = useState(false);
  const [remember, setRemember] = useState(false);
  const [tab, setTab] = useState<"signin" | "signup">("signin");

  const isInspector = role === "inspector";
  const isLender = role === "lender";
  const accent = isInspector ? "#10b981" : isLender ? "#f59e0b" : "#16a34a";
  const accentHover = isInspector ? "#059669" : isLender ? "#d97706" : "#15803d";
  const dashboardPath = isInspector ? "/users/inspectionDashboard" : "/users/fleetDashboard";

  const onLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    if (tab === "signup") {
      try {
        const response = await fetch("/api/users/signup", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(user)
        });
        if (response.ok) {
          toast.success("Account Created! You can now login.");
          setTab("signin");
        } else {
          const data = await response.json();
          toast.error(data.error || data.message || "Signup failed");
        }
      } catch (error: any) {
        toast.error("An error occurred during signup.");
      } finally {
        setLoading(false);
      }
      return;
    }

    setTimeout(() => {
      toast.success(`Welcome! Entering ${isInspector ? "Inspection Hub" : isLender ? "Lender Portal" : "Fleet Ops"}…`);
      router.push(dashboardPath);
    }, 900);
  };

  return (
    <div
      className="min-h-screen flex items-center justify-center p-4 font-['Inter',sans-serif] relative overflow-hidden"
      style={{ backgroundImage: "url('/agri-bg.png')", backgroundSize: "cover", backgroundPosition: "center" }}
    >
      {/* Blurred background overlay */}
      <div className="absolute inset-0 backdrop-blur-sm" style={{ background: "rgba(255,255,255,0.20)" }} />

      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');
        .tab-pill { transition: background 0.25s, color 0.25s, box-shadow 0.25s; }
        .tab-pill.active {
          background: ${accent};
          color: #fff;
          box-shadow: 0 4px 16px ${accent}55;
        }
        .tab-pill:not(.active) { background: transparent; color: #94a3b8; }
        .field-input {
          width:100%; padding: 13px 40px 13px 14px;
          border: 1.5px solid #e2e8f0; border-radius: 14px;
          font-size:14px; font-weight:500; color:#0f172a;
          background:#f8fafc; outline:none;
          transition: border-color 0.2s, box-shadow 0.2s;
        }
        .field-input::placeholder { color: #94a3b8; }
        .field-input:focus {
          border-color: ${accent}99;
          box-shadow: 0 0 0 3px ${accent}18;
        }
        .login-btn {
          width:100%; padding:14px;
          border:none; border-radius:14px;
          background: ${accent}; color:#fff;
          font-size:15px; font-weight:700;
          cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px;
          transition: background 0.2s, transform 0.1s, box-shadow 0.2s;
          box-shadow: 0 6px 24px ${accent}44;
        }
        .login-btn:hover { background: ${accentHover}; box-shadow: 0 8px 28px ${accent}55; }
        .login-btn:active { transform: scale(0.98); }
        .social-btn {
          width:100%; padding:12px;
          border-radius:14px; border:1.5px solid #e2e8f0;
          background:#fff; font-size:13px; font-weight:600; cursor:pointer;
          display:flex; align-items:center; justify-content:center; gap:9px;
          transition: border-color 0.2s, box-shadow 0.2s;
          color: #0f172a;
        }
        .social-btn:hover { border-color:#cbd5e1; box-shadow:0 2px 12px rgba(0,0,0,0.07); }
        .social-btn.dark-btn { background:#0f172a; color:#fff; border-color:#0f172a; }
        .social-btn.dark-btn:hover { background:#1e293b; }
        .card-slide { animation: slideIn 0.45s cubic-bezier(0.22,1,0.36,1) both; }
        @keyframes slideIn { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .confirm-field {
          display: grid;
          transition: grid-template-rows 0.35s cubic-bezier(0.22,1,0.36,1), opacity 0.3s ease;
        }
        .confirm-field.open { grid-template-rows: 1fr; opacity: 1; }
        .confirm-field.closed { grid-template-rows: 0fr; opacity: 0; pointer-events: none; }
        .confirm-field > div { overflow: hidden; }
      `}</style>

      {/* Main Card — 40:60 */}
      <div className="w-full max-w-[1000px] h-[620px] rounded-[28px] overflow-hidden shadow-2xl flex card-slide relative z-10">

        {/* ── LEFT: Form (50%) ── */}
        <div className="w-1/2 flex-shrink-0 bg-white flex flex-col px-12 py-8 overflow-y-auto">
          {/* Logo */}
          <div className="flex items-center gap-2.5 mb-6">
            <div
              className="w-9 h-9 rounded-xl flex items-center justify-center"
              style={{ background: accent }}
            >
              {isInspector
                ? <UserCheck className="w-5 h-5 text-white" />
                : isLender
                ? <Key className="w-5 h-5 text-white" />
                : <Tractor className="w-5 h-5 text-white" />
              }
            </div>
            <span className="text-base font-extrabold text-slate-900 tracking-tight">AgriSense</span>
          </div>

          {/* Welcome */}
          <div className="mb-5">
            <h1 className="text-[22px] font-extrabold text-slate-900 tracking-tight">
              {isInspector ? "Welcome, Inspector!" : isLender ? "Welcome, Lender!" : "Welcome, Farmer!"}
            </h1>
            <p className="text-sm text-slate-500 font-medium mt-0.5">
              {isInspector ? "We're glad to have you back." : isLender ? "Manage your machines, earn more." : "Ready to manage your fleet?"}
            </p>
          </div>

          {/* Sign In / Sign Up Tabs */}
          <div className="flex rounded-2xl bg-slate-100 p-1 mb-5">
            {(["signin", "signup"] as const).map(t => (
              <button
                key={t}
                onClick={() => setTab(t)}
                className={`tab-pill flex-1 py-2.5 rounded-xl text-sm font-bold ${tab === t ? "active" : ""}`}
              >
                {t === "signin" ? "Sign In" : "Sign Up"}
              </button>
            ))}
          </div>

          {/* Form */}
          <form onSubmit={onLogin} className="flex flex-col gap-3">
            {/* Username — visible on Sign Up only */}
            <div className={`confirm-field ${tab === 'signup' ? 'open' : 'closed'}`}>
              <div>
                <div className="relative pt-0">
                  <input
                    type="text"
                    value={user.username}
                    onChange={e => setUser({ ...user, username: e.target.value })}
                    placeholder="Choose a username"
                    className="field-input pr-10"
                    tabIndex={tab === 'signup' ? 0 : -1}
                  />
                  <UserCheck className="absolute right-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
                </div>
              </div>
            </div>

            <div className="relative">
              <input
                type="email"
                value={user.email}
                onChange={e => setUser({ ...user, email: e.target.value })}
                placeholder="Enter your email"
                className="field-input pr-10"
              />
              <Mail className="absolute right-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
            </div>

            <div className="relative">
              <input
                type={showPass ? "text" : "password"}
                value={user.password}
                onChange={e => setUser({ ...user, password: e.target.value })}
                placeholder="Enter your password"
                className="field-input pr-10"
              />
              <button
                type="button"
                onClick={() => setShowPass(!showPass)}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
              >
                {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>

            {/* Confirm Password — visible on Sign Up only */}
            <div className={`confirm-field gap-3 ${tab === 'signup' ? 'open' : 'closed'}`}>
              <div>
                <div className="relative pt-0 mb-3">
                  <input
                    type={showConfirmPass ? "text" : "password"}
                    value={user.confirmPassword}
                    onChange={e => setUser({ ...user, confirmPassword: e.target.value })}
                    placeholder="Confirm your password"
                    className="field-input pr-10"
                    tabIndex={tab === 'signup' ? 0 : -1}
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPass(!showConfirmPass)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                    tabIndex={tab === 'signup' ? 0 : -1}
                  >
                    {showConfirmPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>

                {/* Additional Merchant Fields for Signup */}
                <div className="flex flex-col gap-3 pt-2 mt-1 border-t border-slate-100">
                  <div className="grid grid-cols-2 gap-3">
                    <input type="tel" value={user.phone_number} onChange={e => setUser({...user, phone_number: e.target.value})} placeholder="Phone Number" className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1} />
                    <input type="text" value={user.kyc_number} onChange={e => setUser({...user, kyc_number: e.target.value})} placeholder="KYC ID Number" className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1} />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <select value={user.kyc_document_type} onChange={e => setUser({...user, kyc_document_type: e.target.value})} className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1}>
                      <option value="Aadhar">Aadhar Card</option>
                      <option value="PAN">PAN Card</option>
                      <option value="DL">Driving License</option>
                    </select>
                    <input type="text" value={user.base_pincode} onChange={e => setUser({...user, base_pincode: e.target.value})} placeholder="Base Pincode" className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1} />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <input type="number" value={user.service_radius_km} onChange={e => setUser({...user, service_radius_km: parseInt(e.target.value) || 0})} placeholder="Service Radius (KM)" className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1} />
                    <input type="number" value={user.total_fleet_size} onChange={e => setUser({...user, total_fleet_size: parseInt(e.target.value) || 0})} placeholder="Fleet Size" className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1} />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <select value={user.primary_equipment_type} onChange={e => setUser({...user, primary_equipment_type: e.target.value})} className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1}>
                      <option value="Tractors">Tractors</option>
                      <option value="Harvesters">Harvesters</option>
                      <option value="Drone Sprayers">Drone Sprayers</option>
                      <option value="Implements">Implements</option>
                    </select>
                    <input type="text" value={user.upi_id} onChange={e => setUser({...user, upi_id: e.target.value})} placeholder="UPI ID for Payouts" className="field-input text-xs" tabIndex={tab === 'signup' ? 0 : -1} />
                  </div>
                </div>
              </div>
            </div>

            {/* Remember + Forgot */}
            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 cursor-pointer">
                <button
                  type="button"
                  onClick={() => setRemember(!remember)}
                  className="w-4 h-4 rounded-full border-2 flex items-center justify-center transition-all"
                  style={{ borderColor: remember ? accent : "#cbd5e1", background: remember ? accent : "transparent" }}
                >
                  {remember && <span className="w-1.5 h-1.5 rounded-full bg-white" />}
                </button>
                <span className="text-xs font-semibold text-slate-500">Remember me</span>
              </label>
              <Link href="#" className="text-xs font-bold hover:underline" style={{ color: accent }}>
                Forgot Password?
              </Link>
            </div>

            {/* Login / Signup button */}
            <button type="submit" disabled={loading} className="login-btn mt-1">
              {loading
                ? <><Loader2 className="w-4 h-4 animate-spin" /><span>{tab === 'signin' ? "Signing In…" : "Creating Account…"}</span></>
                : <span>{tab === 'signin' ? "Login" : "Sign Up & Join"}</span>
              }
            </button>

            {/* OR divider */}
            <div className="flex items-center gap-3">
              <div className="flex-1 h-px bg-slate-200" />
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">or</span>
              <div className="flex-1 h-px bg-slate-200" />
            </div>

            {/* Social */}
            <button type="button" className="social-btn dark-btn">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white flex-shrink-0"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98l-.09.06c-.22.14-2.18 1.27-2.16 3.8.03 3.02 2.65 4.03 2.68 4.04l-.07.28zM13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              Log in with Apple
            </button>
            <button type="button" className="social-btn">
              <svg viewBox="0 0 24 24" className="w-4 h-4 flex-shrink-0"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
              Log in with Google
            </button>
          </form>

          <p className="text-center text-[10px] text-slate-400 font-semibold mt-4">
            <Link href="/" className="hover:underline">← Back to role selection</Link>
          </p>
        </div>

        {/* ── RIGHT: Image Slider (60%) ── */}
        <RightPanel role={role} />
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-slate-100 flex items-center justify-center">
        <Loader2 className="w-10 h-10 text-emerald-500 animate-spin" />
      </div>
    }>
      <LoginContent />
    </Suspense>
  );
}