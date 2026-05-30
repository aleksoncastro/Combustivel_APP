import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

/// Nativo (Windows, Android, iOS, etc.):
/// Salva o PDF em arquivo temporário e entrega conforme a plataforma.
Future<void> entregarPdf(Uint8List bytes, String fileName) async {
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/$fileName');
  await file.writeAsBytes(bytes);

  if (Platform.isWindows) {
    // Windows: abre diretamente no leitor padrão (Edge, Adobe, etc.)
    await OpenFile.open(file.path);
  } else {
    // Mobile: abre o menu nativo de compartilhamento
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Relatório de Abastecimentos',
    );
  }
}
