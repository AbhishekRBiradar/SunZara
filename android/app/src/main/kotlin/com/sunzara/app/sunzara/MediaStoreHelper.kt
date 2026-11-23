package com.sunzara.app.sunzara

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import java.io.File

object MediaStoreHelper {
    private const val TAG = "SunZara_MediaStore"

    fun queryAudioFiles(context: Context): List<Map<String, Any?>> {
        val songList = mutableListOf<Map<String, Any?>>()
        val contentResolver = context.contentResolver

        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        }

        val projection = mutableListOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.DATE_MODIFIED,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.IS_MUSIC
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            projection.add(MediaStore.Audio.Media.ALBUM_ARTIST)
        }

        // Safe sort order
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        fun readCursor(cursor: android.database.Cursor) {
            val idCol = cursor.getColumnIndex(MediaStore.Audio.Media._ID)
            val titleCol = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
            val artistCol = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
            val albumCol = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM)
            val durationCol = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION)
            val sizeCol = cursor.getColumnIndex(MediaStore.Audio.Media.SIZE)
            val dataCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)
            val dateAddedCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATE_ADDED)
            val dateModifiedCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATE_MODIFIED)
            val trackCol = cursor.getColumnIndex(MediaStore.Audio.Media.TRACK)
            val yearCol = cursor.getColumnIndex(MediaStore.Audio.Media.YEAR)
            val albumIdCol = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)
            val isMusicCol = cursor.getColumnIndex(MediaStore.Audio.Media.IS_MUSIC)
            val albumArtistCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ARTIST)
            } else -1

            while (cursor.moveToNext()) {
                val id = if (idCol >= 0) cursor.getLong(idCol) else System.currentTimeMillis()
                val rawData = if (dataCol >= 0) cursor.getString(dataCol) ?: "" else ""
                
                // Content URI fallback if direct data path is restricted
                val data = if (rawData.isNotEmpty()) {
                    rawData
                } else {
                    ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id).toString()
                }

                // Skip non-audio files or zero-length corrupted records
                val duration = if (durationCol >= 0) cursor.getLong(durationCol) else 0L
                val size = if (sizeCol >= 0) cursor.getLong(sizeCol) else 0L
                if (duration <= 0 && size <= 0) continue

                val title = if (titleCol >= 0) cursor.getString(titleCol) ?: "Unknown Track" else "Unknown Track"
                val artist = if (artistCol >= 0) cursor.getString(artistCol) ?: "Unknown Artist" else "Unknown Artist"
                val album = if (albumCol >= 0) cursor.getString(albumCol) ?: "Unknown Album" else "Unknown Album"
                val dateAdded = if (dateAddedCol >= 0) cursor.getLong(dateAddedCol) else 0L
                val dateModified = if (dateModifiedCol >= 0) cursor.getLong(dateModifiedCol) else 0L
                val track = if (trackCol >= 0) cursor.getInt(trackCol) else 0
                val year = if (yearCol >= 0) cursor.getInt(yearCol) else 0
                val albumId = if (albumIdCol >= 0) cursor.getLong(albumIdCol) else 0L
                val albumArtist = if (albumArtistCol >= 0) cursor.getString(albumArtistCol) else null

                // Compute album art content URI
                val artworkUri = if (albumId > 0) {
                    ContentUris.withAppendedId(
                        Uri.parse("content://media/external/audio/albumart"),
                        albumId
                    ).toString()
                } else null

                // Compute parent folder name
                val folder = try {
                    if (data.isNotEmpty() && !data.startsWith("content://")) {
                        val file = File(data)
                        file.parentFile?.name ?: "Music"
                    } else "Music"
                } catch (e: Exception) {
                    "Music"
                }

                // Check for pairing .lrc file in the same directory
                val lrcPath = try {
                    if (data.isNotEmpty() && !data.startsWith("content://")) {
                        val dotIndex = data.lastIndexOf('.')
                        if (dotIndex != -1) {
                            val potentialLrc = data.substring(0, dotIndex) + ".lrc"
                            if (File(potentialLrc).exists()) potentialLrc else null
                        } else null
                    } else null
                } catch (e: Exception) {
                    null
                }

                val songMap = mapOf<String, Any?>(
                    "id" to id.toString(),
                    "title" to title,
                    "artist" to artist,
                    "album" to album,
                    "albumArtist" to albumArtist,
                    "genre" to null,
                    "year" to if (year > 0) year else null,
                    "trackNumber" to if (track > 0) track else null,
                    "durationMs" to duration,
                    "fileSize" to size,
                    "filePath" to data,
                    "folder" to folder,
                    "dateAdded" to dateAdded * 1000,
                    "dateModified" to dateModified * 1000,
                    "artworkUri" to artworkUri,
                    "lrcPath" to lrcPath
                )

                songList.add(songMap)
            }
        }

        // Primary: Query with IS_MUSIC != 0
        try {
            contentResolver.query(
                collection,
                projection.toTypedArray(),
                "${MediaStore.Audio.Media.IS_MUSIC} != 0",
                null,
                sortOrder
            )?.use { cursor ->
                readCursor(cursor)
            }
            Log.d(TAG, "Primary query with IS_MUSIC: found ${songList.size} items")
        } catch (e: Exception) {
            Log.e(TAG, "Primary query failed: ${e.message}")
        }

        // Fallback: If no songs discovered, query without selection filter
        if (songList.isEmpty()) {
            try {
                contentResolver.query(
                    collection,
                    projection.toTypedArray(),
                    null,
                    null,
                    sortOrder
                )?.use { cursor ->
                    readCursor(cursor)
                }
                Log.d(TAG, "Fallback query without selection: found ${songList.size} items")
            } catch (e: Exception) {
                Log.e(TAG, "Fallback query failed: ${e.message}")
            }
        }

        return songList
    }
}
