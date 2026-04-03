import { NextResponse } from 'next/server';
import pool from "@/lib/config/supabase";
 
// Scale to millions: Cache the nationwide heatmap for 60 seconds at the Edge
export const revalidate = 60;

export async function GET() {
    try {
        const client = await pool.connect();
        
        const res = await client.query(`
            SELECT 
                a.id,
                a.latitude AS lat,
                a.longitude AS lng,
                a.pathogen_name,
                a.is_positive,
                a.district,
                -- THE MAGIC: Inherit the overarching total diagnostic scans from the district to match the UI widgets
                (
                    SELECT COUNT(*)
                    FROM disease_scans b
                    WHERE b.district = a.district
                ) AS intensity_count
            FROM disease_scans a
            WHERE a.is_positive = TRUE AND a.latitude IS NOT NULL AND a.longitude IS NOT NULL;
        `);
        client.release();

        return NextResponse.json(res.rows);
    } catch (err: any) {
        console.error("❌ Scans fetch error:", err.message);
        return NextResponse.json({ status: "error", message: err.message }, { status: 500 });
    }
}
