import 'package:dio/dio.dart';
import 'package:uiticket_fe/constants/api.dart';
import 'package:uiticket_fe/models/ticket.dart';
import 'package:uiticket_fe/services/http_services.dart';

class TicketRequest extends HttpServices {
  Future<Ticket> bookTicket(String eventId) async {
    try {
      final response = await post(
        url: Api.bookTicket,
        body: {
          'eventId': eventId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Book ticket response: ${response.data}');
        
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            return Ticket.fromJson(responseData['data']);
          } else {
            return Ticket.fromJson(responseData);
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to book ticket: ${response.statusCode}');
      }
    } catch (e) {
      print('Error booking ticket: $e');
      rethrow;
    }
  }

  // Future<List<Ticket>> getUserTickets() async {
  //   try {
  //     final response = await get(url: Api.tickets);
      
  //     if (response.statusCode == 200) {
  //       final List<dynamic> ticketsJson = response.data['data'] ?? response.data;
  //       return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load tickets: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error loading tickets: $e');
  //     rethrow;
  //   }
  // }

  // Thêm method mới để get ticket theo ID
  Future<Ticket> getTicketById(String ticketId) async {
    try {
      final response = await get(url: "${Api.tickets}/$ticketId");
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            return Ticket.fromJson(responseData['data']);
          } else {
            return Ticket.fromJson(responseData);
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load ticket: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading ticket: $e');
      rethrow;
    }
  }

  // Thêm method để cancel ticket
  // Future<Ticket> cancelTicket(String ticketId, {String reason = ''}) async {
  //   try {
  //     final response = await put(
  //       url: "${Api.tickets}/$ticketId/cancel",
  //       body: {
  //         'cancelReason': reason,
  //       },
  //     );
      
  //     if (response.statusCode == 200) {
  //       final responseData = response.data;
  //       if (responseData is Map<String, dynamic>) {
  //         if (responseData.containsKey('data')) {
  //           return Ticket.fromJson(responseData['data']);
  //         } else {
  //           return Ticket.fromJson(responseData);
  //         }
  //       } else {
  //         throw Exception('Invalid response format');
  //       }
  //     } else {
  //       throw Exception('Failed to cancel ticket: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error canceling ticket: $e');
  //     rethrow;
  //   }
  // }
}