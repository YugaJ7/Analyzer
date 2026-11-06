import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Holds the files handed to the share sheet. They contain the user's full
/// habit history, so the folder is emptied before every export and on
/// sign-out. Files can't be deleted right after sharing: receiving apps
/// (e.g. Gmail) read them after the share sheet closes.
abstract final class ExportFileStore {
  @visibleForTesting
  static Future<Directory> Function() baseDirectory = getTemporaryDirectory;

  static Future<Directory> _dir() async =>
      Directory('${(await baseDirectory()).path}/exports');

  /// Replaces any previous export with [name], written as [text] or [bytes].
  static Future<File> write(
    String name, {
    String? text,
    List<int>? bytes,
  }) async {
    assert((text == null) != (bytes == null), 'Pass exactly one of text/bytes');
    await clear();
    final dir = await (await _dir()).create(recursive: true);
    final file = File('${dir.path}/$name');
    return text != null ? file.writeAsString(text) : file.writeAsBytes(bytes!);
  }

  static Future<void> clear() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
