import 'package:flutter/material.dart';

@immutable
class Service {
  const Service({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
  });

  final String id;
  final String name;
  final Duration duration;
  final double price;
  final double rating;
  final String category;
  final String description;
}

@immutable
class Stylist {
  const Stylist({required this.name, required this.level});

  final String name;
  final String level;
}

@immutable
class BookingState {
  const BookingState({
    this.service,
    this.stylist,
    this.date,
    this.timeSlot,
  });

  final Service? service;
  final Stylist? stylist;
  final DateTime? date;
  final String? timeSlot;

  BookingState copyWith({
    Service? service,
    Stylist? stylist,
    DateTime? date,
    String? timeSlot,
  }) {
    return BookingState(
      service: service ?? this.service,
      stylist: stylist ?? this.stylist,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }

  bool get isComplete => service != null && date != null && timeSlot != null;
}
