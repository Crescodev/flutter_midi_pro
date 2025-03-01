import Flutter
import CoreMIDI
import AVFAudio
import AVFoundation
import CoreAudio

public class FlutterMidiProPlugin: NSObject, FlutterPlugin {
  var audioEngine = AVAudioEngine()
  var soundfontIndex = 1
  var sampler = AVAudioUnitSampler()
  var soundfontURLs: [Int: URL] = [:]
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_midi_pro", binaryMessenger: registrar.messenger())
    let instance = FlutterMidiProPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadSoundfont":
        let args = call.arguments as! [String: Any]
        let path = args["path"] as! String
        let url = URL(fileURLWithPath: path)
        
        audioEngine.attach(sampler)
        audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format:nil)
        
        do {
            try audioEngine.start()
        } catch {
            result(-1)
            return
        }
            do {
                try sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: 0)
            } catch {
                result(-1)
                return
            }
        
        soundfontURLs[soundfontIndex] = url
        soundfontIndex += 1
        result(soundfontIndex-1)
        
    case "selectInstrument":
        let args = call.arguments as! [String: Any]
        let sfId = args["sfId"] as! Int
        let program = args["program"] as! Int
        
        guard let soundfontUrl = soundfontURLs[sfId] else {
            result(-1)
            return
        }
        
        do {
            try sampler.loadSoundBankInstrument(at: soundfontUrl, program: UInt8(program), bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: 0)
        } catch {
            result(-1)
            return
        }
        
        sampler.sendProgramChange(UInt8(program), bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: 0, onChannel: 0)
        result(0)
        
    case "playNote":
        do {
            let args = call.arguments as! [String: Any]
            let note = args["key"] as! Int
            let velocity = args["velocity"] as! Int
            
            sampler.startNote(UInt8(note), withVelocity: UInt8(velocity), onChannel: 0)
            result(0)
        } catch {
            result(-1)
        }
        
    case "stopNote":
        do {
            let args = call.arguments as! [String: Any]
            let note = args["key"] as! Int
            
            sampler.stopNote(UInt8(note), onChannel: 0)
            result(0)
        } catch {
            result(-1)
        }
        
    case "unloadSoundfont":
        do {
            let args = call.arguments as! [String:Any]
            let sfId = args["sfId"] as! Int
            
            audioEngine.stop()
            soundfontURLs.removeValue(forKey: sfId)
            result(0)
        } catch {
            result(-1)
        }
        
    case "dispose":
        do {
            audioEngine.stop()
            soundfontURLs = [:]
            result(0)
        } catch {
            result(-1)
        }
        
    default:
        result(-1)
    }
  }
}
