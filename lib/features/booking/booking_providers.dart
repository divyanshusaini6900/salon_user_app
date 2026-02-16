import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/firebase_bootstrap.dart';
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

final timeSlotsProvider = Provider<List<String>>((ref) => timeSlots);
