package com.sunzara.app.sunzara

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ContentUris
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Size
import androidx.annotation.NonNull
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.Locale
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private val MEDIASTORE_CHANNEL = "com.sunzara.app/mediastore"
    private val EFFECTS_CHANNEL = "com.sunzara.app/audio_effects"
    private val VOICE_SEARCH_CHANNEL = "com.sunzara.app/voice_search"
    private val VOICE_EVENTS_CHANNEL = "com.sunzara.app/voice_search_events"
    private val APP_INFO_CHANNEL = "com.sunzara.app/app_info"
    private val VOICE_SEARCH_REQUEST_CODE = 9001

    private val audioEffectsHelper = AudioEffectsHelper()
    private val executor = Executors.newFixedThreadPool(4)
    private var pendingVoiceResult: MethodChannel.Result? = null
    private var speechRecognizer: SpeechRecognizer? = null
    private var voiceEventSink: EventChannel.EventSink? = null
    private var isStoppingVoice = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Package / App Version Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_INFO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPackageVersion" -> {
                    try {
                        val pkgInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            packageManager.getPackageInfo(
                                packageName,
                                PackageManager.PackageInfoFlags.of(0)
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            packageManager.getPackageInfo(packageName, 0)
                        }
                        result.success(
                            mapOf(
                                "versionName" to (pkgInfo.versionName ?: "1.1.0"),
                                "versionCode" to pkgInfo.longVersionCode
                            )
                        )
                    } catch (e: Exception) {
                        result.error("VERSION_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // MediaStore & Artwork Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIASTORE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "queryAudio" -> {
                    executor.execute {
                        try {
                            val audioFiles = MediaStoreHelper.queryAudioFiles(applicationContext)
                            runOnUiThread {
                                result.success(audioFiles)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("QUERY_ERROR", e.localizedMessage, null)
                            }
                        }
                    }
                }
                "getArtwork" -> {
                    val songId = call.argument<String>("id") ?: ""
                    val filePath = call.argument<String>("filePath") ?: ""
                    val size = call.argument<Int>("size") ?: 256

                    executor.execute {
                        var bytes: ByteArray? = null

                        // 1. Try ContentResolver.loadThumbnail on Android Q+ (API 29+)
                        val idLong = songId.toLongOrNull()
                        if (idLong != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            try {
                                val uri = ContentUris.withAppendedId(
                                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                                    idLong
                                )
                                val bitmap = applicationContext.contentResolver.loadThumbnail(
                                    uri,
                                    Size(size, size),
                                    null
                                )
                                val stream = ByteArrayOutputStream()
                                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, stream)
                                bytes = stream.toByteArray()
                            } catch (e: Exception) {
                                // Ignore and fall back to file metadata
                            }
                        }

                        // 2. Fallback: Extract embedded APIC album art directly from audio file
                        if (bytes == null && filePath.isNotEmpty()) {
                            try {
                                val file = File(filePath)
                                if (file.exists() && file.canRead()) {
                                    val retriever = MediaMetadataRetriever()
                                    retriever.setDataSource(filePath)
                                    val art = retriever.embeddedPicture
                                    retriever.release()
                                    if (art != null && art.isNotEmpty()) {
                                        bytes = art
                                    }
                                }
                            } catch (e: Exception) {
                                // Ignore
                            }
                        }

                        val finalBytes = bytes
                        runOnUiThread {
                            result.success(finalBytes)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Audio Effects (Equalizer & BassBoost) Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EFFECTS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initEffects" -> {
                    val sessionId = call.argument<Int>("audioSessionId") ?: 0
                    val info = audioEffectsHelper.initEffects(sessionId)
                    result.success(info)
                }
                "setEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    audioEffectsHelper.setEqualizerEnabled(enabled)
                    result.success(true)
                }
                "setBandLevel" -> {
                    val band = call.argument<Int>("band") ?: 0
                    val level = call.argument<Int>("level") ?: 0
                    audioEffectsHelper.setBandLevel(band, level)
                    result.success(true)
                }
                "usePreset" -> {
                    val presetIndex = call.argument<Int>("presetIndex") ?: 0
                    audioEffectsHelper.usePreset(presetIndex)
                    result.success(true)
                }
                "setBassBoost" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    audioEffectsHelper.setBassBoostStrength(strength)
                    result.success(true)
                }
                "release" -> {
                    audioEffectsHelper.release()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Stream live voice recognition telemetry & partial transcripts for in-app UI
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_EVENTS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    voiceEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    voiceEventSink = null
                }
            }
        )

        // Native Voice Search Channel (headless SpeechRecognizer + Intent fallback)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_SEARCH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isInAppVoiceAvailable" -> {
                    result.success(SpeechRecognizer.isRecognitionAvailable(this))
                }
                "startInAppVoice" -> {
                    if (!SpeechRecognizer.isRecognitionAvailable(this)) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    runOnUiThread {
                        destroySpeechRecognizer()
                        isStoppingVoice = false
                        val promptIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                            putExtra(
                                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
                            )
                            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault().toLanguageTag())
                            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
                        }
                        try {
                            val recognizer = SpeechRecognizer.createSpeechRecognizer(applicationContext)
                            recognizer.setRecognitionListener(object : RecognitionListener {
                                override fun onReadyForSpeech(params: Bundle?) {
                                    emitVoiceEvent(mapOf("type" to "ready"))
                                }

                                override fun onBeginningOfSpeech() {}

                                override fun onRmsChanged(rmsdB: Float) {
                                    emitVoiceEvent(mapOf("type" to "rms", "rms" to rmsdB.toDouble()))
                                }

                                override fun onBufferReceived(buffer: ByteArray?) {}

                                override fun onEndOfSpeech() {}

                                override fun onError(error: Int) {
                                    if (!isStoppingVoice) {
                                        emitVoiceEvent(mapOf("type" to "error", "code" to error))
                                    }
                                }

                                override fun onResults(results: Bundle?) {
                                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                                    val best = matches?.firstOrNull()?.trim() ?: ""
                                    emitVoiceEvent(mapOf("type" to "result", "text" to best))
                                }

                                override fun onPartialResults(partialResults: Bundle?) {
                                    val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                                    val txt = matches?.firstOrNull()?.trim() ?: ""
                                    if (txt.isNotEmpty()) {
                                        emitVoiceEvent(mapOf("type" to "partial", "text" to txt))
                                    }
                                }

                                override fun onEvent(eventType: Int, params: Bundle?) {}
                            })
                            speechRecognizer = recognizer
                            recognizer.startListening(promptIntent)
                            result.success(true)
                        } catch (e: Exception) {
                            destroySpeechRecognizer()
                            result.success(false)
                        }
                    }
                }
                "stopInAppVoice" -> {
                    runOnUiThread {
                        isStoppingVoice = true
                        destroySpeechRecognizer()
                    }
                    result.success(true)
                }
                "startVoiceSearch" -> {
                    pendingVoiceResult?.success(null)
                    pendingVoiceResult = result

                    val prompt = call.argument<String>("prompt") ?: "Say a song or artist name"
                    val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                        putExtra(
                            RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                            RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
                        )
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault().toLanguageTag())
                        putExtra(RecognizerIntent.EXTRA_PROMPT, prompt)
                        putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
                    }

                    try {
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivityForResult(intent, VOICE_SEARCH_REQUEST_CODE)
                        } else {
                            pendingVoiceResult = null
                            result.error("UNAVAILABLE", "No speech recognizer available", null)
                        }
                    } catch (e: ActivityNotFoundException) {
                        pendingVoiceResult = null
                        result.error("UNAVAILABLE", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun emitVoiceEvent(payload: Map<String, Any>) {
        runOnUiThread {
            voiceEventSink?.success(payload)
        }
    }

    private fun destroySpeechRecognizer() {
        try {
            speechRecognizer?.cancel()
            speechRecognizer?.destroy()
        } catch (_: Exception) {
        }
        speechRecognizer = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VOICE_SEARCH_REQUEST_CODE) {
            val callback = pendingVoiceResult
            pendingVoiceResult = null
            if (resultCode == Activity.RESULT_OK && data != null) {
                val matches = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
                callback?.success(matches?.firstOrNull()?.trim())
            } else {
                callback?.success(null)
            }
        }
    }

    override fun onDestroy() {
        isStoppingVoice = true
        destroySpeechRecognizer()
        pendingVoiceResult?.success(null)
        pendingVoiceResult = null
        audioEffectsHelper.release()
        super.onDestroy()
    }
}
