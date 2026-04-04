import { NextResponse } from 'next/server';
import { getNationalMetrics } from '@/lib/controllers/nationalMetricsController';

// Revalidates data every 60 seconds for Edge caching
export const revalidate = 60;

export async function GET() {
    const result = await getNationalMetrics();
    
    if (result.status === "success") {
        return NextResponse.json(result);
    } else {
        return NextResponse.json({ 
            status: "error", 
            message: result.message 
        }, { status: 500 });
    }
}
