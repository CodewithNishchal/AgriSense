/**
 * Next.js App Router: save as `app/api/analyze/save/route.ts`.
 * Set DATABASE_URL only on the server (Vercel env, .env.local). Never in the Flutter app.
 */
import { NextResponse } from 'next/server';
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export async function POST(request: Request) {
  try {
    const payload = await request.json();

    const query = `
      INSERT INTO disease_scans (
        scanned_at,
        latitude,
        longitude,
        pathogen_name,
        confidence_score,
        is_positive,
        raw_ai_payload
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id;
    `;

    const values = [
      payload.timestamp,
      payload.location?.lat ?? null,
      payload.location?.lon ?? null,
      payload.disease_key,
      payload.confidence_raw,
      payload.is_positive,
      payload,
    ];

    const client = await pool.connect();
    try {
      const result = await client.query(query, values);
      return NextResponse.json({
        success: true,
        scanId: result.rows[0].id,
        message: 'Diagnostic saved securely to PostgreSQL.',
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Database Error:', error);
    return NextResponse.json(
      { error: 'Failed to save diagnostic scan' },
      { status: 500 },
    );
  }
}
