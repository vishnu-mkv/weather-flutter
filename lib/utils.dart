import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import './weather.dart';

const API_KEY = "54863d221db85b9338b326f57a78298f";
const BASE_URL = "api.openweathermap.org";
const WEATHER_PATH = "/data/2.5/weather";

Uri buildURL(String? city, double? lat, double? lon) {
  final queryParameters = {
    'appid': API_KEY,
    'units': 'metric',
  };

  if (city != null) {
    queryParameters['q'] = city;
  } else if (lat != null && lon != null) {
    queryParameters['lat'] = lat.toString();
    queryParameters['lon'] = lon.toString();
  } else {
    throw Exception('Invalid parameters');
  }

  return Uri.https(BASE_URL, WEATHER_PATH, queryParameters);
}

Future<WeatherData> getWeather([String? city, double? lat, double? lon]) async {
  final url = buildURL(city, lat, lon);
  final res = await http.get(url);

  if (res.statusCode == 200) {
    return WeatherData.fromJson(json.decode(res.body));
  }

  throw Exception('Failed to load weather data');
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
