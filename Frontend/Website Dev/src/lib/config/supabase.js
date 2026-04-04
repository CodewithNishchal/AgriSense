import { Pool } from 'pg';

/**
 * Direct Postgres Connection Pool
 * This uses your DATABASE_URL for raw SQL queries.
 */
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// For testing the connection
export const testConnection = async () => {
    try {
        const client = await pool.connect();
        const res = await client.query('SELECT NOW()');
        client.release();
        console.log("✅ Successfully connected to Postgres:", res.rows[0].now);
        return true;
    } catch (err) {
        console.error("❌ Postgres connection error:", err.message);
        return false;
    }
};

export default pool;
