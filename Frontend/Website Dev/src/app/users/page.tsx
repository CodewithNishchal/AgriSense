import React from 'react';

export default function UsersPage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-br from-indigo-900 via-slate-900 to-black text-white px-4">
      <div className="max-w-4xl w-full text-center space-y-8 animate-in fade-in slide-in-from-bottom-8 duration-1000">
        <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight">
          <span className="bg-clip-text text-transparent bg-gradient-to-r from-cyan-400 to-blue-500">
            Users
          </span> Page
        </h1>
        <p className="text-slate-400 text-lg md:text-xl max-w-2xl mx-auto">
          Manage your users and view system-wide activity in one beautifully crafted interface.
        </p>
        <div className="flex justify-center gap-4">
          <a
            href="/users/Dashboard"
            className="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-full shadow-lg shadow-blue-500/30 transition-all hover:scale-105 active:scale-95"
          >
            Go to Dashboard
          </a>
        </div>
      </div>
    </div>
  );
}
