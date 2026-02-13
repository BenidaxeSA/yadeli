import 'dart:io';

/// Mapbox supporté uniquement sur Android et iOS
bool get isMapboxSupported =>
    Platform.isAndroid || Platform.isIOS;
