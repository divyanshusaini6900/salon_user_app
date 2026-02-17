import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import '../booking/booking_controller.dart';
import '../booking/booking_providers.dart';
import '../booking/models.dart';
import 'voice_booking_parser.dart';

class VoiceBookingScreen extends ConsumerStatefulWidget {
  const VoiceBookingScreen({super.key});

  @override
  ConsumerState<VoiceBookingScreen> createState() => _VoiceBookingScreenState();
}

class _VoiceBookingScreenState extends ConsumerState<VoiceBookingScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _transcript = '';
  VoiceBookingResult? _result;

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _parseTranscript();
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available on this device.')),
      );
      return;
    }

    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() => _transcript = result.recognizedWords);
      },
    );
  }

  void _parseTranscript() {
    if (_transcript.trim().isEmpty) return;
    final parser = VoiceBookingParser();
    setState(() => _result = parser.parse(_transcript));
  }

  void _applyToBooking() {
    if (_result == null) return;
    final bookingNotifier = ref.read(bookingControllerProvider.notifier);
    if (_result!.service != null) bookingNotifier.selectService(_result!.service!);
    if (_result!.stylist != null) bookingNotifier.selectStylist(_result!.stylist!);
    if (_result!.date != null) bookingNotifier.selectDate(_result!.date!);
    if (_result!.timeSlot != null) bookingNotifier.selectTime(_result!.timeSlot!);

    if (_result!.isComplete) {
      context.go('/summary');
    } else {
      context.go('/schedule');
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final servicesStream = ref.watch(servicesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Booking')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          Text('Say your booking', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Example: ?Book haircut with Yoyo this Saturday at 5 PM?.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isListening ? 'Listening...' : 'Tap the mic to start speaking',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleListening,
                      icon: Icon(_isListening ? Icons.stop_circle : Icons.mic_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_transcript.isEmpty ? 'No transcript yet.' : _transcript,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_result != null) ...[
            Text('Detected details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _DetailRow(label: 'Service', value: _result!.service?.name ?? 'Not detected'),
            _DetailRow(label: 'Stylist', value: _result!.stylist?.name ?? 'Not detected'),
            _DetailRow(label: 'Date', value: _result!.date != null ? DateFormat('EEE, d MMM').format(_result!.date!) : 'Not detected'),
            _DetailRow(label: 'Time', value: _result!.timeSlot ?? 'Not detected'),
            const SizedBox(height: 16),
            GradientButton(
              label: _result!.isComplete ? 'Continue to summary' : 'Complete details',
              onPressed: _applyToBooking,
            ),
            const SizedBox(height: 12),
            Text('If something looks off, you can edit it in the next step.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.softInk)),
          ],
          const SizedBox(height: 24),
          Text('Popular services', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          StreamBuilder<List<Service>>(
            stream: servicesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Failed to load services');
              }
              final services = snapshot.data ?? [];
              return Wrap(
                spacing: 8,
                children: services.map((service) => Chip(label: Text(service.name))).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
