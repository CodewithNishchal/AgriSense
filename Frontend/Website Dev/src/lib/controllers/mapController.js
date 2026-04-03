import pool from "../config/supabase";

export const getMapMarkers = async () => {
    try {
        const client = await pool.connect();
        
        // Fetch all disease scans from the public schema
        // Fetch aggregated disease scans grouped by approximate geographic coordinate (creates natural spatial clusters)
        const res = await client.query(`
            SELECT 
                a.id,
                a.latitude AS lat,
                a.longitude AS lng,
                a.pathogen_name,
                a.is_positive,
                a.district,
                -- Inherit the exact Total Diagnostic Scans metric calculated in the regional panel
                (
                    SELECT COUNT(*)
                    FROM disease_scans b
                    WHERE b.district = a.district
                ) AS intensity_count
            FROM disease_scans a
            WHERE a.is_positive = TRUE AND a.latitude IS NOT NULL AND a.longitude IS NOT NULL;
        `);
        client.release();

        // Format the data to match what the frontend expects
        const formattedData = res.rows.map(row => ({
            id: row.id,
            district: row.district || "Unknown District",
            lat: Number(row.lat),
            lng: Number(row.lng),
            intensity_count: Number(row.intensity_count),
            disease: row.pathogen_name || "Unknown",
        }));

        return { status: "success", data: formattedData };
    } catch (err) {
        console.error("❌ Map markers fetch error:", err.message);
        return { status: "error", message: err.message };
    }
};
