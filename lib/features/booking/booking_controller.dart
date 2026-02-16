import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

class BookingController extends StateNotifier<BookingState> {
  BookingController() : super(const BookingState());

  void selectService(Service service) {
    state = state.copyWith(service: service);
  }

  void selectStylist(Stylist stylist) {
    state = state.copyWith(stylist: stylist);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void selectTime(String timeSlot) {
    state = state.copyWith(timeSlot: timeSlot);
  }

  void reset() {
    state = const BookingState();
  }
}

final bookingControllerProvider = StateNotifierProvider<BookingController, BookingState>((ref) {
  return BookingController();
});
