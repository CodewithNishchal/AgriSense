import { NextResponse } from 'next/server';
import { getDistrictAnalytics } from '@/lib/controllers/analyticsController';
 
// Optimization: Cache district metrics for 60 seconds
export const revalidate = 60;

export async function GET(request, { params }) {
    const { district } = await params;

    if (!district) {
        return NextResponse.json({ status: "error", message: "District parameter is required" }, { status: 400 });
    }

    const result = await getDistrictAnalytics(decodeURIComponent(district));

    if (result.status === "success") {
        return NextResponse.json(result);
    } else {
        return NextResponse.json({ status: "error", message: result.message }, { status: 500 });
    }
}
