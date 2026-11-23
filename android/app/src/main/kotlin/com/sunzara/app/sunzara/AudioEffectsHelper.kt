package com.sunzara.app.sunzara

import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer

class AudioEffectsHelper {
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var currentSessionId: Int = 0

    fun initEffects(audioSessionId: Int): Map<String, Any?> {
        currentSessionId = audioSessionId
        release()

        val result = mutableMapOf<String, Any?>()

        try {
            // Priority 0, audioSessionId
            equalizer = Equalizer(0, audioSessionId)
            bassBoost = BassBoost(0, audioSessionId)

            val numBands = equalizer?.numberOfBands ?: 0
            val bandRange = equalizer?.bandLevelRange // [min, max] in millibels (typically -1500 to +1500)
            val minLevel = bandRange?.get(0)?.toInt() ?: -1500
            val maxLevel = bandRange?.get(1)?.toInt() ?: 1500

            val bands = mutableListOf<Map<String, Any?>>()
            for (i in 0 until numBands) {
                val centerFreq = equalizer?.getCenterFreq(i.toShort()) ?: 0 // in mHz
                val currentLevel = equalizer?.getBandLevel(i.toShort()) ?: 0
                bands.add(
                    mapOf(
                        "index" to i,
                        "centerFreqHz" to centerFreq / 1000,
                        "currentLevel" to currentLevel.toInt()
                    )
                )
            }

            // Presets
            val numPresets = equalizer?.numberOfPresets ?: 0
            val presets = mutableListOf<String>()
            for (i in 0 until numPresets) {
                val name = equalizer?.getPresetName(i.toShort()) ?: "Preset $i"
                presets.add(name)
            }

            result["supported"] = true
            result["numBands"] = numBands.toInt()
            result["minLevel"] = minLevel
            result["maxLevel"] = maxLevel
            result["bands"] = bands
            result["presets"] = presets
            result["bassBoostSupported"] = bassBoost?.strengthSupported ?: false
        } catch (e: Exception) {
            result["supported"] = false
            result["error"] = e.localizedMessage
        }

        return result
    }

    fun setEqualizerEnabled(enabled: Boolean) {
        try {
            equalizer?.enabled = enabled
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun setBandLevel(band: Int, level: Int) {
        try {
            equalizer?.setBandLevel(band.toShort(), level.toShort())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun usePreset(presetIndex: Int) {
        try {
            equalizer?.usePreset(presetIndex.toShort())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun setBassBoostStrength(strength: Int) {
        try {
            if (bassBoost?.strengthSupported == true) {
                bassBoost?.enabled = strength > 0
                bassBoost?.setStrength(strength.toShort()) // 0 to 1000
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun release() {
        try {
            equalizer?.release()
            bassBoost?.release()
        } catch (e: Exception) {
            // ignore
        }
        equalizer = null
        bassBoost = null
    }
}
