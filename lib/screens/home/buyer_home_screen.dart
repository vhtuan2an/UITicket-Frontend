import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uiticket_fe/constants/design.dart';
import 'package:uiticket_fe/providers/event_provider.dart';
import 'package:uiticket_fe/screens/event/event_detail_screen.dart';
import 'package:uiticket_fe/screens/event/widgets/event_card.dart';
import 'dart:math' as math;

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: kPrimaryColor,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Hello, John", style: TextStyle(fontSize: 16, color: Colors.white)),
                   const Text(
                    "Find your next event",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Flexible(child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),)
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventsProvider);
          return await ref.read(eventsProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section hiển thị "Upcoming Events" với nút "See All"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upcoming Events",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // Xử lý khi nhấn vào See All
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Events theo chiều ngang
              SizedBox(
                height: 280,
                child: eventsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
                  data: (events) {
                    if (events.isEmpty) {
                      return const Center(child: Text('No events available'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(), // Cho phép scroll ngang với hiệu ứng bounce
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: math.min(events.length, 3), 
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final eventImage = event.images.isNotEmpty 
                            ? event.images.first 
                            : "https://via.placeholder.com/150";
                        final formattedDate = DateFormat('dd MMM').format(event.date).toUpperCase();
                        
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          margin: const EdgeInsets.only(right: 16),
                          child: EventCard(
                            title: event.name,
                            date: formattedDate,
                            location: event.location,
                            image: eventImage,
                            eventId: event.id, // Truyền ID sự kiện
                            onTap: () {
                              // Điều hướng đến trang chi tiết event
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => EventDetailScreen(eventId: event.id),
                              //   ),
                            },
                          )
                        );
                      },
                    );
                  },
                ),
              ),
              
              // Section hiển thị "All Events"
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "All Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              // Danh sách All Events theo chiều ngang (thay vì dọc)
              SizedBox(
                height: 280,  // Sử dụng cùng chiều cao với phần Upcoming Events
                child: eventsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
                  data: (events) {
                    if (events.isEmpty) {
                      return const Center(child: Text('No events available'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,  // Thay đổi thành horizontal
                      physics: const BouncingScrollPhysics(),  // Sử dụng BouncingScrollPhysics thay vì NeverScrollableScrollPhysics
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: math.min(events.length, 3),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final eventImage = event.images.isNotEmpty 
                            ? event.images.first 
                            : "https://via.placeholder.com/150";
                        final formattedDate = DateFormat('dd MMM').format(event.date).toUpperCase();
                        
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.7,  // Giống như Upcoming Events
                          margin: const EdgeInsets.only(right: 16),
                          child: EventCard(
                            title: event.name,
                            date: formattedDate,
                            location: event.location,
                            image: eventImage,
                            eventId: event.id, // Truyền ID sự kiện
                            onTap: () {
                              // Điều hướng đến trang chi tiết event
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => EventDetailScreen(eventId: event.id),
                              //
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, size: 32),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final Color color;

  const CategoryButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}


 