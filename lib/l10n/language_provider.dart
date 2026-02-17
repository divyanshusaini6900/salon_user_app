import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final languageProvider = StateProvider<Locale>((ref) => const Locale('en'));
