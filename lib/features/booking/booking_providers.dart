import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/firebase_bootstrap.dart';
import '../auth/auth_controller.dart';
import '../bookings/user_booking.dart';
import '../../data/firebase/firestore_service.dart';
import 'booking_data.dart';
import 'models.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.read(firestoreProvider));
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  if (FirebaseBootstrap.enableFirebase) {
    return ref.read(firestoreServiceProvider).fetchServices();
  }
  return services;
});

final stylistsProvider = FutureProvider<List<Stylist>>((ref) async {
  if (FirebaseBootstrap.enableFirebase) {
    return ref.read(firestoreServiceProvider).fetchStylists();
  }
  return stylists;
});


final servicesStreamProvider = Provider<Stream<List<Service>>>((ref) {
  if (FirebaseBootstrap.enableFirebase) {
    return ref.read(firestoreServiceProvider).watchServices();
  }
  return Stream.value(services);
});

final stylistsStreamProvider = Provider<Stream<List<Stylist>>>((ref) {
  if (FirebaseBootstrap.enableFirebase) {
    return ref.read(firestoreServiceProvider).watchStylists();
  }
  return Stream.value(stylists);
});

final userBookingsStreamProvider = Provider<Stream<List<UserBooking>>>((ref) {
  if (!FirebaseBootstrap.enableFirebase) {
    return Stream.value(const <UserBooking>[]);
  }
  final profile = ref.watch(authControllerProvider).profile;
  final uid = profile?.uid ?? FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value(const <UserBooking>[]);
  }
  return ref.read(firestoreServiceProvider).watchBookings(userId: uid);
});

final timeSlotsProvider = Provider<List<String>>((ref) => timeSlots);
