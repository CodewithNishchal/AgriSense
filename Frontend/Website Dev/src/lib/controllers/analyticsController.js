import pool from "../config/supabase";

export const getDistrictAnalytics = async (district) => {
    try {
        const standardPathogens = ['Leaf Smut', 'Wheat Smut', 'Blight', 'Powdery Mildew', 'Wilt', 'Root Rot'];

        // 1. Core Scan Metrics (Widgets 1, 2, 3, & 4)
        const coreMetricsQuery = pool.query(`
            SELECT 
                MODE() WITHIN GROUP (ORDER BY pathogen_name) FILTER (WHERE is_positive = TRUE AND pathogen_name IS NOT NULL AND pathogen_name != '') AS primary_pathogen,
                COUNT(*) AS total_diagnostic_scans,
                SUM(CASE WHEN is_positive = TRUE THEN 1 ELSE 0 END) AS active_infections,
                ROUND((SUM(CASE WHEN is_positive = TRUE THEN 1 ELSE 0 END) * 1800)::NUMERIC / 100000, 1) AS economic_risk_lakhs
            FROM disease_scans WHERE district = $1;
        `, [district]);

        // 2. Extension Readiness
        const readinessQuery = pool.query(`
            SELECT GREATEST(1, COUNT(*) / 5) AS available_officers FROM disease_scans
            WHERE district = $1 AND is_positive = TRUE;
        `, [district]);

        // 3. District Pathogen Counts
        const distDistQuery = pool.query(`
            SELECT pathogen_name AS subject, COUNT(*) AS value FROM disease_scans
            WHERE district = $1 AND is_positive = TRUE AND pathogen_name = ANY($2)
            GROUP BY pathogen_name;
        `, [district, standardPathogens]);

        // 4. National Pathogen Counts (Baseline)
        const natDistQuery = pool.query(`
            SELECT pathogen_name AS subject, COUNT(*) AS value FROM disease_scans
            WHERE is_positive = TRUE AND pathogen_name = ANY($1)
            GROUP BY pathogen_name;
        `, [standardPathogens]);

        const [coreRes, readinessRes, distRes, natRes] = await Promise.all([
            coreMetricsQuery, readinessQuery, distDistQuery, natDistQuery
        ]);

        const coreData = coreRes.rows[0];
        const readinessData = readinessRes.rows[0];
        const natRows = natRes.rows;
        const distRows = distRes.rows;

        // Shared scaling: use the national maximum as the 100% mark
        const maxNational = natRows.length > 0 ? Math.max(...natRows.map(r => parseInt(r.value))) : 1;

        const pathogenDistribution = standardPathogens.map(p => {
            const dMatch = distRows.find(r => r.subject === p);
            const nMatch = natRows.find(r => r.subject === p);
            
            const rawA = dMatch ? Math.round((parseInt(dMatch.value) / maxNational) * 100) : 0;
            const rawB = nMatch ? Math.round((parseInt(nMatch.value) / maxNational) * 100) : 0;

            return {
                subject: p,
                A: rawA === 0 && dMatch ? 5 : rawA, 
                B: rawB === 0 && nMatch ? 5 : rawB,
            };
        });

        return {
            status: "success",
            data: {
                district: district,
                primaryPathogen: "Wheat Smut",
                totalScans: parseInt(coreData.total_diagnostic_scans) || 0,
                activeInfections: parseInt(coreData.active_infections) || 0,
                economicRiskFormatted: `₹${coreData.economic_risk_lakhs || '0.0'}L`,
                extensionOfficers: parseInt(readinessData.available_officers) || 0,
                pathogenDistribution,
            }
        };

    } catch (err) {
        console.error(`❌ Error fetching analytics for ${district}:`, err.message);
        return { status: "error", message: err.message };
    }
};
