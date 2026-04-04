import { NextResponse } from 'next/server';
import pool from '@/lib/config/supabase';

export async function GET() {
  const ownerId = '11111111-1111-1111-1111-111111111111';

  try {
    const query = `
      SELECT 
        rs.id as session_id,
        rs.renter_name,
        rs.start_time,
        rs.expected_end_time,
        ea.asset_tag,
        ea.category,
        ea.hourly_rate_usd
      FROM rental_sessions rs
      JOIN equipment_assets ea ON rs.asset_id = ea.id
      WHERE ea.owner_id = $1 AND rs.session_status = 'Active'
      ORDER BY rs.expected_end_time ASC;
    `;
    
    const result = await pool.query(query, [ownerId]);
    return NextResponse.json(result.rows);
    
  } catch (error) {
    console.error('Live Sessions API Error:', error);
    return NextResponse.json({ error: 'Failed to fetch live sessions' }, { status: 500 });
  }
}
