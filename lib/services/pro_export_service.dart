import 'package:allset/models/models.dart';
import 'package:allset/services/feature_flags.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ProExportService {
  ProExportService._();
  static final ProExportService instance = ProExportService._();

  /// Export a CSV of all songs in the setlist with composer/publisher/PRO info.
  Future<void> exportRoyaltyCsv(
    PlaylistModel playlist,
    List<SetlistItemModel> items,
  ) async {
    if (!FeatureFlags.instance.proMode) return;

    final rows = <List<dynamic>>[
      ['#', 'Title', 'Key', 'BPM', 'Composer', 'Publisher', 'PRO Info'],
    ];

    int num = 1;
    for (final item in items) {
      if (item.type != 'song') continue;
      final s = item.song;
      if (s == null) continue;
      rows.add([
        num++,
        s.title,
        s.key ?? '',
        s.bpm?.toString() ?? '',
        s.composer ?? '',
        s.publisher ?? '',
        s.proInfo ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final setlistName = playlist.title.isNotEmpty ? playlist.title : 'setlist';
    await Share.share(csv, subject: '$setlistName — Royalty Report.csv');
  }
}
