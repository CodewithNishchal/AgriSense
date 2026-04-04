import { NextResponse } from 'next/server';
import pool from '@/lib/config/supabase';
 
// Scale to millions: Cache fleet overview for 60s at the Edge
export const revalidate = 60;

export async function GET() {
  // In a real app, this comes from the JWT token. 
  // For now, we hardcode the specific user we just created.
  const ownerId = '11111111-1111-1111-1111-111111111111';

  try {
    // Run all aggregations in parallel for maximum speed using the pool directly
    const [statusCounts, categoryCounts, revenueData, tasksData] = await Promise.all([
      // 1. Get counts for the "Fleet Utilization" donut and top header
      pool.query(`
        SELECT current_status, COUNT(*) as count 
        FROM equipment_assets 
        WHERE owner_id = $1 
        GROUP BY current_status
      `, [ownerId]),

      // 2. Get counts for the "Asset Categories" progress bars
      pool.query(`
        SELECT category, COUNT(*) as total,
        SUM(CASE WHEN current_status = 'Rented' THEN 1 ELSE 0 END) as rented_count
        FROM equipment_assets 
        WHERE owner_id = $1 
        GROUP BY category
      `, [ownerId]),

      // 3. Get the "Active Earning Rate" (Sum of hourly rates for currently rented gear)
      pool.query(`
        SELECT SUM(hourly_rate_usd) as active_earning_rate
        FROM equipment_assets
        WHERE owner_id = $1 AND current_status = 'Rented'
      `, [ownerId]),

      // 4. Get the Logistics Tasks (Bottom left cards)
      pool.query(`
        SELECT task_state, title, subtitle 
        FROM fleet_tasks 
        WHERE owner_id = $1 
        ORDER BY created_at DESC LIMIT 3
      `, [ownerId])
    ]);

    // Format the response to be incredibly easy for React to digest
    return NextResponse.json({
      utilization: statusCounts.rows,
      categories: categoryCounts.rows,
      activeEarningRate: revenueData.rows[0].active_earning_rate || 0,
      tasks: tasksData.rows
    });

  } catch (error) {
    console.error('Overview API Error:', error);
    return NextResponse.json({ error: 'Failed to fetch overview data' }, { status: 500 });
  }
}
