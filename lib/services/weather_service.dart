import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_model.dart';


class WeatherService {
  final String apiKey = 'YOUR_API_KEY_HERE';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
    Future<WeatherModel> fetchWeather(String city) async {
          final url = Uri.parse(
      '$baseUrl?q=$city&appid=$apiKey&units=metric',
    );
        final response = await http.get(url);
            if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
          } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }
}