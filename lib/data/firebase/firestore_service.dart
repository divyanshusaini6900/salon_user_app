import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/booking/models.dart';
import '../../features/bookings/user_booking.dart';

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


  Stream<List<Service>> watchServices() {
    return _firestore.collection('services').snapshots().map((snapshot) {
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
    });
  }

  Stream<List<Stylist>> watchStylists() {
    return _firestore.collection('stylists').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Stylist(
          name: data['name'] as String? ?? doc.id,
          level: data['level'] as String? ?? 'Stylist',
        );
      }).toList();
    });
  }

  Stream<List<UserBooking>> watchBookings({required String userId}) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(UserBooking.fromDoc).toList());
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    await _firestore.collection('bookings').add(data);
  }
}
