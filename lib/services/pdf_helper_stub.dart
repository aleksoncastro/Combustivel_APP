import 'dart:typed_data';

/// Stub – nunca é executado diretamente.
/// O compilador escolhe [pdf_helper_web.dart] ou [pdf_helper_native.dart]
/// conforme a plataforma alvo.
Future<void> entregarPdf(Uint8List bytes, String fileName) async {
  throw UnsupportedError('Plataforma não suportada para exportação de PDF.');
}
