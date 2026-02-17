import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SalonUserApp extends ConsumerWidget {
  const SalonUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(languageProvider);
    return MaterialApp.router(
      title: 'Lushe Salon',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
