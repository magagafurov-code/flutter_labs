import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  // ⚡ ВАШ НОВЫЙ КЛЮЧ WEATHERSTACK
  final String _apiKey = '1e94a7306bc23eaade9775a8047a3d5b';

  Future<void> _getWeather() async {
    String cityName = _cityController.text.trim();
    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Введите название города';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData = null;
    });

    try {
      // 🌐 НОВЫЙ URL ДЛЯ WEATHERSTACK
      final response = await http.get(
        Uri.parse(
          'https://api.weatherstack.com/current?access_key=$_apiKey&query=$cityName',
        ),
      );

      // Обработка ответа
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Проверка на ошибку от API (например, лимит или неверный ключ)
        if (data.containsKey('error')) {
          setState(() {
            _errorMessage = 'Ошибка API: ${data['error']['info'] ?? 'Неизвестная ошибка'}';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Ошибка соединения (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка сети. Проверьте интернет.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода (Weatherstack)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Поле ввода и кнопка
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Введите город...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF2A2F3F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                    onSubmitted: (_) => _getWeather(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5ECF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _getWeather,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Состояния
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6C5ECF),
                  ),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_weatherData != null)
                Expanded(
                  child: _buildWeatherInfo(),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 80,
                          color: Colors.yellow[700],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Узнайте погоду в любом городе',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    // 📌 ИЗВЛЕЧЕНИЕ ДАННЫХ ИЗ ОТВЕТА WEATHERSTACK
    final location = _weatherData!['location'];
    final current = _weatherData!['current'];

    final cityName = location['name'] ?? 'Неизвестно';
    final country = location['country'] ?? '';
    final temperature = current['temperature']?.round() ?? 0;
    final feelsLike = current['feelslike']?.round() ?? temperature;
    final description = current['weather_descriptions']?[0] ?? 'Нет данных';
    final humidity = current['humidity'] ?? 0;
    final windSpeed = current['wind_speed'] ?? 0;
    final iconUrl = current['weather_icons']?[0] ?? '';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Название города и страны
          Text(
            '$cityName, $country',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Иконка погоды
          if (iconUrl.isNotEmpty)
            Image.network(
              iconUrl,
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.cloud, size: 80),
            )
          else
            const Icon(Icons.cloud, size: 80),
          // Температура
          Text(
            '$temperature°C',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
          ),
          // Описание
          Text(
            description,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          // Детали
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2F3F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  icon: Icons.thermostat,
                  label: 'Ощущается',
                  value: '$feelsLike°C',
                ),
                _buildDetailItem(
                  icon: Icons.water_drop,
                  label: 'Влажность',
                  value: '$humidity%',
                ),
                _buildDetailItem(
                  icon: Icons.air,
                  label: 'Ветер',
                  value: '${windSpeed}м/с',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C5ECF)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}