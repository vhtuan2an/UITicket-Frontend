import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/constants/design.dart';
import 'package:uiticket_fe/providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  
  const EventDetailScreen({super.key, required this.eventId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng provider để fetch thông tin chi tiết của event theo ID
    final eventDetailAsync = ref.watch(eventDetailProvider(eventId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: eventDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
        data: (event) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị thông tin chi tiết của event
              // ...
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Chuyển đến màn hình đặt vé
            },
            child: const Text('Book Tickets'),
          ),
        ),
      ),
    );
  }
}