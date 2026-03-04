import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isCelsius = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    FocusScope.of(context).unfocus();

    if (_controller.text.trim().isEmpty) {
      setState(() => _errorMessage = "Please enter a city name.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _service.fetchWeather(_controller.text.trim());

      await _saveLastCity(_controller.text.trim());

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = "City not found.";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);
  }

  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('last_city');
    if (lastCity != null) {
      _controller.text = lastCity;
    }
  }

  double _getDisplayTemp() {
    if (_weather == null) return 0;
    return _isCelsius
        ? _weather!.temperature
        : (_weather!.temperature * 9 / 5) + 32;
  }

  String _getWeatherIcon(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('clear')) return '☀️';
    if (desc.contains('cloud')) return '⛅';
    if (desc.contains('rain')) return '🌧️';
    if (desc.contains('storm')) return '⛈️';
    if (desc.contains('snow')) return '❄️';
    if (desc.contains('mist') || desc.contains('fog')) return '🌫️';
    return '🌡️';
  }

  Color _getBackgroundColor(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('clear')) return const Color(0xFF87CEEB);
    if (desc.contains('cloud')) return const Color(0xFFB0BEC5);
    if (desc.contains('rain')) return const Color(0xFF546E7A);
    if (desc.contains('storm')) return const Color(0xFF37474F);
    if (desc.contains('snow')) return const Color(0xFFE3F2FD);
    if (desc.contains('mist') || desc.contains('fog')) {
      return const Color(0xFFCFD8DC);
    }
    return const Color(0xFF87CEEB);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _weather != null
        ? _getBackgroundColor(_weather!.description)
        : const Color(0xFF87CEEB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _isCelsius = !_isCelsius),
              child: Chip(
                label: Text(_isCelsius ? '°C' : '°F'),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildSearchButton(),
            const SizedBox(height: 30),
            if (_isLoading) _buildLoading(),
            if (_errorMessage != null) _buildError(),
            if (_weather != null) _buildWeatherCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Enter city name',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _fetchWeather,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Search'),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text(
          'Fetching weather...',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _weather!.cityName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getWeatherIcon(_weather!.description),
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 4),
            Text(
              '${_getDisplayTemp().toStringAsFixed(1)}${_isCelsius ? '°C' : '°F'}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(_weather!.description),
            Text('Humidity: ${_weather!.humidity}%'),
          ],
        ),
      ),
    );
  }
}
