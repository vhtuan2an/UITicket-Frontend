import 'package:dio/dio.dart';
import 'package:uiticket_fe/constants/api.dart';
import 'package:uiticket_fe/models/event.dart';
import 'package:uiticket_fe/services/http_services.dart';
import 'package:uiticket_fe/models/event.dart';

class EventRequest extends HttpServices {
  Future<List<Event>> getEvents() async {
    try {
      final response = await get(url: Api.getEvents);
      
      if (response.statusCode == 200) {
        // Kiểm tra cấu trúc response
        print('Event response structure: ${response.data.runtimeType}');
        
        // Nếu response.data['data'] là một List
        if (response.data['data'] is List) {
          final List<dynamic> eventsJson = response.data['data'];
          return eventsJson.map((json) => Event.fromJson(json)).toList();
        } 
        // Nếu response.data có cấu trúc khác
        else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      rethrow;
    }
  }
}