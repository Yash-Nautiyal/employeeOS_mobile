import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// Converts between job description storage (HTML for web + DB) and Flutter Quill [Document].
///
/// - **Read:** Tries Quill Delta JSON (legacy app saves), then HTML (React/web), then plain text.
/// - **Write:** Always emits HTML so the web editor can load the same column.
class QuillDescriptionCodec {
  QuillDescriptionCodec._();

  static bool _looksLikeHtml(String value) {
    final s = value.trimLeft();
    return s.startsWith('<') && s.contains('>');
  }

  /// Builds a [Document] for [QuillController] from stored [raw] (HTML, Delta JSON, or text).
  static Document decodeToDocument(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return Document();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return Document.fromJson(decoded);
      }
    } catch (_) {
      // Not Delta JSON.
    }

    if (_looksLikeHtml(raw)) {
      try {
        final delta = HtmlToDelta().convert(raw);
        return Document.fromDelta(delta);
      } catch (_) {
        // Fall through to plain text.
      }
    }

    return Document.fromDelta(Delta()..insert('$raw\n'));
  }

  /// Serializes the editor document to HTML for [jobs.description] (and web React Quill).
  static String encodeDocumentToHtml(Document doc) {
    final ops = doc.toDelta().toJson() as List<dynamic>;
    final list = ops.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return QuillDeltaToHtmlConverter(list).convert();
  }
}
