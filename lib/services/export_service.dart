import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import '../models/exercise.dart';

class ExportService {
  static Future<File> exportDataToPdf({
    required List<DateTime> days,
    required Map<DateTime, List<FoodEntry>> food,
    required Map<DateTime, List<Exercise>> exercise,
    required Map<DateTime, List<WaterEntry>> water,
    required Map<DateTime, Map<String, bool>> selfCheck,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    for (final day in days) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Date: ${dateFormat.format(day)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Food:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (food[day]?.isNotEmpty ?? false)
                  ...food[day]!.map(
                    (f) => pw.Text(
                      '${timeFormat.format(f.timestamp)} – ${f.name} – ${f.quantity} ${f.mealType}',
                    ),
                  )
                else
                  pw.Text('No food entries.'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Exercise:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (exercise[day]?.isNotEmpty ?? false)
                  ...exercise[day]!.map(
                    (e) =>
                        pw.Text('${e.name} – ${e.durationSeconds ~/ 60} min'),
                  )
                else
                  pw.Text('No exercise.'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Water:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (water[day]?.isNotEmpty ?? false)
                  pw.Text(
                    '~${water[day]!.fold<double>(0, (sum, w) => sum + w.volume) ~/ 1000} L',
                  )
                else
                  pw.Text('No water entries.'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Self-check:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (selfCheck[day] != null)
                  pw.Text(
                    'Protein target: ${selfCheck[day]!['proteinTarget'] == true ? 'Yes' : 'No'}\nTraining: ${selfCheck[day]!['training'] == true ? 'Yes' : 'No'}\nCheating: ${selfCheck[day]!['cheating'] == true ? 'Yes' : 'No'}',
                  )
                else
                  pw.Text('No self-check.'),
              ],
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/fitc_export_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
