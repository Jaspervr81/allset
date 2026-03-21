import 'package:allset/models/models.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/realm_provider.dart';
import 'package:allset/providers/setlist_providers.dart';
import 'package:allset/services/feature_flags.dart';
import 'package:allset/services/pro_export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

class ProProfilesScreen extends ConsumerStatefulWidget {
  const ProProfilesScreen({super.key});

  @override
  ConsumerState<ProProfilesScreen> createState() => _ProProfilesScreenState();
}

class _ProProfilesScreenState extends ConsumerState<ProProfilesScreen> {
  final _nameCtrl = TextEditingController();
  final _composerCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _proOrgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _composerCtrl.dispose();
    _publisherCtrl.dispose();
    _proOrgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlags.instance.proMode) {
      return const Scaffold(
        body: Center(child: Text('Pro feature not available')),
      );
    }

    final darkMode = ref.watch(darkModeProvider);
    final realm = ref.read(realmProvider);
    final profiles = realm.all<ProProfileModel>().toList();
    final bgColor = darkMode ? Colors.black : Colors.white;
    final fontColor = darkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Text('PRO Profiles',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: fontColor)),
                    IconButton(
                      icon: const Icon(Icons.table_chart_outlined),
                      tooltip: 'Export royalty CSV',
                      onPressed: () {
                        final notifier =
                            ref.read(currentSetlistProvider.notifier);
                        final playlist = notifier.playlist;
                        if (playlist == null) return;
                        ProExportService.instance
                            .exportRoyaltyCsv(playlist, notifier.items);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Profile Name',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _composerCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Composer',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _publisherCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Publisher',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _proOrgCtrl,
                            decoration: const InputDecoration(
                                labelText: 'PRO Org (ASCAP/BMI/etc)',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _saveProfile(realm),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (_, i) {
                    final p = profiles[i];
                    return ListTile(
                      title: Text(p.name,
                          style: TextStyle(color: fontColor)),
                      subtitle: Text(
                          [p.composer, p.publisher, p.proOrg]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(' · '),
                          style: TextStyle(
                              color: fontColor.withValues(alpha: 0.6))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () {
                          realm.write(() => realm.delete(p));
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile(Realm realm) {
    if (_nameCtrl.text.isEmpty) return;
    final profile = ProProfileModel(Uuid.v4(), _nameCtrl.text,
        composer:
            _composerCtrl.text.isNotEmpty ? _composerCtrl.text : null,
        publisher:
            _publisherCtrl.text.isNotEmpty ? _publisherCtrl.text : null,
        proOrg: _proOrgCtrl.text.isNotEmpty ? _proOrgCtrl.text : null);
    realm.write(() => realm.add(profile));
    _nameCtrl.clear();
    _composerCtrl.clear();
    _publisherCtrl.clear();
    _proOrgCtrl.clear();
    setState(() {});
  }
}
