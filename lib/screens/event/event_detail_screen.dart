import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uiticket_fe/constants/design.dart';
import 'package:uiticket_fe/providers/event_provider.dart';
import 'package:uiticket_fe/providers/user_provider.dart';
import 'package:uiticket_fe/providers/ticket_provider.dart';
import 'package:uiticket_fe/models/ticket.dart';
import 'package:uiticket_fe/models/event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isBooking = false;

  // Widget để hiển thị thông tin creator
  Widget _buildCreatorInfo(BuildContext context, WidgetRef ref, String createdById) {
    if (createdById.isEmpty) {
      return _buildDefaultCreatorInfo(context);
    }

    final creatorAsync = ref.watch(userInfoProvider(createdById));
    
    return creatorAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading creator info...'),
          ],
        ),
      ),
      error: (error, stack) {
        print('Error loading creator: $error');
        return _buildDefaultCreatorInfo(context);
      },
      data: (creator) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Text(
                creator.name.isNotEmpty 
                  ? creator.name[0].toUpperCase() 
                  : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creator.name.isNotEmpty 
                      ? creator.name 
                      : 'Unknown Creator',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Event Organizer • ${creator.role.replaceAll('_', ' ').toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contact ${creator.name}'),
                  ),
                );
              },
              icon: const Icon(Icons.message, color: kPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCreatorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: const Text(
              'U',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unknown Creator',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Event Organizer',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.message, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _bookTicket(String eventId) async {
    if (_isBooking) return;

    setState(() {
      _isBooking = true;
    });

    try {
      final ticketRequest = ref.read(ticketRequestProvider);
      final ticket = await ticketRequest.bookTicket(eventId);
      
      print('Ticket booked successfully: ${ticket.toString()}');
      
      // Kiểm tra xem có payment URL không
      if (ticket.paymentData.isNotEmpty && 
          ticket.paymentData.containsKey('deeplink')) {
        final deeplink = ticket.paymentData['deeplink'] as String;
        
        // Hiển thị dialog xác nhận trước khi chuyển đến MoMo
        if (mounted) {
          _showPaymentDialog(ticket, deeplink);
        }
      } else {
        // Nếu không có payment data, hiển thị thông báo thành công
        if (mounted) {
          _showBookingSuccessDialog(ticket);
        }
      }
      
      // Refresh event data để cập nhật số lượng vé
      ref.invalidate(eventDetailProvider(eventId));
      
    } catch (e) {
      print('Error booking ticket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book ticket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  void _showPaymentDialog(Ticket ticket, String deeplink) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking Code: ${ticket.bookingCode}'),
              const SizedBox(height: 8),
              Text('Status: ${ticket.statusDisplayText}'),
              const SizedBox(height: 8),
              Text('Payment: ${ticket.paymentStatusDisplayText}'),
              const SizedBox(height: 16),
              if (ticket.paymentData.containsKey('amount'))
                Text('Amount: ${NumberFormat.currency(symbol: '\$').format((ticket.paymentData['amount'] as num) / 100)}'),
              const SizedBox(height: 16),
              const Text('Tap "Pay Now" to complete payment via MoMo.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchMoMoPayment(deeplink);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBookingSuccessDialog(Ticket ticket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking Code: ${ticket.bookingCode}'),
              const SizedBox(height: 8),
              Text('Status: ${ticket.statusDisplayText}'),
              const SizedBox(height: 8),
              const Text('Your ticket has been booked successfully!'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchMoMoPayment(String deeplink) async {
    try {
      print('Attempting to launch: $deeplink');
      
      final uri = Uri.parse(deeplink);
      
      // Thử launch với các mode khác nhau
      bool launched = false;
      
      // Thử với externalApplication mode
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Launch result: $launched');
      } catch (e) {
        print('ExternalApplication mode failed: $e');
      }
      
      // Nếu không thành công, thử với platformDefault
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          print('PlatformDefault launch result: $launched');
        } catch (e) {
          print('PlatformDefault mode failed: $e');
        }
      }
      
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open MoMo app. Please ensure MoMo is installed.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
    } catch (e) {
      print('Error launching MoMo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final ref = this.ref; // Get ref from ConsumerState
    final eventDetailAsync = ref.watch(eventDetailProvider(widget.eventId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: eventDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(eventDetailProvider(widget.eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (event) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              Container(
                height: 250,
                width: double.infinity,
                child: event.images.isNotEmpty 
                  ? Image.network(
                      event.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.event, size: 50),
                    ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Event Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM dd, yyyy - HH:mm').format(event.date),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Event Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Event Price
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        Text(
                          event.price == 0 ? 'Free' : '\$${event.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tickets Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${event.ticketsSold}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Sold'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${event.maxAttendees - event.ticketsSold}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Available'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${event.maxAttendees}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Total'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Creator Information
                    const Text(
                      'Event Creator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCreatorInfo(context, ref, event.createdBy),
                    const SizedBox(height: 20),
                    
                    // Event Description
                    if (event.description.isNotEmpty) ...[
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Event Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: event.status == 'active' 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Status: ${event.status.toUpperCase()}',
                        style: TextStyle(
                          color: event.status == 'active' 
                            ? Colors.green 
                            : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: eventDetailAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (event) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (event.maxAttendees > event.ticketsSold) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        event.price == 0 ? 'Free' : '\$${event.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.maxAttendees > event.ticketsSold 
                        ? kPrimaryColor 
                        : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: (event.maxAttendees > event.ticketsSold && !_isBooking)
                      ? () => _bookTicket(widget.eventId)
                      : null,
                    child: _isBooking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          event.maxAttendees > event.ticketsSold
                            ? 'Book Now'
                            : 'Sold Out',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}