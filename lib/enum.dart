enum Roles {
  admin,
  event_creator,
  ticket_buyer,
}

extension RolesExtension on Roles {
  String get value {
    switch (this) {
      case Roles.admin:
        return 'admin';
      case Roles.event_creator:
        return 'event_creator';
      case Roles.ticket_buyer:
        return 'ticket_buyer';
    }
  }
}