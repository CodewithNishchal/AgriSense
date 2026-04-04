const { Pool } = require('pg');
const pool = new Pool({
    connectionString: "postgresql://postgres.ebjljcwbwzcquhacdavz:LYwbzAV7rU6iZyTG@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres",
});

const ownerId = '11111111-1111-1111-1111-111111111111';

async function seed() {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        console.log('Ensuring tables exist...');
        // Drop constraints or tables if they cause issues (for hackathon clean slate)
        // For now just ensure they exist.
        await client.query(`
            CREATE TABLE IF NOT EXISTS equipment_assets (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                owner_id UUID,
                asset_tag TEXT UNIQUE,
                category TEXT,
                current_status TEXT,
                hourly_rate_usd DECIMAL,
                fuel_battery_level INTEGER,
                latitude DOUBLE PRECISION,
                longitude DOUBLE PRECISION,
                last_pinged_at TIMESTAMP DEFAULT NOW()
            )`);

        await client.query(`
            CREATE TABLE IF NOT EXISTS rental_sessions (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                asset_id UUID REFERENCES equipment_assets(id),
                renter_name TEXT,
                start_time TIMESTAMP,
                expected_end_time TIMESTAMP,
                session_status TEXT,
                total_revenue_generated DECIMAL DEFAULT 0
            )`);

        await client.query(`
            CREATE TABLE IF NOT EXISTS telematics_alerts (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                asset_id UUID REFERENCES equipment_assets(id),
                alert_type TEXT,
                severity TEXT,
                message TEXT,
                is_resolved BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT NOW()
            )`);

        await client.query(`
            CREATE TABLE IF NOT EXISTS fleet_tasks (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                owner_id UUID,
                title TEXT,
                subtitle TEXT,
                task_state TEXT,
                created_at TIMESTAMP DEFAULT NOW()
            )`);

        // Clear existing data
        await client.query('DELETE FROM fleet_tasks');
        await client.query('DELETE FROM telematics_alerts');
        await client.query('DELETE FROM rental_sessions');
        await client.query('DELETE FROM equipment_assets');

        console.log('Seeding equipment_assets...');
        const assets = [
            ['TRC-08', 'Heavy Duty', 'Available', 80.00, 72, 43.3194, 11.3705],
            ['TRC-02', 'Heavy Duty', 'Rented', 65.00, 45, 43.3262, 11.3610],
            ['BKH-04', 'Harvester', 'Rented', 120.00, 68, 43.3122, 11.3810],
            ['TRC-A9', 'Compact', 'Rented', 40.00, 89, 43.3268, 11.3820],
            ['TRC-C2', 'Compact', 'Available', 35.00, 95, 43.3262, 11.3610],
            ['BKH-08', 'Harvester', 'Maintenance', 110.00, 12, 43.3150, 11.3750],
            ['TRC-05', 'Standard', 'Available', 50.00, 80, 43.3210, 11.3650],
            ['TRC-12', 'Standard', 'Available', 45.00, 60, 43.3230, 11.3680]
        ];

        const assetIds = [];
        for (const a of assets) {
            const res = await client.query(
                'INSERT INTO equipment_assets (owner_id, asset_tag, category, current_status, hourly_rate_usd, fuel_battery_level, latitude, longitude, last_pinged_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW()) RETURNING id',
                [ownerId, a[0], a[1], a[2], a[3], a[4], a[5], a[6]]
            );
            assetIds.push({ tag: a[0], id: res.rows[0].id });
        }

        console.log('Seeding rental_sessions...');
        const renters = ['Ramesh K.', 'Luca M.', 'Sofia R.', 'Giulia F.'];
        const activeAssets = assetIds.filter(a => ['TRC-02', 'BKH-04', 'TRC-A9'].includes(a.tag));
        
        for (let i = 0; i < activeAssets.length; i++) {
            const startTime = new Date(Date.now() - 3600000 * 1.5);
            const expectedEnd = new Date(startTime.getTime() + 3600000 * 4);
            await client.query(
                'INSERT INTO rental_sessions (asset_id, renter_name, start_time, expected_end_time, session_status, total_revenue_generated) VALUES ($1, $2, $3, $4, $5, $6)',
                [activeAssets[i].id, renters[i], startTime, expectedEnd, 'Active', 0]
            );
        }

        console.log('Seeding telematics_alerts...');
        const bkh04 = assetIds.find(a => a.tag === 'BKH-04');
        const trc02 = assetIds.find(a => a.tag === 'TRC-02');

        await client.query(
            'INSERT INTO telematics_alerts (asset_id, alert_type, severity, message, is_resolved) VALUES ($1, $2, $3, $4, $5)',
            [bkh04.id, 'Engine Temperature', 'Critical', 'Harvester BKH-04: High Temp Alert', false]
        );
        await client.query(
            'INSERT INTO telematics_alerts (asset_id, alert_type, severity, message, is_resolved) VALUES ($1, $2, $3, $4, $5)',
            [trc02.id, 'Geofence Breach', 'Warning', 'Boundary Alert: TRC-02 left operating zone', false]
        );

        console.log('Seeding fleet_tasks...');
        const tasks = [
            ['TRC-08 Routine Check', 'Inspection due tomorrow', 'Pending'],
            ['BKH-08 Refuel Request', 'South Field - Depot B', 'In-Progress'],
            ['New Lease Agreement', 'Tractor #A9 extension', 'Review']
        ];
        for (const t of tasks) {
            await client.query(
                'INSERT INTO fleet_tasks (owner_id, title, subtitle, task_state) VALUES ($1, $2, $3, $4)',
                [ownerId, t[0], t[1], t[2]]
            );
        }

        await client.query('COMMIT');
        console.log('Successfully seeded database with ownerId ' + ownerId);
    } catch (e) {
        await client.query('ROLLBACK');
        console.error('Seeding error:', e);
    } finally {
        client.release();
        pool.end();
    }
}
seed();
