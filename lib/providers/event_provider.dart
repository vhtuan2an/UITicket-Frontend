import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/models/event.dart';
import 'package:uiticket_fe/requests/event_request.dart';

final eventRequestProvider = Provider((ref) => EventRequest());

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventRequest = ref.read(eventRequestProvider);
  return await eventRequest.getEvents();
});