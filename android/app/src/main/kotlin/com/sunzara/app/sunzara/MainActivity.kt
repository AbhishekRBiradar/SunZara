package com.sunzara.app.sunzara

import android.content.ContentUris
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import android.provider.MediaStore
import android.util.Size
import androidx.annotation.NonNull
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private val MEDIASTORE_CHANNEL = "com.sunzara.app/mediastore"
    private val EFFECTS_CHANNEL = "com.sunzara.app/audio_effects"

    private val audioEffectsHelper = AudioEffectsHelper()
    private val executor = Executors.newFixedThreadPool(4)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
    }

    override fun onDestroy() {
        audioEffectsHelper.release()
        super.onDestroy()
    }
}
