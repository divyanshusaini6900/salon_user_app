import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../app/firebase_bootstrap.dart';
import '../../data/firebase/storage_service.dart';

class AiLook {
  AiLook({required this.name, required this.description, required this.tagline, required this.serviceId});

  final String name;
  final String description;
  final String tagline;
  final String serviceId;
}

class AiState {
  const AiState({
    this.hasPhoto = false,
    this.isAnalyzing = false,
    this.isUploading = false,
    this.note,
    this.photoUrl,
  });

  final bool hasPhoto;
  final bool isAnalyzing;
  final bool isUploading;
  final String? note;
  final String? photoUrl;

  AiState copyWith({
    bool? hasPhoto,
    bool? isAnalyzing,
    bool? isUploading,
    String? note,
    String? photoUrl,
  }) {
    return AiState(
      hasPhoto: hasPhoto ?? this.hasPhoto,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isUploading: isUploading ?? this.isUploading,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class AiController extends StateNotifier<AiState> {
  AiController(this._storage) : super(const AiState());

  final StorageService _storage;

  Future<void> uploadSelfie(File file) async {
    if (!FirebaseBootstrap.enableFirebase) {
      _simulateAnalysis();
      return;
    }

    state = state.copyWith(isUploading: true, note: 'Uploading selfie...');
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final url = await _storage.uploadSelfie(userId: userId, file: file);
      state = state.copyWith(isUploading: false, hasPhoto: true, photoUrl: url, note: 'Analyzing facial structure...');
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isAnalyzing: false, note: 'Oval face detected ? Soft layers recommended');
    } catch (_) {
      state = state.copyWith(isUploading: false, note: 'Upload failed. Please try again.');
    }
  }

  void _simulateAnalysis() {
    state = state.copyWith(hasPhoto: true, isAnalyzing: true, note: 'Analyzing facial structure...');
    Future.delayed(const Duration(milliseconds: 900), () {
      state = state.copyWith(isAnalyzing: false, note: 'Oval face detected ? Soft layers recommended');
    });
  }

  void reset() {
    state = const AiState();
  }
}

final aiControllerProvider = StateNotifierProvider<AiController, AiState>((ref) {
  return AiController(ref.read(storageServiceProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

final aiLooksProvider = Provider<List<AiLook>>((ref) {
  return [
    AiLook(
      name: 'Soft Butterfly Layers',
      tagline: 'Best for oval & heart faces',
      description: 'Creates volume around cheekbones with a feathered finish.',
      serviceId: 'cut',
    ),
    AiLook(
      name: 'Modern Blunt Bob',
      tagline: 'Sharp jawline enhancer',
      description: 'Clean lines that highlight the jawline and neck.',
      serviceId: 'style',
    ),
    AiLook(
      name: 'Warm Honey Balayage',
      tagline: 'Adds dimension and warmth',
      description: 'Soft, sunlit highlights for a natural glow.',
      serviceId: 'color',
    ),
  ];
});
