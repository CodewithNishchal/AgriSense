/// Validates [raw] for [AnalyzeSaveService]: must be `http`/`https`, never a DB connection string.
void assertValidAnalyzeSaveUrl(String raw) {
  final url = raw.trim();
  if (url.isEmpty) {
    throw StateError(
      'ANALYZE_SAVE_API_URL is empty. Set it in assets/.env or '
      '--dart-define=ANALYZE_SAVE_API_URL=...',
    );
  }

  final u = Uri.tryParse(url);
  if (u == null || !u.hasScheme || u.host.isEmpty) {
    throw StateError(
      'ANALYZE_SAVE_API_URL must be a full URL, e.g. '
      'https://your-app.vercel.app/api/analyze/save',
    );
  }

  final scheme = u.scheme.toLowerCase();
  const dbSchemes = {
    'postgresql',
    'postgres',
    'mysql',
    'mongodb',
    'mongodb+srv',
    'redis',
  };
  if (dbSchemes.contains(scheme)) {
    throw StateError(
      'ANALYZE_SAVE_API_URL must be an HTTPS API endpoint, not a $scheme:// database URL. '
      'Put DATABASE_URL only on your server (Next.js / Vercel env). The app POSTs JSON to https://…',
    );
  }

  if (scheme != 'http' && scheme != 'https') {
    throw StateError(
      'ANALYZE_SAVE_API_URL must start with https:// (or http:// for local dev). '
      'Unsupported scheme: $scheme',
    );
  }
}

/// Host for logs only (no path, no credentials).
String? analyzeSaveUrlHostForLog(String raw) {
  final u = Uri.tryParse(raw.trim());
  if (u == null || u.host.isEmpty) return null;
  return u.host;
}
