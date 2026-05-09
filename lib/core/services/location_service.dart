// lib/core/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;
  final String  place; // ← adresse lisible ex: "Ghazela, Ariana, Tunisie"
  final String? error;

  const LocationResult._({
    this.latitude,
    this.longitude,
    required this.place,
    this.error,
  });

  bool get ok => error == null;
}

class LocationService {
  /// Retourne la position GPS + adresse lisible de l'opérateur.
  /// Si refusée ou indisponible → retourne "AUTO" sans bloquer.
  static Future<LocationResult> getLocation() async {
    try {
      // 1. Vérifier si le GPS est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult._(
          place: 'GPS désactivé',
          error: 'GPS désactivé',
        );
      }

      // 2. Vérifier / demander la permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult._(
            place: 'Permission refusée',
            error: 'Permission refusée',
          );
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult._(
          place: 'Permission refusée définitivement',
          error: 'Permission refusée définitivement',
        );
      }

      // 3. Obtenir les coordonnées GPS
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // 4. Reverse geocoding → adresse lisible
      final place = await _toAddress(pos.latitude, pos.longitude);

      return LocationResult._(
        latitude:  pos.latitude,
        longitude: pos.longitude,
        place:     place,
      );
    } catch (e) {
      return LocationResult._(
        place: 'AUTO',
        error: e.toString(),
      );
    }
  }

  /// Convertit des coordonnées en adresse lisible.
  /// Exemples de résultats :
  ///   "Ghazela, Ariana, Tunisie"
  ///   "Rue de la Paix, Paris, France"
  ///   "36.81921, 10.16584"  ← fallback si geocoding échoue
  static Future<String> _toAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }

      final p = placemarks.first;

      // Construire une adresse lisible avec les champs disponibles
      // Exemple : "Ghazela, Ariana, Tunisie"
      final parts = <String>[];

      if (p.subLocality?.isNotEmpty == true)   parts.add(p.subLocality!);    // Ghazela
      if (p.locality?.isNotEmpty == true)       parts.add(p.locality!);       // Ariana
      if (p.administrativeArea?.isNotEmpty == true &&
          p.administrativeArea != p.locality)   parts.add(p.administrativeArea!);
      if (p.country?.isNotEmpty == true)        parts.add(p.country!);        // Tunisie

      if (parts.isEmpty) {
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }

      return parts.join(', ');
    } catch (_) {
      // Si le geocoding échoue (pas de réseau), on tombe sur les coords brutes
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
  }
}