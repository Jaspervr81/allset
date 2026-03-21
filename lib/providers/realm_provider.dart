import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:allset/models/models.dart';

final realmProvider = Provider<Realm>((ref) {
  final config = Configuration.local(
    [
      SongModel.schema,
      PlaylistModel.schema,
      SetlistItemModel.schema,
      FolderModel.schema,
      ProProfileModel.schema,
      AppSettingsModel.schema,
    ],
    schemaVersion: 3,
    migrationCallback: (migration, oldVersion) {
      if (oldVersion < 2) {
        migration.renameProperty('PlaylistModel', 'name', 'title');
      }
      // v3 adds folderId to SongModel and PlaylistModel — no data migration needed
    },
  );
  final realm = Realm(config);
  ref.onDispose(realm.close);
  return realm;
});
