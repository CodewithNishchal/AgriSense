import pool from "../config/supabase";

export const getNationalMetrics = async () => {
    try {
        // 1. National Threat Overview (Volume & Positivity)
        const metric1 = pool.query(`
            SELECT 
                COUNT(*) AS total_scans_all_time,
                SUM(CASE WHEN is_positive = TRUE THEN 1 ELSE 0 END) AS total_positive_cases,
                ROUND((SUM(CASE WHEN is_positive = TRUE THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(*), 0)) * 100, 2) AS national_positivity_rate_pct,
                SUM(CASE WHEN scanned_at >= NOW() - INTERVAL '7 days' THEN 1 ELSE 0 END) AS scans_last_7_days,
                MODE() WITHIN GROUP (ORDER BY pathogen_name) FILTER (WHERE is_positive = TRUE AND pathogen_name IS NOT NULL AND pathogen_name != '') AS dominant_pathogen
            FROM 
                disease_scans;
        `);

        // 2. Fastest Regional Hotspot (Ranked by TOTAL activity volume)
        const metric2 = pool.query(`
            SELECT 
                district as primary_district,
                COUNT(*) as cases_in_cluster,
                MODE() WITHIN GROUP (ORDER BY pathogen_name) FILTER (WHERE is_positive = TRUE AND pathogen_name IS NOT NULL AND pathogen_name != '') as primary_pathogen
            FROM 
                disease_scans
            WHERE 
                district IS NOT NULL
            GROUP BY 
                district
            ORDER BY 
                cases_in_cluster DESC
            LIMIT 1;
        `);

        // 3. Pathogen Velocity (Week-over-Week Growth Rate)
        const metric3 = pool.query(`
            WITH WeeklyStats AS (
                SELECT 
                    SUM(CASE WHEN scanned_at >= NOW() - INTERVAL '7 days' THEN 1 ELSE 0 END) AS current_week_positive,
                    SUM(CASE WHEN scanned_at >= NOW() - INTERVAL '14 days' AND scanned_at < NOW() - INTERVAL '7 days' THEN 1 ELSE 0 END) AS previous_week_positive
                FROM 
                    disease_scans
                WHERE 
                    is_positive = TRUE
            )
            SELECT 
                COALESCE(current_week_positive, 0) as current_week_positive,
                COALESCE(previous_week_positive, 0) as previous_week_positive,
                CASE 
                    WHEN COALESCE(previous_week_positive, 0) = 0 THEN CASE WHEN COALESCE(current_week_positive, 0) = 0 THEN 0 ELSE 100.00 END
                    ELSE ROUND(((current_week_positive - previous_week_positive)::NUMERIC / previous_week_positive) * 100, 2)
                END AS week_over_week_growth_pct
            FROM 
                WeeklyStats;
        `);

        // 4. Affected Geographic Area (Convex Hull)
        const metric4 = pool.query(`
            SELECT 
                CASE 
                    WHEN COUNT(*) < 3 THEN 0 -- Convex Hull requires at least 3 points
                    ELSE
                        ROUND(
                            (ST_Area(
                                ST_ConvexHull(
                                    ST_Collect(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326))
                                )::geography
                            ) / 1000000)::NUMERIC, 2
                        )
                END AS total_affected_area_sq_km
            FROM 
                disease_scans
            WHERE 
                is_positive = TRUE AND longitude IS NOT NULL AND latitude IS NOT NULL;
        `);

        // Execute all promises in parallel using the pool directly
        const [res1, res2, res3, res4] = await Promise.all([metric1, metric2, metric3, metric4]);

        return { 
            status: "success", 
            data: {
                overview: {
                    ...res1.rows[0],
                    dominant_pathogen: res1.rows[0].dominant_pathogen || "Undetermined"
                },
                hotspot: res2.rows[0] || { primary_district: "No Active Clusters", cases_in_cluster: 0, primary_pathogen: "N/A" },
                velocity: res3.rows[0],
                area: res4.rows[0]
            } 
        };
    } catch (err) {
        console.error("❌ National Metrics fetch error:", err.message);
        return { status: "error", message: err.message };
    }
};
