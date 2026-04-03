import { NextResponse } from 'next/server';
import { getMapMarkers } from '@/lib/controllers/mapController';
 
// Scale to millions: Cache the map data for 60 seconds at the Edge
export const revalidate = 60;

export async function GET() {
    const result = await getMapMarkers();
    
    if (result.status === "success") {
        return NextResponse.json(result);
    } else {
        return NextResponse.json({ 
            status: "error", 
            message: result.message 
        }, { status: 500 });
    }
}
