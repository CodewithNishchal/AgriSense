const { Pool } = require('pg');

const pool = new Pool({
    connectionString: "postgresql://postgres.ebjljcwbwzcquhacdavz:LYwbzAV7rU6iZyTG@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres",
});

async function main() {
    const client = await pool.connect();
    const res = await client.query("SELECT district, pathogen_name, COUNT(*) FROM disease_scans WHERE district = 'Nagpur' GROUP BY district, pathogen_name;");
    console.log("Scans in Nagpur:");
    console.table(res.rows);
    client.release();
    pool.end();
}
main();
