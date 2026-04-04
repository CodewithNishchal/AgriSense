import { NextResponse } from 'next/server';
import pool from '@/lib/config/supabase';

export async function GET() {
  const ownerId = '11111111-1111-1111-1111-111111111111';

  try {
    // Run all aggregations in parallel using the pool directly for stability
    const [assetsData, alertsData] = await Promise.all([
      // 1. Get all asset locations, battery levels, and status for the Map
      pool.query(`
        SELECT 
          id, asset_tag, current_status, 
          fuel_battery_level, latitude, longitude 
        FROM equipment_assets
        WHERE owner_id = $1
      `, [ownerId]),

      // 2. Get active, unresolved alerts (JOIN to get the asset tag)
      pool.query(`
        SELECT 
          ta.id, ta.alert_type, ta.severity, ta.message,
          ea.asset_tag, ea.latitude, ea.longitude
        FROM telematics_alerts ta
        JOIN equipment_assets ea ON ta.asset_id = ea.id
        WHERE ea.owner_id = $1 AND ta.is_resolved = FALSE
        ORDER BY ta.created_at DESC
      `, [ownerId])
    ]);

    return NextResponse.json({
      fleetLocations: assetsData.rows,
      activeAlerts: alertsData.rows,
      // Calculate the massive 65% donut chart on the backend
      averageBattery: Math.round(
        assetsData.rows.reduce((sum, asset) => sum + asset.fuel_battery_level, 0) / 
        (assetsData.rows.length || 1)
      )
    });

  } catch (error) {
    console.error('Telematics API Error:', error);
    return NextResponse.json({ error: 'Failed to fetch telematics' }, { status: 500 });
  }
}
