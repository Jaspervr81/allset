import 'dart:convert';
import 'package:allset/models/app_settings_model.dart';
import 'package:allset/models/setlist_item_model.dart';
import 'package:allset/models/song_model.dart';
import 'package:allset/services/feature_flags.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:realm/realm.dart';

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// Share setlist as plain text via share sheet.
  Future<void> shareSetlistAsText(
    PlaylistModel playlist,
    List<SetlistItemModel> items,
  ) async {
    final buf = StringBuffer();
    buf.writeln(playlist.title.isNotEmpty ? playlist.title : 'Setlist');
    if (playlist.artist != null) buf.writeln(playlist.artist);
    if (playlist.date != null) {
      buf.writeln(
          '${playlist.date!.month}/${playlist.date!.day}/${playlist.date!.year}');
    }
    if (playlist.venue != null) buf.writeln(playlist.venue);
    buf.writeln('---');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.type == 'break') {
        buf.writeln('--- ${item.label ?? 'BREAK'} ---');
      } else if (item.type == 'note') {
        buf.writeln('  * ${item.label ?? ''}');
      } else if (item.song != null) {
        final s = item.song!;
        buf.write('${i + 1}. ${s.title}');
        if (s.key != null) buf.write('  [${s.key}]');
        if (s.bpm != null) buf.write('  ${s.bpm}bpm');
        buf.writeln();
      }
    }
    await Share.share(buf.toString());
  }

  /// Print / export setlist as PDF.
  Future<void> printSetlistPdf(
    PlaylistModel playlist,
    List<SetlistItemModel> items,
    AppSettingsModel settings,
  ) async {
    final doc = pw.Document();
    final isPro = FeatureFlags.instance.isPro;
    final format = isPro && settings.pdfPaperSize == 'a4'
        ? PdfPageFormat.a4
        : PdfPageFormat.letter;
    final alignment = isPro
        ? _pdfAlignment(settings.pdfAlignment)
        : pw.TextAlign.left;
    final showNumbers = isPro ? settings.pdfShowNumbers : true;

    doc.addPage(pw.Page(
      pageFormat: format,
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              playlist.title.isNotEmpty ? playlist.title : 'Setlist',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            if (playlist.artist != null)
              pw.Text(playlist.artist!,
                  style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),
            for (int i = 0; i < items.length; i++)
              _buildPdfItem(items[i], i + 1, showNumbers, alignment),
          ],
        );
      },
    ));

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  pw.Widget _buildPdfItem(
      SetlistItemModel item, int num, bool showNumbers, pw.TextAlign align) {
    if (item.type == 'break') {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Text('--- ${item.label ?? 'BREAK'} ---',
            style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic, fontSize: 11)),
      );
    }
    if (item.type == 'note') {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text('  * ${item.label ?? ''}',
            style: const pw.TextStyle(fontSize: 10)),
      );
    }
    final song = item.song;
    if (song == null) return pw.SizedBox();
    final prefix = showNumbers ? '$num. ' : '';
    final key = song.key != null ? '  [${song.key}]' : '';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text('$prefix${song.title}$key',
          textAlign: align,
          style: pw.TextStyle(
              fontSize: 13, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.TextAlign _pdfAlignment(String alignment) {
    switch (alignment) {
      case 'center':
        return pw.TextAlign.center;
      case 'right':
        return pw.TextAlign.right;
      default:
        return pw.TextAlign.left;
    }
  }

  /// Backup all songs + setlists to JSON and share.
  Future<void> exportBackupJson(Realm realm) async {
    final songs = realm.all<SongModel>().map((s) => {
          'id': s.id.toString(),
          'title': s.title,
          'key': s.key,
          'artist': s.artist,
          'bpm': s.bpm,
          'length': s.length,
          'notes': s.notes,
          'lyrics': s.lyrics,
          'composer': s.composer,
          'publisher': s.publisher,
        }).toList();

    final setlists = realm.all<PlaylistModel>().map((pl) => {
          'id': pl.id.toString(),
          'title': pl.title,
          'artist': pl.artist,
          'date': pl.date?.toIso8601String(),
          'venue': pl.venue,
          'city': pl.city,
        }).toList();

    final json = jsonEncode({'songs': songs, 'setlists': setlists});
    await Share.share(json, subject: 'AllSet Backup');
  }
}
