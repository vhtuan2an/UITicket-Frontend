import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/models/ticket.dart';
import 'package:uiticket_fe/requests/ticket_request.dart';

final ticketRequestProvider = Provider((ref) => TicketRequest());

// final userTicketsProvider = FutureProvider<List<Ticket>>((ref,) async {
//   final ticketRequest = ref.read(ticketRequestProvider);
//   return await ticketRequest.getUserTickets();
// });

// Provider cho book ticket
final bookTicketProvider = FutureProvider.family<Ticket, String>((ref, eventId) async {
  final ticketRequest = ref.read(ticketRequestProvider);
  return await ticketRequest.bookTicket(eventId);
});

// Provider cho get ticket theo ID
final ticketDetailProvider = FutureProvider.family<Ticket, String>((ref, ticketId) async {
  final ticketRequest = ref.read(ticketRequestProvider);
  return await ticketRequest.getTicketById(ticketId);
});