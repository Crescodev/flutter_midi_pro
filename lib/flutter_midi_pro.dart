import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_midi_pro/flutter_midi_pro_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

/// The FlutterMidiPro class provides functions for writing to and loading soundfont
/// files, as well as playing and stopping MIDI notes.
///
class MidiPro {
  // Singleton instance
  static MidiPro? _instance;

  // Private constructor
  MidiPro._();

  // Factory constructor
  factory MidiPro() {
    _instance ??= MidiPro._();
    return _instance!;
  }

  // Soundfont ID'lerinin geçici dosya yollarını tutacak map
  final Map<int, String> _soundfontPaths = {};

  /// Sets a string value in the FluidSynth settings
  /// This method is only available on Android.
  /// For more information, see the FluidSynth documentation.
  Future<int> setStr(String name, String value) async {
    return FlutterMidiProPlatform.instance.setStr(name, value);
  }

  /// Sets an integer value in the FluidSynth settings
  Future<int> setInt(String name, int value) async {
    return FlutterMidiProPlatform.instance.setInt(name, value);
  }

  /// Sets a double value in the FluidSynth settings
  Future<int> setNum(String name, double value) async {
    return FlutterMidiProPlatform.instance.setNum(name, value);
  }

  /// Gets an integer value from the FluidSynth settings
  Future<int> getInt(String name) async {
    return FlutterMidiProPlatform.instance.getInt(name);
  }

  /// Gets a double value from the FluidSynth settings
  Future<double> getNum(String name) async {
    return FlutterMidiProPlatform.instance.getNum(name);
  }

  /// Loads a soundfont file from the specified asset path.
  /// Returns the sfId (SoundfontSamplerId).
  Future<int> loadSoundfontAsset(
      {required String assetPath, required int bank, required int program}) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    await tempFile.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    final sfId = await FlutterMidiProPlatform.instance.loadSoundfont(tempFile.path, bank, program);
    if (sfId == -1) {
      throw Exception('Failed to load soundfont');
    }
    return sfId;
  }

  /// Loads a soundfont file from the specified data.
  /// Returns the sfId (SoundfontSamplerId).
  Future<int> loadSoundfontData(
      {required Uint8List data, required int bank, required int program}) async {
    final tempDir = await getTemporaryDirectory();
    final randomTempFileName = 'soundfont_${DateTime.now().millisecondsSinceEpoch}.sf2';
    final tempFile = File('${tempDir.path}/$randomTempFileName');
    tempFile.writeAsBytesSync(data);

    final sfId = await FlutterMidiProPlatform.instance.loadSoundfont(tempFile.path, bank, program);
    _soundfontPaths[sfId] = tempFile.path; // Dosya yolunu kaydet
    if (sfId == -1) {
      throw Exception('Failed to load soundfont');
    }
    return sfId;
  }

  /// Loads a soundfont file from the specified path.
  /// Returns the sfId (SoundfontSamplerId).
  Future<int> loadSoundfontFile(
      {required String path, required int bank, required int program}) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${path.split('/').last}');
    await tempFile.copy(path);
    final sfId = await FlutterMidiProPlatform.instance.loadSoundfont(tempFile.path, bank, program);
    if (sfId == -1) {
      throw Exception('Failed to load soundfont');
    }
    return sfId;
  }

  /// Selects an instrument on the specified soundfont.
  /// The soundfont ID is the ID returned by the [loadSoundfont] method.
  /// The channel is a number from 1 to 16.
  /// The bank number is the bank number of the instrument on the soundfont.
  /// The program number is the program number of the instrument on the soundfont.
  /// This is the same as the patch number.
  /// If the soundfont does not have banks, set the bank number to 0.
  Future<int> selectInstrument({
    /// The soundfont ID. First soundfont loaded is 1.
    required int sfId,

    /// The program number of the instrument on the soundfont.
    /// This is the same as the patch number.
    required int program,

    /// The MIDI channel. This is a number from 0 to 15. Channel numbers start at 0.
    int channel = 0,

    /// The bank number of the instrument on the soundfont. If the soundfont does not
    /// have banks, set this to 0.
    int bank = 0,
  }) async {
    return FlutterMidiProPlatform.instance.selectInstrument(sfId, channel, bank, program);
  }

  /// Plays a note on the specified channel.
  /// The channel is a number from 0 to 15.
  /// The key is the MIDI note number. This is a number from 0 to 127.
  /// The velocity is the velocity of the note. This is a number from 0 to 127.
  /// A velocity of 127 is the maximum velocity.
  /// The note will continue to play until it is stopped.
  /// To stop the note, use the [stopNote] method.
  Future<int> playNote({
    /// The MIDI channel. This is a number from 0 to 15. Channel numbers start at 0.
    int channel = 0,

    /// The MIDI note number. This is a number from 0 to 127.
    required int key,

    /// The velocity of the note. This is a number from 0 to 127.
    required int velocity,

    /// The soundfont ID. First soundfont loaded is 1.
    required int sfId,
  }) async {
    return FlutterMidiProPlatform.instance.playNote(channel, key, velocity, sfId);
  }

  /// Stops a note on the specified channel.
  /// The channel is a number from 0 to 15.
  /// The key is the MIDI note number. This is a number from 0 to 127.
  /// The note will stop playing.
  /// To play the note again, use the [playNote] method.
  /// To stop all notes on a channel, use the [stopAllNotes] method.
  Future<int> stopNote({
    /// The MIDI channel. This is a number from 0 to 15. Channel numbers start at 0.
    int channel = 0,

    /// The MIDI note number. This is a number from 0 to 127.
    required int key,

    /// The soundfont ID. First soundfont loaded is 1.
    required int sfId,
  }) async {
    return FlutterMidiProPlatform.instance.stopNote(channel, key, sfId);
  }

  /// Unloads a soundfont from memory.
  /// The soundfont ID is the ID returned by the [loadSoundfont] method.
  /// If resetPresets is true, the presets will be reset to the default values.
  Future<int> unloadSoundfont(int sfId) async {
    final result = await FlutterMidiProPlatform.instance.unloadSoundfont(sfId);

    // Geçici dosyayı sil
    final tempPath = _soundfontPaths[sfId];
    if (tempPath != null) {
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      _soundfontPaths.remove(sfId);
    }

    return result;
  }

  /// Disposes of the FlutterMidiPro instance.
  /// This should be called when the instance is no longer needed.
  /// This will stop all notes and unload all soundfonts.
  /// This will also release all resources used by the instance.
  /// After disposing of the instance, the instance should not be used again.
  ///
  Future<void> dispose() async {
    // Tüm geçici dosyaları temizle
    for (var tempPath in _soundfontPaths.values) {
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
    _soundfontPaths.clear();

    return FlutterMidiProPlatform.instance.dispose();
  }
}
