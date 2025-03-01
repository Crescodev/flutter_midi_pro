import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_midi_pro/flutter_midi_pro_platform_interface.dart';

/// An implementation of [FlutterMidiProPlatform] that uses method channels.
class MethodChannelFlutterMidiPro extends FlutterMidiProPlatform {
  static const MethodChannel _channel = MethodChannel('flutter_midi_pro');

  @override
  Future<int> setStr(String name, String value) async {
    return await _channel.invokeMethod('setStr', {'name': name, 'value': value});
  }

  @override
  Future<int> setInt(String name, int value) async {
    return await _channel.invokeMethod('setInt', {'name': name, 'value': value});
  }

  @override
  Future<int> setNum(String name, double value) async {
    return await _channel.invokeMethod('setNum', {'name': name, 'value': value});
  }

  @override
  Future<int> getInt(String name) async {
    return await _channel.invokeMethod('getInt', {'name': name});
  }

  @override
  Future<double> getNum(String name) async {
    return await _channel.invokeMethod('getNum', {'name': name});
  }

  @override
  Future<int> loadSoundfont(String path) async {
    return await _channel.invokeMethod('loadSoundfont', {'path': path});
  }

  @override
  Future<int> selectInstrument(int sfId, int program) async {
    return await _channel.invokeMethod('selectInstrument', {'sfId': sfId, 'program': program});
  }

  @override
  Future<int> playNote(int key, int velocity, int sfId) async {
    return await _channel
        .invokeMethod('playNote', {'key': key, 'velocity': velocity, 'sfId': sfId});
  }

  @override
  Future<int> stopNote(int key, int sfId) async {
    return await _channel.invokeMethod('stopNote', {'key': key, 'sfId': sfId});
  }

  @override
  Future<int> unloadSoundfont(int sfId) async {
    return await _channel.invokeMethod('unloadSoundfont', {'sfId': sfId});
  }

  @override
  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }
}
