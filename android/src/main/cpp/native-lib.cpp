#include <jni.h>
#include <fluidsynth.h>
#include <unistd.h>
#include <map>

std::map<int, fluid_settings_t*>  settings;
std::map<int, fluid_synth_t*> synths = {};
std::map<int, fluid_audio_driver_t*> drivers = {};
std::map<int, int> soundfonts = {};
int nextSfId = 1;

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_stopAllNotes(JNIEnv* env, jclass clazz) {
    try {
        for (auto const& x : synths) {
            for (int i = 0; i < 16; i++) {
                fluid_synth_all_notes_off(x.second, i);
            }
        }
        return 0;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_setInt(JNIEnv* env, jclass clazz, jstring name, jint value, jint sfId) {
    try {
        const char *settingName = env->GetStringUTFChars(name, nullptr);
        int result = fluid_settings_setint(settings[sfId], settingName, value);
        synths[sfId] = new_fluid_synth(settings[sfId]);
        drivers[sfId] = new_fluid_audio_driver(settings[sfId], synths[sfId]);
        env->ReleaseStringUTFChars(name, settingName);
        return result;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_setStr(JNIEnv* env, jclass clazz, jstring name, jstring value, jint sfId) {
    try {
        const char *settingName = env->GetStringUTFChars(name, nullptr);
        const char *settingValue = env->GetStringUTFChars(value, nullptr);
        int result = fluid_settings_setstr(settings[sfId], settingName, settingValue);
        synths[sfId] = new_fluid_synth(settings[sfId]);
        drivers[sfId] = new_fluid_audio_driver(settings[sfId], synths[sfId]);
        env->ReleaseStringUTFChars(name, settingName);
        env->ReleaseStringUTFChars(value, settingValue);
        return result;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_setNum(JNIEnv* env, jclass clazz, jstring name, jdouble value, jint sfId) {
    try {
        const char *settingName = env->GetStringUTFChars(name, nullptr);
        int result = fluid_settings_setnum(settings[sfId], settingName, value);
        synths[sfId] = new_fluid_synth(settings[sfId]);
        drivers[sfId] = new_fluid_audio_driver(settings[sfId], synths[sfId]);
        env->ReleaseStringUTFChars(name, settingName);
        return result;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_getInt(JNIEnv* env, jclass clazz, jstring name, jint sfId) {
    try {
        const char *settingName = env->GetStringUTFChars(name, nullptr);
        int value;
        fluid_settings_getint(settings[sfId], settingName, &value);
        env->ReleaseStringUTFChars(name, settingName);
        return value;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jdouble JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_getNum(JNIEnv* env, jclass clazz, jstring name, jint sfId) {
    try {
        const char *settingName = env->GetStringUTFChars(name, nullptr);
        double value;
        fluid_settings_getnum(settings[sfId], settingName, &value);
        env->ReleaseStringUTFChars(name, settingName);
        return value;
    } catch (...) {
        return -1.0;
    }
}

extern "C" JNIEXPORT int JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_loadSoundfont(JNIEnv* env, jclass clazz, jstring path, jint bank, jint program) {
    try {
        const char *nativePath = env->GetStringUTFChars(path, nullptr);
        settings[nextSfId] = new_fluid_settings();
        fluid_settings_setnum(settings[nextSfId], "synth.gain", 1.0);
        fluid_settings_setstr(settings[nextSfId], "synth.threadsafe-api", "yes");
        fluid_settings_setstr(settings[nextSfId], "synth.lock-memory", "yes");
        synths[nextSfId] = new_fluid_synth(settings[nextSfId]);
        drivers[nextSfId] = new_fluid_audio_driver(settings[nextSfId], synths[nextSfId]);
        int sfId = fluid_synth_sfload(synths[nextSfId], nativePath, 0);
        for (int i = 0; i < 16; i++) {
            fluid_synth_program_select(synths[nextSfId], i, sfId, bank, program);
        }
        env->ReleaseStringUTFChars(path, nativePath);
        soundfonts[nextSfId] = sfId;
        nextSfId++;
        return nextSfId - 1;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_selectInstrument(JNIEnv* env, jclass clazz, jint sfId, jint channel, jint bank, jint program) {
    try {
        return fluid_synth_program_select(synths[sfId], channel, soundfonts[sfId], bank, program);
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_playNote(JNIEnv* env, jclass clazz, jint channel, jint key, jint velocity, jint sfId) {
    try {
        return fluid_synth_noteon(synths[sfId], channel, key, velocity);
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_stopNote(JNIEnv* env, jclass clazz, jint channel, jint key, jint sfId) {
    try {
        return fluid_synth_noteoff(synths[sfId], channel, key);
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_unloadSoundfont(JNIEnv* env, jclass clazz, jint sfId) {
    try {
        delete_fluid_audio_driver(drivers[sfId]);
        int result = fluid_synth_sfunload(synths[sfId], soundfonts[sfId], 1);
        delete_fluid_synth(synths[sfId]);
        synths.erase(sfId);
        drivers.erase(sfId);
        soundfonts.erase(sfId);
        return result;
    } catch (...) {
        return -1;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_melihhakanpektas_flutter_1midi_1pro_FlutterMidiProPlugin_dispose(JNIEnv* env, jclass clazz) {
    try {
        for (auto const& x : synths) {
            delete_fluid_audio_driver(drivers[x.first]);
            delete_fluid_synth(synths[x.first]);
            delete_fluid_settings(settings[x.first]);
        }
        synths.clear();
        drivers.clear();
        soundfonts.clear();
        return 0;
    } catch (...) {
        return -1;
    }
}