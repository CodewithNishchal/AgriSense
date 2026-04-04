const { Pool } = require('pg');

const pool = new Pool({
    connectionString: "postgresql://postgres.ebjljcwbwzcquhacdavz:LYwbzAV7rU6iZyTG@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres",
});

async function main() {
    const client = await pool.connect();
    const res = await client.query("SELECT district, pathogen_name, COUNT(*) FROM disease_scans WHERE district = 'Nagpur' GROUP BY district, pathogen_name;");
    console.log("Scans in Nagpur:", JSON.stringify(res.rows, null, 2));
    
    // Also let's see if there is any other place doing Wheat Brown Rust
    const res2 = await client.query("SELECT district, pathogen_name, COUNT(*) FROM disease_scans WHERE pathogen_name LIKE '%h%' GROUP BY district, pathogen_name;");
    console.log("Other:", JSON.stringify(res2.rows, null, 2));
    client.release();
    pool.end();
}
main();
