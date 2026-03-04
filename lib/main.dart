import 'services/weather_service.dart';
import 'package:flutter/material.dart';
void main() async {
  final service = WeatherService();

  try {
    final weather = await service.fetchWeather('Manila');
    print('City: ${weather.cityName}');
    print('Temp: ${weather.temperature}°C');
    print('Desc: ${weather.description}');
    print('Humidity: ${weather.humidity}%');
  } catch (e) {
    print('Error: $e');
  }
}