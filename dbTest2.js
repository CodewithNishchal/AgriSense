const { Pool } = require('pg');

const pool = new Pool({
    connectionString: "postgresql://postgres.ebjljcwbwzcquhacdavz:LYwbzAV7rU6iZyTG@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres",
});

async function main() {
    const client = await pool.connect();
    const res = await client.query("SELECT DISTINCT pathogen_name FROM disease_scans WHERE pathogen_name ILIKE '%wheat%' OR pathogen_name ILIKE '%brown%' OR pathogen_name ILIKE '%rust%';");
    console.log("Pathogens matching wheat/brown/rust:", res.rows);
    client.release();
    pool.end();
}
main();
