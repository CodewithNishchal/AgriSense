const { Pool } = require('pg');
const pool = new Pool({
    connectionString: "postgresql://postgres.ebjljcwbwzcquhacdavz:LYwbzAV7rU6iZyTG@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres",
});

async function main() {
    const client = await pool.connect();
    
    // Get all public tables
    const tables = await client.query(`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;`);
    const tableNames = tables.rows.map(r => r.table_name);
    process.stdout.write('TABLES: ' + tableNames.join(', ') + '\n');
    
    // Get columns for equipment_assets
    const eq = await client.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'equipment_assets' ORDER BY ordinal_position;`);
    process.stdout.write('\nEQUIPMENT_ASSETS COLS: ' + eq.rows.map(r => r.column_name + ':' + r.data_type).join(', ') + '\n');
    
    const eqSample = await client.query('SELECT * FROM equipment_assets LIMIT 3;');
    process.stdout.write('\nEQ SAMPLE: ' + JSON.stringify(eqSample.rows) + '\n');
    
    // Check other fleet tables
    const otherFleet = tableNames.filter(t => !['disease_scans', 'regional_daily_metrics', 'equipment_assets'].includes(t));
    process.stdout.write('\nOTHER TABLES: ' + otherFleet.join(', ') + '\n');
    
    for (const tbl of otherFleet) {
        const cols = await client.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = $1 ORDER BY ordinal_position;`, [tbl]);
        process.stdout.write('\n' + tbl + ' COLS: ' + cols.rows.map(r => r.column_name + ':' + r.data_type).join(', ') + '\n');
        const sample = await client.query('SELECT * FROM ' + tbl + ' LIMIT 2;');
        process.stdout.write(tbl + ' SAMPLE: ' + JSON.stringify(sample.rows) + '\n');
    }
    
    client.release();
    pool.end();
    process.exit(0);
}
main().catch(e => { process.stdout.write('ERROR: ' + e.message + '\n'); process.exit(1); });
