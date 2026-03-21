import 'package:allset/pro/pro_profiles_screen.dart';
import 'package:allset/providers/app_settings_provider.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/services/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final bgColor = darkMode ? Colors.black : Colors.white;
    final fontColor = darkMode ? Colors.white : Colors.black;
    final isPro = FeatureFlags.instance.isPro;

    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Text('Settings',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: fontColor)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Dark mode
                    SwitchListTile(
                      title: Text('Dark Mode',
                          style: TextStyle(color: fontColor)),
                      value: darkMode,
                      onChanged: (_) =>
                          ref.read(darkModeProvider.notifier).toggle(),
                    ),

                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text('Date & Time',
                          style: TextStyle(
                              color: fontColor.withValues(alpha: 0.5),
                              fontSize: 12)),
                    ),

                    // Date format
                    SwitchListTile(
                      title: Text('Use D/M/Y date format',
                          style: TextStyle(color: fontColor)),
                      subtitle: Text(
                          settings.dateFormatDMY ? 'D/M/Y' : 'M/D/Y',
                          style: TextStyle(
                              color: fontColor.withValues(alpha: 0.6))),
                      value: settings.dateFormatDMY,
                      onChanged: (v) =>
                          notifier.update((s) => s.dateFormatDMY = v),
                    ),

                    // 24h clock
                    SwitchListTile(
                      title: Text('24-hour clock',
                          style: TextStyle(color: fontColor)),
                      value: settings.clock24h,
                      onChanged: (v) =>
                          notifier.update((s) => s.clock24h = v),
                    ),

                    // PDF options (Pro)
                    if (isPro) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text('PRO Profiles',
                            style: TextStyle(color: fontColor)),
                        subtitle: Text('Composer / Publisher / PRO',
                            style: TextStyle(
                                color: fontColor.withValues(alpha: 0.6))),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProProfilesScreen())),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text('PDF Export (Pro)',
                            style: TextStyle(
                                color: fontColor.withValues(alpha: 0.5),
                                fontSize: 12)),
                      ),
                      ListTile(
                        title: Text('Paper size',
                            style: TextStyle(color: fontColor)),
                        trailing: DropdownButton<String>(
                          value: settings.pdfPaperSize,
                          dropdownColor: bgColor,
                          style: TextStyle(color: fontColor),
                          items: const [
                            DropdownMenuItem(
                                value: 'letter', child: Text('Letter')),
                            DropdownMenuItem(
                                value: 'a4', child: Text('A4')),
                          ],
                          onChanged: (v) => notifier
                              .update((s) => s.pdfPaperSize = v ?? 'letter'),
                        ),
                      ),
                      SwitchListTile(
                        title: Text('Show song numbers',
                            style: TextStyle(color: fontColor)),
                        value: settings.pdfShowNumbers,
                        onChanged: (v) =>
                            notifier.update((s) => s.pdfShowNumbers = v),
                      ),
                      ListTile(
                        title: Text('Text alignment',
                            style: TextStyle(color: fontColor)),
                        trailing: DropdownButton<String>(
                          value: settings.pdfAlignment,
                          dropdownColor: bgColor,
                          style: TextStyle(color: fontColor),
                          items: const [
                            DropdownMenuItem(
                                value: 'left', child: Text('Left')),
                            DropdownMenuItem(
                                value: 'center', child: Text('Center')),
                            DropdownMenuItem(
                                value: 'right', child: Text('Right')),
                          ],
                          onChanged: (v) => notifier
                              .update((s) => s.pdfAlignment = v ?? 'left'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
