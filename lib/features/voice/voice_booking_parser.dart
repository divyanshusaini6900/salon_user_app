import 'package:intl/intl.dart';

import '../booking/booking_data.dart';
import '../booking/models.dart';

class VoiceBookingResult {
  VoiceBookingResult({
    required this.rawText,
    this.service,
    this.stylist,
    this.date,
    this.timeSlot,
  });

  final String rawText;
  final Service? service;
  final Stylist? stylist;
  final DateTime? date;
  final String? timeSlot;

  bool get isComplete => service != null && date != null && timeSlot != null;
}

class VoiceBookingParser {
  VoiceBookingResult parse(String text) {
    final normalized = text.toLowerCase();
    final service = _matchService(normalized);
    final stylist = _matchStylist(normalized);
    final date = _matchDate(normalized);
    final timeSlot = _matchTimeSlot(normalized);

    return VoiceBookingResult(
      rawText: text,
      service: service,
      stylist: stylist,
      date: date,
      timeSlot: timeSlot,
    );
  }

  Service? _matchService(String input) {
    if (input.contains('haircut') || input.contains('cut')) {
      return services.firstWhere((s) => s.id == 'cut');
    }
    if (input.contains('color') || input.contains('colour')) {
      return services.firstWhere((s) => s.id == 'color');
    }
    if (input.contains('spa') || input.contains('scalp')) {
      return services.firstWhere((s) => s.id == 'spa');
    }
    if (input.contains('style') || input.contains('blowout')) {
      return services.firstWhere((s) => s.id == 'style');
    }
    if (input.contains('manicure') || input.contains('nail')) {
      return services.firstWhere((s) => s.id == 'nails');
    }
    return null;
  }

  Stylist? _matchStylist(String input) {
    for (final stylist in stylists) {
      if (input.contains(stylist.name.toLowerCase())) {
        return stylist;
      }
    }
    return null;
  }

  DateTime? _matchDate(String input) {
    final now = DateTime.now();
    if (input.contains('today')) return DateTime(now.year, now.month, now.day);
    if (input.contains('tomorrow')) return DateTime(now.year, now.month, now.day + 1);

    final weekdays = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    for (final entry in weekdays.entries) {
      if (input.contains(entry.key)) {
        final target = entry.value;
        var date = DateTime(now.year, now.month, now.day);
        while (date.weekday != target) {
          date = date.add(const Duration(days: 1));
        }
        return date;
      }
    }
    return null;
  }

  String? _matchTimeSlot(String input) {
    final regex = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)');
    final match = regex.firstMatch(input);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2) ?? '00');
    final period = match.group(3)!.toUpperCase();

    var hour24 = hour % 12;
    if (period == 'PM') hour24 += 12;
    if (period == 'AM' && hour == 12) hour24 = 0;
    final formatted = DateFormat('hh:mm a').format(DateTime(0, 1, 1, hour24, minute));

    for (final slot in timeSlots) {
      if (slot == formatted) return slot;
    }
    return null;
  }
}
