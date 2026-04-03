"use client";

import { useState, useEffect, useMemo } from 'react';
import Map, { Source, Layer, Popup } from 'react-map-gl/mapbox';
import 'mapbox-gl/dist/mapbox-gl.css';

export default function InspectionMap() {
  const [scans, setScans] = useState<any[]>([]);
  const [hoverInfo, setHoverInfo] = useState<any>(null);

  useEffect(() => {
    // Fetch from your updated API route
    fetch('/api/scans')
      .then(res => res.json())
      .then(data => setScans(data))
      .catch(console.error);
  }, []);

  // 1. Convert your DB rows into a valid GeoJSON object for Mapbox
  const geojson = useMemo(() => ({
    type: 'FeatureCollection' as const,
    features: scans.map(scan => ({
      type: 'Feature' as const,
      geometry: { type: 'Point' as const, coordinates: [scan.lng, scan.lat] },
      properties: {
        id: scan.id,
        district: scan.district,
        pathogen_name: scan.pathogen_name,
        intensity_count: parseInt(scan.intensity_count, 10) // The magic number
      }
    }))
  }), [scans]);

  // 2. Define the Data-Driven Styling Layer
  const layerStyle: any = {
    id: 'disease-points',
    type: 'circle',
    paint: {
      // Map the radius to be slightly larger for higher intensity
      'circle-radius': ['interpolate', ['linear'], ['get', 'intensity_count'],
        1, 8,   // If count is 1, radius is 8px
        10, 15  // If count is 10+, radius is 15px
      ],
      // THE COLOR GRADIENT: Map the intensity_count to a Green -> Red scale
      'circle-color': [
        'interpolate',
        ['linear'],
        ['get', 'intensity_count'],
        1, '#10b981',  // Green (1-3 cases)
        4, '#eab308',  // Yellow (Escalating cluster)
        7, '#f97316',  // Orange (Hotspot)
        10, '#ef4444'  // Red (Severe Outbreak)
      ],
      'circle-stroke-width': 1,
      'circle-stroke-color': '#ffffff',
      'circle-opacity': 0.8
    }
  };

  return (
    <div style={{ width: '100%', height: '500px', borderRadius: '8px', overflow: 'hidden' }}>
      <Map
        // Be sure your env file uses NEXT_PUBLIC_MAPBOX_TOKEN as you verified in your codebase earlier
        mapboxAccessToken={process.env.NEXT_PUBLIC_MAPBOX_TOKEN || process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN}
        initialViewState={{ longitude: 79.0882, latitude: 21.1458, zoom: 5 }}
        mapStyle="mapbox://styles/mapbox/dark-v11" // Dark mode makes heatmaps pop!
        interactiveLayerIds={['disease-points']}
        onMouseEnter={(e: any) => {
          if (e.features && e.features.length > 0) {
            setHoverInfo({
              feature: e.features[0],
              x: e.lngLat.lng,
              y: e.lngLat.lat
            });
          }
        }}
        onMouseLeave={() => setHoverInfo(null)}
      >
        {/* Feed the GeoJSON into the Mapbox Layer */}
        {scans.length > 0 && (
          <Source id="scans-data" type="geojson" data={geojson}>
            <Layer {...layerStyle} />
          </Source>
        )}

        {/* Hover Tooltip */}
        {hoverInfo && (
          <Popup
            longitude={hoverInfo.x}
            latitude={hoverInfo.y}
            closeButton={false}
            closeOnClick={false}
            anchor="bottom"
          >
            <div style={{ padding: '4px', color: '#000' }}>
              <strong>{hoverInfo.feature.properties.district}</strong><br/>
              Pathogen: {hoverInfo.feature.properties.pathogen_name}<br/>
              Nearby Cases (5km): {hoverInfo.feature.properties.intensity_count}
            </div>
          </Popup>
        )}
      </Map>
    </div>
  );
}
