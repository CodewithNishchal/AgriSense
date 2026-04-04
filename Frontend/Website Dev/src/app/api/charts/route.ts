import { NextResponse } from 'next/server';
import pool from '@/lib/config/supabase';
 
// Optimization: Cache time-series data for 60 seconds
export const revalidate = 60;

export async function GET(request: Request) {
    const { searchParams } = new URL(request.url);
    const district = searchParams.get('district') || 'Nagpur';

    try {
        const query = `
            SELECT 
                TO_CHAR(record_date, 'Mon DD') as date_label,
                positive_cases,
                avg_humidity,
                economic_risk_inr,
                is_forecast
            FROM regional_daily_metrics
            WHERE district = $1
            ORDER BY record_date ASC;
        `;
        
        const result = await pool.query(query, [district]);
        return NextResponse.json(result.rows);
    } catch (error) {
        console.error("❌ Chart fetch error:", error);
        return NextResponse.json({ error: 'Failed to fetch chart data' }, { status: 500 });
    }
}
