import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:allset/models/models.dart';
import 'package:allset/providers/realm_provider.dart';

class AppSettingsNotifier extends StateNotifier<AppSettingsModel> {
  final Realm _realm;

  AppSettingsNotifier(this._realm) : super(_loadOrCreate(_realm));

  static AppSettingsModel _loadOrCreate(Realm realm) {
    final all = realm.all<AppSettingsModel>();
    if (all.isEmpty) {
      final s = AppSettingsModel(Uuid.v4());
      realm.write(() => realm.add(s));
      return s;
    }
    return all.first;
  }

  void update(void Function(AppSettingsModel) fn) {
    _realm.write(() => fn(state));
    state = state;
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsModel>((ref) {
  final realm = ref.watch(realmProvider);
  return AppSettingsNotifier(realm);
});
