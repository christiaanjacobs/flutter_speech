// Copyright (c)  2024  Xiaomi Corporation
// import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import "dart:io";
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

// Copy the asset file from src to dst
Future<String> copyAssetFile(String src, [String? dst]) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  if (dst == null) {
    dst = basename(src);
  }
  final target = join(directory.path, dst);
  bool exists = await new File(target).exists();

  final data = await rootBundle.load(src);

  if (!exists || File(target).lengthSync() != data.lengthInBytes) {
    final List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(target).writeAsBytes(bytes);
  }

  return target;
}

Float32List convertBytesToFloat32(Uint8List bytes, [endian = Endian.little]) {
  final values = Float32List(bytes.length ~/ 2);

  final data = ByteData.view(bytes.buffer);

  for (var i = 0; i < bytes.length; i += 2) {
    int short = data.getInt16(i, endian);
    values[i ~/ 2] = short / 32678.0;
  }

  return values;
}

// class AudioConverter {

//   Future<String> convertPcmToWav(String pcmFilePath) async {
//     // Get the directory to save the converted file
//     final directory = await getApplicationDocumentsDirectory();
//     String wavFilePath = '${directory.path}/converted_audio.wav';

//     // FFmpeg command to convert PCM to WAV
//     String command = '-f s16le -ar 16000 -ac 1 -i $pcmFilePath $wavFilePath';

//     // Execute the command
//     final session = await FFmpegKit.execute(command);
//     final returnCode = await session.getReturnCode();

//     if (ReturnCode.isSuccess(returnCode)) {
//       return wavFilePath; // Successful conversion
//     } else if (ReturnCode.isCancel(returnCode)) {
//       throw Exception('Conversion canceled');
//     } else {
//       throw Exception('Error converting PCM to WAV');
//     }
//   }
// }

class FixedSizeListOfUint8List {
  final List<Uint8List> _items;
  final int _maxSize;

  FixedSizeListOfUint8List(this._maxSize) : _items = [];

  void add(Uint8List item) {
    if (_items.length >= _maxSize) {
      _items.removeAt(0); // Remove the oldest list
    }
    _items.add(item); // Add the new Uint8List
  }

  void clear() {
    _items.clear(); // Clear all items
  }

  List<Uint8List> get items =>
      List.unmodifiable(_items); // Return a read-only copy

  @override
  String toString() {
    return _items.map((list) => list.toString()).toList().toString();
  }
}
