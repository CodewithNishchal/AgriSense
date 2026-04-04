"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

interface FleetNavTabsProps {
  activeTab?: 'available' | 'active';
  onTabChange?: (tab: 'available' | 'active') => void;
}

export default function FleetNavTabs({ activeTab, onTabChange }: FleetNavTabsProps) {
  const pathname = usePathname();
  const isAvailable = activeTab ? activeTab === 'available' : pathname.includes("availableAssets");

  const handleTabClick = (tab: 'available' | 'active', e: React.MouseEvent) => {
    if (onTabChange) {
      e.preventDefault();
      onTabChange(tab);
    }
  };

  return (
    <div className="flex items-center gap-4 bg-white dark:bg-[#1e293b] p-2 rounded-full shadow-sm border border-gray-100 dark:border-gray-800 transition-colors">
      <div className="flex-1 flex bg-gray-100 dark:bg-[#0f172a] rounded-full p-1 h-12 relative overflow-hidden">
        {/* Sliding pill */}
        <div
          className={`absolute top-1 h-[calc(100%-8px)] w-[calc(50%-4px)] bg-[#528956] rounded-full shadow-md transition-all duration-300 ease-out ${
            isAvailable ? "left-1" : "left-[calc(50%+2px)]"
          }`}
        />
        <Link
          href="/users/fleetDashboard"
          onClick={(e) => handleTabClick('available', e)}
          className={`relative z-10 w-1/2 flex items-center justify-between px-4 text-sm font-semibold transition-colors cursor-pointer ${
            isAvailable ? "text-white" : "text-gray-500 dark:text-gray-400"
          }`}
        >
          <span>Available Assets</span>
          <span className={`text-xs font-bold px-1.5 py-0.5 rounded-full ${isAvailable ? "bg-white/20 text-white" : "bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400"}`}>14</span>
        </Link>
        <Link
          href="/users/fleetDashboard"
          onClick={(e) => handleTabClick('active', e)}
          className={`relative z-10 w-1/2 flex items-center justify-between px-4 text-sm font-semibold transition-colors cursor-pointer ${
            !isAvailable ? "text-white" : "text-gray-500 dark:text-gray-400"
          }`}
        >
          <span>Active Rentals</span>
          <span className={`text-xs font-bold px-1.5 py-0.5 rounded-full ${!isAvailable ? "bg-white/20 text-white" : "bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400"}`}>8</span>
        </Link>
      </div>
      <Link href="/users/fleetDashboard/newBooking">
        <button className="bg-[#1a211b] dark:bg-green-700 text-white px-6 py-3 rounded-full text-sm font-medium flex items-center gap-2 hover:bg-black dark:hover:bg-green-600 transition-all active:scale-95 whitespace-nowrap group cursor-pointer">
          <svg className="w-4 h-4 transition-transform group-hover:rotate-90" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
          </svg>
          New Booking
        </button>
      </Link>
    </div>
  );
}
