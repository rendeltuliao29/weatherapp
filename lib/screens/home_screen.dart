import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
    final WeatherService _service = WeatherService();
  final TextEditingController _controller = TextEditingController();
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
    Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _service.fetchWeather(_controller.text);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  Future<void> _fetchWeather() async {
        setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
        final weather = await _service.fetchWeather(_controller.text);
              setState(() {
        _weather = weather;
        _isLoading = false;
      });
          } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
      @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
            body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                        TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
                        const SizedBox(height: 16),
                                    ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('Search'),
            ),
            const SizedBox(height: 30),
                        if (_isLoading)
              const CircularProgressIndicator(),
                          if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
                          if (_weather != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        _weather!.cityName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_weather!.temperature}°C',
                        style: const TextStyle(fontSize: 40),
                      ),
                      Text(_weather!.description),
                      Text('Humidity: ${_weather!.humidity}%'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}