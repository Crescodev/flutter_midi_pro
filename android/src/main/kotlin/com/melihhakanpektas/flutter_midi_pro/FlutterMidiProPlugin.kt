package com.melihhakanpektas.flutter_midi_pro

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import android.media.AudioManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** FlutterMidiProPlugin */
class FlutterMidiProPlugin: FlutterPlugin, MethodCallHandler {
  companion object {
    init {
      System.loadLibrary("native-lib")
    }
    @JvmStatic
    private external fun stopAllNotes(): Int

    @JvmStatic
    private external fun setStr(name: String, value: String, sfId:Int): Int
    
    @JvmStatic
    private external fun setInt(name: String, value: Int, sfId:Int): Int
    
    @JvmStatic
    private external fun setNum(name: String, value: Double, sfId:Int): Int

    @JvmStatic
    private external fun getInt(name: String, sfId:Int): Int

    @JvmStatic
    private external fun getNum(name: String, sfId:Int): Double

    @JvmStatic
    private external fun loadSoundfont(path: String, bank: Int, program: Int): Int

    @JvmStatic
    private external fun selectInstrument(sfId: Int, channel:Int, bank: Int, program: Int): Int

    @JvmStatic
    private external fun playNote(channel: Int, key: Int, velocity: Int, sfId: Int): Int

    @JvmStatic
    private external fun stopNote(channel: Int, key: Int, sfId: Int): Int

    @JvmStatic
    private external fun unloadSoundfont(sfId: Int): Int
    @JvmStatic
    private external fun dispose(): Int
  }

  private lateinit var channel : MethodChannel
  private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
  private var isLoading = false

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_midi_pro")
    channel.setMethodCallHandler(this)
  }
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
        "stopAllNotes" -> {
            CoroutineScope(Dispatchers.IO).launch {
              val response = withContext(Dispatchers.Default) {
                stopAllNotes()
              }
              if (response >= 0) result.success(response)
              else result.error("FLUIDSYNTH_ERROR", "Failed to stop all notes", response)
            }
        }
      "setStr" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val name = call.argument<String>("name") as String
          val value = call.argument<String>("value") as String
            val sfId = call.argument<Int>("sfId")?:1
          val response = withContext(Dispatchers.Default) {
            setStr(name, value, sfId)
          }
          if (response >= 0) result.success(response)
          else result.error("FLUIDSYNTH_ERROR", "Failed to set string value", response)
        }
      }
      "setInt" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val name = call.argument<String>("name") as String
          val value = call.argument<Int>("value") as Int
          val sfId = call.argument<Int>("sfId")?:1
          val response = withContext(Dispatchers.Default) {
            setInt(name, value, sfId)
          }
          if (response >= 0) result.success(response)
          else result.error("FLUIDSYNTH_ERROR", "Failed to set int value", response)
        }
      }
      "setNum" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val name = call.argument<String>("name") as String
          val value = call.argument<Double>("value") as Double
          val sfId = call.argument<Int>("sfId")?:1
          val response = withContext(Dispatchers.Default) {
            setNum(name, value, sfId)
          }
          if (response >= 0) result.success(response)
          else result.error("FLUIDSYNTH_ERROR", "Failed to set num value", response)
        }
      }
      "getInt" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val name = call.argument<String>("name") as String
          val sfId = call.argument<Int>("sfId")?:1
          val value = withContext(Dispatchers.Default) {
            getInt(name, sfId)
          }
          result.success(value)
        }
      }
      "getNum" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val name = call.argument<String>("name") as String
          val sfId = call.argument<Int>("sfId")?:1
          val value = withContext(Dispatchers.Default) {
            getNum(name, sfId)
          }
          result.success(value)
        }
      }
      "loadSoundfont" -> {
        if (isLoading) {
          result.error("LOAD_IN_PROGRESS", "Another soundfont is currently loading", null)
          return
        }
        isLoading = true
        CoroutineScope(Dispatchers.IO).launch {
          val path = call.argument<String>("path") as String
          val bank = call.argument<Int>("bank") ?: 0
          val program = call.argument<Int>("program") ?: 0
          val audioManager = flutterPluginBinding.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
          val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
          audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
          val sfId = withContext(Dispatchers.Default) {
            loadSoundfont(path, bank, program)
          }
          Thread.sleep(500)
          audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, currentVolume, 0)
            isLoading = false
          if (sfId == -1) {
            result.error("INVALID_ARGUMENT", "Something went wrong. Check the path of the template soundfont", null)
          } else {
            result.success(sfId)
          }
        }
      }
      "selectInstrument" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val sfId = call.argument<Int>("sfId")?:1
          val channel = call.argument<Int>("channel")?:0
          val bank = call.argument<Int>("bank")?:0
          val program = call.argument<Int>("program")?:0
          val response = withContext(Dispatchers.Default) {
            selectInstrument(sfId, channel, bank, program)
          }
          if (response >= 0) result.success(response) 
          else result.error("FLUIDSYNTH_ERROR", "Failed to select instrument", response)
        }
      }
      "playNote" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val channel = call.argument<Int>("channel")
          val key = call.argument<Int>("key")
          val velocity = call.argument<Int>("velocity")
          val sfId = call.argument<Int>("sfId")
          if (channel != null && key != null && velocity != null && sfId != null) {
            val response = withContext(Dispatchers.Default) {
              playNote(channel, key, velocity, sfId)
            }
            if (response >= 0) result.success(response) 
            else result.error("FLUIDSYNTH_ERROR", "Failed to play note", response)
          } else {
            result.error("INVALID_ARGUMENT", "channel, key, and velocity are required", null)
          }
        }
      }
      "stopNote" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val channel = call.argument<Int>("channel")
          val key = call.argument<Int>("key")
          val sfId = call.argument<Int>("sfId")
          if (channel != null && key != null && sfId != null) {
            val response = withContext(Dispatchers.Default) {
              stopNote(channel, key, sfId)
            }
            if (response >= 0) result.success(response) 
            else result.error("FLUIDSYNTH_ERROR", "Failed to stop note", response)
          } else {
            result.error("INVALID_ARGUMENT", "channel and key are required", null)
          }
        }
      }
      "unloadSoundfont" -> {
        CoroutineScope(Dispatchers.IO).launch {
          val sfId = call.argument<Int>("sfId")
          if (sfId != null) {
            val response = withContext(Dispatchers.Default) {
              unloadSoundfont(sfId)
            }
            if (response >= 0) result.success(response) 
            else result.error("FLUIDSYNTH_ERROR", "Failed to unload soundfont", response)
          } else {
            result.error("INVALID_ARGUMENT", "sfId is required", null)
          }
        }
      }
      "dispose" -> {
        CoroutineScope(Dispatchers.IO).launch {

          val response = withContext(Dispatchers.Default) {
            dispose()
          }
            if (response >= 0) result.success(response)
            else result.error("FLUIDSYNTH_ERROR", "Failed to dispose", response)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}