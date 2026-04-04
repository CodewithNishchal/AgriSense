'use client'

import Link from "next/link";
import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import axios from "axios";
import { toast } from "react-hot-toast";

export default function SignupPage() {
    const router = useRouter()
    const [user, setUser] = useState({
        username: "",
        email: "",
        password: "",
        phone_number: "",
        kyc_document_type: "Aadhar",
        kyc_number: "",
        base_pincode: "",
        service_radius_km: 10,
        total_fleet_size: 1,
        primary_equipment_type: "Tractors",
        upi_id: "",
    })

    const [buttonDisabled, setButtonDisabled] = useState(true);
    const [loading, setLoading] = useState(false);

    const onSignup = async () => {
        try {
            setLoading(true);
            const response = await axios.post("/api/users/signup", user);
            toast.success("Merchant Account Created Successfully! 🚀");
            router.push("/login")
        } catch (error: any) {
            console.log("Signup failed", error.message);
            toast.error(error.response?.data?.error || "Signup failed");
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => {
        if (
            user.email.length > 0 && 
            user.password.length > 0 &&
            user.username.length > 0 &&
            user.phone_number.length > 0 &&
            user.kyc_number.length > 0 &&
            user.base_pincode.length > 0 &&
            user.upi_id.length > 0
        ) {
            setButtonDisabled(false);
        } else {
            setButtonDisabled(true);
        }
    }, [user]);

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
        const { id, value } = e.target;
        setUser({ ...user, [id]: value });
    };

    return (
        <div className="flex items-center justify-center min-h-screen bg-[#0f172a] text-gray-200 font-['Inter',sans-serif] py-12 px-4">
            <div className="bg-[#1e293b] p-8 rounded-3xl shadow-xl border border-gray-700 w-full max-w-2xl">
                <h1 className="text-3xl font-black text-center mb-2 text-white">Merchant Fleet Registration</h1>
                <p className="text-center text-sm font-medium text-gray-400 mb-8 border-b border-gray-700 pb-6">
                    Join the P2P AgriSense Network. Provide your details to start renting your assets.
                </p>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {/* Basic Info */}
                    <div className="col-span-1 md:col-span-2">
                        <h2 className="text-sm font-bold text-green-500 uppercase tracking-widest mb-3">1. Primary Detail</h2>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="username">Username</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="username" type="text" value={user.username} onChange={handleInputChange} placeholder="FleetOwner_99" />
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="email">Email</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="email" type="email" value={user.email} onChange={handleInputChange} placeholder="you@domain.com" />
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="password">Password</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="password" type="password" value={user.password} onChange={handleInputChange} placeholder="••••••••" />
                            </div>
                        </div>
                    </div>

                    {/* Trust & Verification */}
                    <div className="col-span-1 md:col-span-2 mt-2">
                        <h2 className="text-sm font-bold text-green-500 uppercase tracking-widest mb-3">2. Trust & Verification</h2>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="phone_number">WhatsApp / Phone</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="phone_number" type="tel" value={user.phone_number} onChange={handleInputChange} placeholder="+91 9876543210" />
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="kyc_document_type">KYC ID Type</label>
                                <select className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="kyc_document_type" value={user.kyc_document_type} onChange={handleInputChange}>
                                    <option value="Aadhar">Aadhar Card</option>
                                    <option value="PAN">PAN Card</option>
                                    <option value="DL">Driving License</option>
                                </select>
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="kyc_number">KYC Number</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="kyc_number" type="text" value={user.kyc_number} onChange={handleInputChange} placeholder="XXXX-XXXX-XXXX" />
                            </div>
                        </div>
                    </div>

                    {/* Spatial / DNA */}
                    <div className="col-span-1 md:col-span-2 mt-2">
                        <h2 className="text-sm font-bold text-green-500 uppercase tracking-widest mb-3">3. Fleet Logistics</h2>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="base_pincode">Base Village / Pincode</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="base_pincode" type="text" value={user.base_pincode} onChange={handleInputChange} placeholder="440001" />
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="service_radius_km">Service Radius (in KM)</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="service_radius_km" type="number" min="1" max="100" value={user.service_radius_km} onChange={handleInputChange} />
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="total_fleet_size">Initial Fleet Size</label>
                                <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="total_fleet_size" type="number" min="1" value={user.total_fleet_size} onChange={handleInputChange} />
                            </div>
                            <div className="flex flex-col">
                                <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="primary_equipment_type">Primary Equipment</label>
                                <select className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-green-500 text-white transition-colors" id="primary_equipment_type" value={user.primary_equipment_type} onChange={handleInputChange}>
                                    <option value="Tractors">Tractors</option>
                                    <option value="Harvesters">Harvesters</option>
                                    <option value="Drone Sprayers">Drone Sprayers</option>
                                    <option value="Implements">Implements</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Financials */}
                    <div className="col-span-1 md:col-span-2 mt-2 border-t border-gray-700 pt-6">
                        <h2 className="text-sm font-bold text-blue-500 uppercase tracking-widest mb-3 flex items-center gap-2">
                            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg> 
                            4. Payout Information
                        </h2>
                        <div className="flex flex-col">
                            <label className="text-xs font-bold text-gray-400 mb-1" htmlFor="upi_id">Preferred UPI ID</label>
                            <input className="p-2.5 bg-gray-800 border border-gray-600 rounded-xl focus:outline-none focus:border-blue-500 text-white transition-colors" id="upi_id" type="text" value={user.upi_id} onChange={handleInputChange} placeholder="merchant@okbank" />
                            <p className="text-[10px] text-gray-500 mt-1">Earnings will be settled to this UPI address after each completed rental.</p>
                        </div>
                    </div>
                </div>

                <div className="mt-8 flex flex-col items-center">
                    <button
                        onClick={onSignup}
                        disabled={buttonDisabled || loading}
                        className={`w-full p-3 rounded-xl font-black uppercase tracking-wider transition-all duration-300 shadow-xl ${
                            buttonDisabled ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-green-600 text-white hover:bg-green-500 hover:-translate-y-1 hover:shadow-green-500/20 active:scale-95'
                        }`}
                    >
                        {loading ? "Activating Node..." : "Onboard to Fleet Network" }
                    </button>
                    <Link href="/login" className="mt-6 text-sm font-bold text-green-500 hover:text-green-400 hover:underline transition-colors">
                        Already have an active node? Secure Login
                    </Link>
                </div>
            </div>
        </div>
    )
}