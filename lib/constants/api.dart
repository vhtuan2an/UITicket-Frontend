class Api {
  static const String baseUrl = 'https://uiticket-backend.onrender.com/';
  
  // Auth
  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String resetPassword = "auth/reset-password";

  // User
  static const String users = "users";

  // Event
  static const String events = "events";

  // Ticket
  static const String tickets = "tickets";
  static const String bookTicket = "tickets/book";
}
