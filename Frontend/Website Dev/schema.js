const { Pool } = require('pg');
const fs = require('fs');
const pool = new Pool({
    connectionString: "postgresql://postgres.ebjljcwbwzcquhacdavz:LYwbzAV7rU6iZyTG@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres",
});

async function run() {
    let output = '';
    const client = await pool.connect();
    const tables = ['equipment_assets', 'rental_sessions', 'telematics_alerts'];
    for (const table of tables) {
        output += `--- ${table} ---\n`;
        const res = await client.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = $1`, [table]);
        res.rows.forEach(c => output += `${c.column_name} (${c.data_type})\n`);
        const sample = await client.query(`SELECT * FROM ${table} LIMIT 1`);
        output += 'Sample: ' + JSON.stringify(sample.rows[0], null, 2) + '\n\n';
    }
    client.release();
    pool.end();
    fs.writeFileSync('schema_utf8.txt', output, 'utf8');
}
run();
