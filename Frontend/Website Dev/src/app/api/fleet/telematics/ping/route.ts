import { NextResponse } from 'next/server';
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// 1. The In-Memory Buffer (Survives between serverless requests)
// We declare it globally so Next.js doesn't overwrite it on every ping
declare global {
  var telematicsQueue: any[];
}
if (!(global as any).telematicsQueue) {
  (global as any).telematicsQueue = [];
}

// 2. The Configuration Thresholds
const BATCH_SIZE_LIMIT = 50; // Flush to DB when we hit 50 pings

export async function POST(request: Request) {
  try {
    const ping = await request.json(); 
    // Example ping: { assetId: 'uuid', lat: 20.85, lng: 78.98, battery: 65 }

    // 3. Push the incoming GPS ping to RAM (Extremely fast, no DB delay)
    (global as any).telematicsQueue.push(ping);

    // 4. Check if the buffer is full and ready to flush
    if ((global as any).telematicsQueue.length >= BATCH_SIZE_LIMIT) {
      
      // Clone the queue and immediately clear it so new pings aren't blocked
      const batchToProcess = [...(global as any).telematicsQueue];
      (global as any).telematicsQueue = []; 

      // 5. The "Unnest" Trick: The most efficient way to bulk-update PostgreSQL
      // We convert our array of objects into arrays of columns
      const assetIds = batchToProcess.map(p => p.assetId);
      const lats = batchToProcess.map(p => p.lat);
      const lngs = batchToProcess.map(p => p.lng);
      const batteries = batchToProcess.map(p => p.battery);

      const client = await pool.connect();
      
      // We use PostgreSQL UNNEST to update 50+ rows in a single query
      await client.query(`
        UPDATE equipment_assets AS ea
        SET 
            latitude = u.lat,
            longitude = u.lng,
            fuel_battery_level = u.battery,
            last_pinged_at = NOW()
        FROM UNNEST($1::uuid[], $2::float8[], $3::float8[], $4::int[]) 
          AS u(id, lat, lng, battery)
        WHERE ea.id = u.id;
      `, [assetIds, lats, lngs, batteries]);

      client.release();
      console.log(`Successfully batch-updated ${batchToProcess.length} telematics records.`);
    }

    // Always return a 200 OK instantly so the IoT device (tractor) doesn't hang
    return NextResponse.json({ status: 'Ping received & buffered' });

  } catch (error) {
    console.error('Telematics Ping Error:', error);
    return NextResponse.json({ error: 'Failed to process ping' }, { status: 500 });
  }
}
