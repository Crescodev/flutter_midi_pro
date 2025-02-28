import 'package:flutter_midi_pro/flutter_midi_pro_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterMidiProPlatform extends PlatformInterface {
  FlutterMidiProPlatform() : super(token: _token);
  static final Object _token = Object();
  static FlutterMidiProPlatform _instance = MethodChannelFlutterMidiPro();
  static FlutterMidiProPlatform get instance => _instance;

  static set instance(FlutterMidiProPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<int> loadSoundfont(String path, int bank, int program) {
    throw UnimplementedError('loadSoundfont() has not been implemented.');
  }

  Future<int> selectInstrument(int sfId, int channel, int bank, int program) {
    throw UnimplementedError('selectInstrument() has not been implemented.');
  }

  Future<int> playNote(int channel, int key, int velocity, int sfId) {
    throw UnimplementedError('playNote() has not been implemented.');
  }

  Future<int> stopNote(int channel, int key, int sfId) {
    throw UnimplementedError('stopNote() has not been implemented.');
  }

  Future<int> unloadSoundfont(int sfId) {
    throw UnimplementedError('unloadSoundfont() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<int> setStr(String name, String value) {
    throw UnimplementedError('setStr() has not been implemented.');
  }

  Future<int> setInt(String name, int value) {
    throw UnimplementedError('setInt() has not been implemented.');
  }

  Future<int> setNum(String name, double value) {
    throw UnimplementedError('setNum() has not been implemented.');
  }

  Future<int> getInt(String name) {
    throw UnimplementedError('getInt() has not been implemented.');
  }

  Future<double> getNum(String name) {
    throw UnimplementedError('getNum() has not been implemented.');
  }
}
