import pool, { testConnection } from "../../lib/config/supabase";

/**
 * Next.js Server Component (Frontend UI running on Backend Server)
 */
export default async function TestDatabasePage() {
    // Check initial connection
    const isConnected = await testConnection();

    // Fetch Table Names from public schema
    let tables: string[] = [];
    if (isConnected) {
        try {
            const result = await pool.query(`
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name ASC
            `);
            tables = result.rows.map((row: any) => row.table_name);
        } catch (error) {
            console.error("Error fetching tables:", error);
        }
    }

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-black p-12 font-sans">
            <div className="max-w-3xl mx-auto">
                <h1 className="text-3xl font-bold mb-8 text-black dark:text-white">
                    Database Schema Explorer
                </h1>

                {/* Connection Status Card */}
                <div className={`p-6 rounded-2xl border mb-10 ${isConnected
                        ? "bg-green-50 border-green-200 text-green-800"
                        : "bg-red-50 border-red-200 text-red-800"
                    }`}>
                    <div className="flex items-center gap-4">
                        <span className="text-2xl">
                            {isConnected ? "✅" : "❌"}
                        </span>
                        <div>
                            <p className="font-bold text-lg">
                                {isConnected ? "Connection Successful" : "Connection Failed"}
                            </p>
                            <p className="mt-1 opacity-80 text-sm">
                                {isConnected
                                    ? `Total Public Tables: ${tables.length}`
                                    : "Check your DATABASE_URL in the .env file."
                                }
                            </p>
                        </div>
                    </div>
                </div>

                {/* Table List Section */}
                {isConnected && (
                    <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl overflow-hidden shadow-sm">
                        <div className="px-6 py-4 border-b border-zinc-100 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-800/50">
                            <h2 className="text-xs font-black uppercase tracking-widest text-zinc-400">
                                Tables Found in 'public'
                            </h2>
                        </div>

                        <div className="divide-y divide-zinc-100 dark:divide-zinc-800">
                            {tables.length > 0 ? (
                                tables.map((name, i) => (
                                    <div key={i} className="px-6 py-4 hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-colors flex items-center justify-between group">
                                        <div className="flex items-center gap-3">
                                            <div className="w-8 h-8 rounded-lg bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center text-zinc-400 font-mono text-xs">
                                                {i + 1}
                                            </div>
                                            <span className="font-bold text-zinc-700 dark:text-zinc-200">{name}</span>
                                        </div>
                                        <span className="text-[10px] font-black uppercase text-zinc-300 dark:text-zinc-600 opacity-0 group-hover:opacity-100 transition-opacity">
                                            Ready to Query
                                        </span>
                                    </div>
                                ))
                            ) : (
                                <div className="px-6 py-12 text-center text-zinc-400 italic">
                                    No tables found in the public schema.
                                    <br />
                                    <span className="text-[10px] mt-2 block not-italic">Go to Supabase Dashboard to create your first table.</span>
                                </div>
                            )}
                        </div>
                    </div>
                )}

                <div className="mt-10 pt-6 border-t border-zinc-200 dark:border-zinc-800 flex justify-between items-center text-[10px] font-bold text-zinc-400 uppercase tracking-widest">
                    <span>Generated: {new Date().toLocaleTimeString()}</span>
                    <span>Backend Context: pg-pool (v8.11)</span>
                </div>
            </div>
        </div>
    );
}
