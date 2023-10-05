import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:maps/models/auto_complete_result.dart';

class MapServices {
  final String key = 'your API KEY';
  final String types = 'geocode';
  Future<List<AutoCompleteResult>> searchPlaces(String searchInput) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchInput&types=$types&key=$key';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Autocomplete Response data: ${response.body}');
        var json = convert.jsonDecode(response.body);
        var results = json['predictions'] as List;
        return results.map((e) => AutoCompleteResult.fromJson(e)).toList();
      } else {
        print('Autocomplete Error: ${response.statusCode}');
        // Handle the error as needed, e.g., throw an exception or return an empty list.
        throw Exception('Autocomplete request failed');
      }
    } catch (e) {
      print('Autocomplete Exception: $e');
      // Handle the exception as needed, e.g., return an empty list.
      return [];
    }
  }

  Future<Map<String, dynamic>> getPlace(String? input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$input&key=$key';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Place Details Response data: ${response.body}');
        var json = convert.jsonDecode(response.body);
        var results = json['result'] as Map<String, dynamic>;
        return results;
      } else {
        print('Place Details Error: ${response.statusCode}');
        // Handle the error as needed, e.g., throw an exception or return null.
        throw Exception('Place Details request failed');
      }
    } catch (e) {
      print('Place Details Exception: $e');
      // Handle the exception as needed, e.g., return null.
      return {};
    }
  }
}
/*
  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points'])
    };

    return results;
  }

  Future<dynamic> getPlaceDetails(LatLng coords, int radius) async {
    var lat = coords.latitude;
    var lng = coords.longitude;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?&location=$lat,$lng&radius=$radius&key=$key';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    return json;
  }

  Future<dynamic> getMorePlaceDetails(String token) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?&pagetoken=$token&key=$key';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    return json;
  }*/

