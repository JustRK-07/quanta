/// Backend URL configuration.
///
/// Override for a deployed build with:
/// flutter build web --release --dart-define=QUANTA_API_BASE_URL=https://...
const String quantaApiBaseUrl = String.fromEnvironment(
  'QUANTA_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8001',
);
