# AgriSense Development Roadmap: Order of Creation

This guide outlines the step-by-step creation of the **AgriSense** project. To keep your work tree clean and prevent bulk commits, copy these files 2-3 at a time in the following sequence.

### Phase 1: Foundation & Core Configuration
*Set up the environment and database connectivity first.*
1. `package.json` — All required dependencies (Next.js, Mapbox, SWR, Mongoose, Lucid React).
2. `.env` — Database URI, token secrets, and Mapbox API keys.
3. `src/dbConfig/dbConfig.ts` — The central MongoDB connection logic.
4. `src/lib/mapboxConfig.ts` — Shared configuration for Mapbox components.

### Phase 2: Domain Models (The Blueprints)
*Define how data is structured before building the APIs.*
5. `src/models/userModel.ts` — Authentication schema (Roles: Inspector, Farmer, Lender).
6. `src/models/fleetModel.ts` — Schema for equipment, telematics, and rent sessions.
7. `src/models/scanModel.ts` — Database schema for disease scans and outbreaks.

### Phase 3: Global UI & Authentication
*The framework of the application.*
8. `src/app/layout.tsx` & `src/app/globals.css` — Global styling and font imports.
9. `src/components/Header.tsx` & `src/components/Sidebar.tsx` — Navigation infrastructure.
10. `src/app/login/page.tsx` & `src/app/signup/page.tsx` — The split-screen authenticated entry.

### Phase 4: Backend Data Core (API Routes)
*Implement the logic that feeds the dashboards.*
11. `src/app/api/users/login/route.ts` & `signup/route.ts` — Backend auth logic.
12. `src/app/api/analytics/national/route.ts` — Aggregated national health metrics.
13. `src/app/api/charts/time-series/route.ts` — Predictive data for the "Hackathon Trick" (History + Forecast).

### Phase 5: Role-Specific Feature: Inspection
*Building the inspector's terminal.*
14. `src/components/inspection/InspectionMap.tsx` — The primary Mapbox visualization for disease heatmaps.
15. `src/app/api/scans/recent/route.ts` — Endpoint for the latest inspection data.
16. `src/components/inspection/OutbreakAlerts.tsx` — UI for real-time risk notifications.

### Phase 6: Role-Specific Feature: Fleet Management
*Building the equipment lender/renter terminal.*
17. `src/app/api/fleet/overview/route.ts` — KPI aggregation for fleet status.
18. `src/app/api/fleet/telematics/route.ts` — Real-time GeoJSON provider for tractor locations.
19. `src/components/fleet/FleetNavTabs.tsx` — Custom navigation for fleet views.

### Phase 7: Landing Experience & Final Polish
*The first thing the user sees and performance optimizations.*
20. `src/app/page.tsx` — The premium, animated three-role landing page.
21. `src/app/api/map-data/route.ts` — The generalized map-data provider.
22. **Optimization Pass**: Adding `export const revalidate = 60;` to all National Analytics and Fleet routes for Vercel Edge Caching.

### Development Utilities (Use Only for Seeding/Testing)
* `schema.js` — Database schema initialization.
* `seedFleet.js` — Script to populate the fleet database with realistic test data.
* `testApi.js` — Quick sanity check for the backend endpoints.

---
**Tip:** After copying each phase, run `npm dev` to ensure no circular dependencies or missing model errors were introduced.
