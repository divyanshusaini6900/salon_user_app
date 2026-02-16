import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/booking/models.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Service>> fetchServices() async {
    final snapshot = await _firestore.collection('services').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Service(
        id: doc.id,
        name: data['name'] as String? ?? doc.id,
        duration: Duration(minutes: (data['durationMinutes'] as num?)?.toInt() ?? 45),
        price: (data['price'] as num?)?.toDouble() ?? 0,
        rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
        category: data['category'] as String? ?? 'Hair',
        description: data['description'] as String? ?? '',
      );
    }).toList();
  }

  Future<List<Stylist>> fetchStylists() async {
    final snapshot = await _firestore.collection('stylists').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Stylist(
        name: data['name'] as String? ?? doc.id,
        level: data['level'] as String? ?? 'Stylist',
      );
    }).toList();
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    await _firestore.collection('bookings').add(data);
  }
}
