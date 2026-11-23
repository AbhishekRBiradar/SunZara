// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTableTable extends SongsTable
    with TableInfo<$SongsTableTable, SongsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateModifiedMeta = const VerificationMeta(
    'dateModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateModified = GeneratedColumn<DateTime>(
    'date_modified',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lrcPathMeta = const VerificationMeta(
    'lrcPath',
  );
  @override
  late final GeneratedColumn<String> lrcPath = GeneratedColumn<String>(
    'lrc_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    album,
    albumArtist,
    genre,
    year,
    trackNumber,
    durationMs,
    fileSize,
    filePath,
    folder,
    dateAdded,
    dateModified,
    artworkUri,
    lrcPath,
    isFavorite,
    playCount,
    lastPlayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    } else if (isInserting) {
      context.missing(_folderMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    if (data.containsKey('date_modified')) {
      context.handle(
        _dateModifiedMeta,
        dateModified.isAcceptableOrUnknown(
          data['date_modified']!,
          _dateModifiedMeta,
        ),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
      );
    }
    if (data.containsKey('lrc_path')) {
      context.handle(
        _lrcPathMeta,
        lrcPath.isAcceptableOrUnknown(data['lrc_path']!, _lrcPathMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      ),
      dateModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_modified'],
      ),
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      ),
      lrcPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lrc_path'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
    );
  }

  @override
  $SongsTableTable createAlias(String alias) {
    return $SongsTableTable(attachedDatabase, alias);
  }
}

class SongsTableData extends DataClass implements Insertable<SongsTableData> {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int durationMs;
  final int fileSize;
  final String filePath;
  final String folder;
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final String? artworkUri;
  final String? lrcPath;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  const SongsTableData({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    required this.durationMs,
    required this.fileSize,
    required this.filePath,
    required this.folder,
    this.dateAdded,
    this.dateModified,
    this.artworkUri,
    this.lrcPath,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || albumArtist != null) {
      map['album_artist'] = Variable<String>(albumArtist);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_size'] = Variable<int>(fileSize);
    map['file_path'] = Variable<String>(filePath);
    map['folder'] = Variable<String>(folder);
    if (!nullToAbsent || dateAdded != null) {
      map['date_added'] = Variable<DateTime>(dateAdded);
    }
    if (!nullToAbsent || dateModified != null) {
      map['date_modified'] = Variable<DateTime>(dateModified);
    }
    if (!nullToAbsent || artworkUri != null) {
      map['artwork_uri'] = Variable<String>(artworkUri);
    }
    if (!nullToAbsent || lrcPath != null) {
      map['lrc_path'] = Variable<String>(lrcPath);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    return map;
  }

  SongsTableCompanion toCompanion(bool nullToAbsent) {
    return SongsTableCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      albumArtist: albumArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtist),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      durationMs: Value(durationMs),
      fileSize: Value(fileSize),
      filePath: Value(filePath),
      folder: Value(folder),
      dateAdded: dateAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAdded),
      dateModified: dateModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateModified),
      artworkUri: artworkUri == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUri),
      lrcPath: lrcPath == null && nullToAbsent
          ? const Value.absent()
          : Value(lrcPath),
      isFavorite: Value(isFavorite),
      playCount: Value(playCount),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
    );
  }

  factory SongsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      albumArtist: serializer.fromJson<String?>(json['albumArtist']),
      genre: serializer.fromJson<String?>(json['genre']),
      year: serializer.fromJson<int?>(json['year']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      filePath: serializer.fromJson<String>(json['filePath']),
      folder: serializer.fromJson<String>(json['folder']),
      dateAdded: serializer.fromJson<DateTime?>(json['dateAdded']),
      dateModified: serializer.fromJson<DateTime?>(json['dateModified']),
      artworkUri: serializer.fromJson<String?>(json['artworkUri']),
      lrcPath: serializer.fromJson<String?>(json['lrcPath']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'albumArtist': serializer.toJson<String?>(albumArtist),
      'genre': serializer.toJson<String?>(genre),
      'year': serializer.toJson<int?>(year),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileSize': serializer.toJson<int>(fileSize),
      'filePath': serializer.toJson<String>(filePath),
      'folder': serializer.toJson<String>(folder),
      'dateAdded': serializer.toJson<DateTime?>(dateAdded),
      'dateModified': serializer.toJson<DateTime?>(dateModified),
      'artworkUri': serializer.toJson<String?>(artworkUri),
      'lrcPath': serializer.toJson<String?>(lrcPath),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
    };
  }

  SongsTableData copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Value<String?> albumArtist = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    int? durationMs,
    int? fileSize,
    String? filePath,
    String? folder,
    Value<DateTime?> dateAdded = const Value.absent(),
    Value<DateTime?> dateModified = const Value.absent(),
    Value<String?> artworkUri = const Value.absent(),
    Value<String?> lrcPath = const Value.absent(),
    bool? isFavorite,
    int? playCount,
    Value<DateTime?> lastPlayed = const Value.absent(),
  }) => SongsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    albumArtist: albumArtist.present ? albumArtist.value : this.albumArtist,
    genre: genre.present ? genre.value : this.genre,
    year: year.present ? year.value : this.year,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    durationMs: durationMs ?? this.durationMs,
    fileSize: fileSize ?? this.fileSize,
    filePath: filePath ?? this.filePath,
    folder: folder ?? this.folder,
    dateAdded: dateAdded.present ? dateAdded.value : this.dateAdded,
    dateModified: dateModified.present ? dateModified.value : this.dateModified,
    artworkUri: artworkUri.present ? artworkUri.value : this.artworkUri,
    lrcPath: lrcPath.present ? lrcPath.value : this.lrcPath,
    isFavorite: isFavorite ?? this.isFavorite,
    playCount: playCount ?? this.playCount,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
  );
  SongsTableData copyWithCompanion(SongsTableCompanion data) {
    return SongsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      folder: data.folder.present ? data.folder.value : this.folder,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateModified: data.dateModified.present
          ? data.dateModified.value
          : this.dateModified,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      lrcPath: data.lrcPath.present ? data.lrcPath.value : this.lrcPath,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('filePath: $filePath, ')
          ..write('folder: $folder, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('lrcPath: $lrcPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    albumArtist,
    genre,
    year,
    trackNumber,
    durationMs,
    fileSize,
    filePath,
    folder,
    dateAdded,
    dateModified,
    artworkUri,
    lrcPath,
    isFavorite,
    playCount,
    lastPlayed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.genre == this.genre &&
          other.year == this.year &&
          other.trackNumber == this.trackNumber &&
          other.durationMs == this.durationMs &&
          other.fileSize == this.fileSize &&
          other.filePath == this.filePath &&
          other.folder == this.folder &&
          other.dateAdded == this.dateAdded &&
          other.dateModified == this.dateModified &&
          other.artworkUri == this.artworkUri &&
          other.lrcPath == this.lrcPath &&
          other.isFavorite == this.isFavorite &&
          other.playCount == this.playCount &&
          other.lastPlayed == this.lastPlayed);
}

class SongsTableCompanion extends UpdateCompanion<SongsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<String?> albumArtist;
  final Value<String?> genre;
  final Value<int?> year;
  final Value<int?> trackNumber;
  final Value<int> durationMs;
  final Value<int> fileSize;
  final Value<String> filePath;
  final Value<String> folder;
  final Value<DateTime?> dateAdded;
  final Value<DateTime?> dateModified;
  final Value<String?> artworkUri;
  final Value<String?> lrcPath;
  final Value<bool> isFavorite;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayed;
  final Value<int> rowid;
  const SongsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.filePath = const Value.absent(),
    this.folder = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.lrcPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsTableCompanion.insert({
    required String id,
    required String title,
    required String artist,
    required String album,
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    required int durationMs,
    required int fileSize,
    required String filePath,
    required String folder,
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.lrcPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artist = Value(artist),
       album = Value(album),
       durationMs = Value(durationMs),
       fileSize = Value(fileSize),
       filePath = Value(filePath),
       folder = Value(folder);
  static Insertable<SongsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<int>? trackNumber,
    Expression<int>? durationMs,
    Expression<int>? fileSize,
    Expression<String>? filePath,
    Expression<String>? folder,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? dateModified,
    Expression<String>? artworkUri,
    Expression<String>? lrcPath,
    Expression<bool>? isFavorite,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (trackNumber != null) 'track_number': trackNumber,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSize != null) 'file_size': fileSize,
      if (filePath != null) 'file_path': filePath,
      if (folder != null) 'folder': folder,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateModified != null) 'date_modified': dateModified,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (lrcPath != null) 'lrc_path': lrcPath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<String?>? albumArtist,
    Value<String?>? genre,
    Value<int?>? year,
    Value<int?>? trackNumber,
    Value<int>? durationMs,
    Value<int>? fileSize,
    Value<String>? filePath,
    Value<String>? folder,
    Value<DateTime?>? dateAdded,
    Value<DateTime?>? dateModified,
    Value<String?>? artworkUri,
    Value<String?>? lrcPath,
    Value<bool>? isFavorite,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayed,
    Value<int>? rowid,
  }) {
    return SongsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
      folder: folder ?? this.folder,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      artworkUri: artworkUri ?? this.artworkUri,
      lrcPath: lrcPath ?? this.lrcPath,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (dateModified.present) {
      map['date_modified'] = Variable<DateTime>(dateModified.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (lrcPath.present) {
      map['lrc_path'] = Variable<String>(lrcPath.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('filePath: $filePath, ')
          ..write('folder: $folder, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('lrcPath: $lrcPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customArtworkPathMeta = const VerificationMeta(
    'customArtworkPath',
  );
  @override
  late final GeneratedColumn<String> customArtworkPath =
      GeneratedColumn<String>(
        'custom_artwork_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSmartMeta = const VerificationMeta(
    'isSmart',
  );
  @override
  late final GeneratedColumn<bool> isSmart = GeneratedColumn<bool>(
    'is_smart',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_smart" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    customArtworkPath,
    createdAt,
    updatedAt,
    isSmart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('custom_artwork_path')) {
      context.handle(
        _customArtworkPathMeta,
        customArtworkPath.isAcceptableOrUnknown(
          data['custom_artwork_path']!,
          _customArtworkPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_smart')) {
      context.handle(
        _isSmartMeta,
        isSmart.isAcceptableOrUnknown(data['is_smart']!, _isSmartMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      customArtworkPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_artwork_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      isSmart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_smart'],
      )!,
    );
  }

  @override
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistsTableData extends DataClass
    implements Insertable<PlaylistsTableData> {
  final String id;
  final String name;
  final String? customArtworkPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSmart;
  const PlaylistsTableData({
    required this.id,
    required this.name,
    this.customArtworkPath,
    required this.createdAt,
    this.updatedAt,
    required this.isSmart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || customArtworkPath != null) {
      map['custom_artwork_path'] = Variable<String>(customArtworkPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_smart'] = Variable<bool>(isSmart);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      customArtworkPath: customArtworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customArtworkPath),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSmart: Value(isSmart),
    );
  }

  factory PlaylistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      customArtworkPath: serializer.fromJson<String?>(
        json['customArtworkPath'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSmart: serializer.fromJson<bool>(json['isSmart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'customArtworkPath': serializer.toJson<String?>(customArtworkPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSmart': serializer.toJson<bool>(isSmart),
    };
  }

  PlaylistsTableData copyWith({
    String? id,
    String? name,
    Value<String?> customArtworkPath = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    bool? isSmart,
  }) => PlaylistsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    customArtworkPath: customArtworkPath.present
        ? customArtworkPath.value
        : this.customArtworkPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isSmart: isSmart ?? this.isSmart,
  );
  PlaylistsTableData copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      customArtworkPath: data.customArtworkPath.present
          ? data.customArtworkPath.value
          : this.customArtworkPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSmart: data.isSmart.present ? data.isSmart.value : this.isSmart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('customArtworkPath: $customArtworkPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSmart: $isSmart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, customArtworkPath, createdAt, updatedAt, isSmart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.customArtworkPath == this.customArtworkPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSmart == this.isSmart);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> customArtworkPath;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSmart;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.customArtworkPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    this.customArtworkPath = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaylistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? customArtworkPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSmart,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (customArtworkPath != null) 'custom_artwork_path': customArtworkPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSmart != null) 'is_smart': isSmart,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? customArtworkPath,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<bool>? isSmart,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      customArtworkPath: customArtworkPath ?? this.customArtworkPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSmart: isSmart ?? this.isSmart,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (customArtworkPath.present) {
      map['custom_artwork_path'] = Variable<String>(customArtworkPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSmart.present) {
      map['is_smart'] = Variable<bool>(isSmart.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('customArtworkPath: $customArtworkPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSmart: $isSmart, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTableTable extends PlaylistSongsTable
    with TableInfo<$PlaylistSongsTableTable, PlaylistSongsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSongsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSongsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSongsTableData(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PlaylistSongsTableTable createAlias(String alias) {
    return $PlaylistSongsTableTable(attachedDatabase, alias);
  }
}

class PlaylistSongsTableData extends DataClass
    implements Insertable<PlaylistSongsTableData> {
  final String playlistId;
  final String songId;
  final int sortOrder;
  const PlaylistSongsTableData({
    required this.playlistId,
    required this.songId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PlaylistSongsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsTableCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      sortOrder: Value(sortOrder),
    );
  }

  factory PlaylistSongsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSongsTableData(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PlaylistSongsTableData copyWith({
    String? playlistId,
    String? songId,
    int? sortOrder,
  }) => PlaylistSongsTableData(
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PlaylistSongsTableData copyWithCompanion(PlaylistSongsTableCompanion data) {
    return PlaylistSongsTableData(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsTableData(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSongsTableData &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.sortOrder == this.sortOrder);
}

class PlaylistSongsTableCompanion
    extends UpdateCompanion<PlaylistSongsTableData> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PlaylistSongsTableCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongsTableCompanion.insert({
    required String playlistId,
    required String songId,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       sortOrder = Value(sortOrder);
  static Insertable<PlaylistSongsTableData> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongsTableCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PlaylistSongsTableCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsTableCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStateTableTable extends PlaybackStateTable
    with TableInfo<$PlaybackStateTableTable, PlaybackStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _currentSongIdMeta = const VerificationMeta(
    'currentSongId',
  );
  @override
  late final GeneratedColumn<String> currentSongId = GeneratedColumn<String>(
    'current_song_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contextTypeMeta = const VerificationMeta(
    'contextType',
  );
  @override
  late final GeneratedColumn<String> contextType = GeneratedColumn<String>(
    'context_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('library'),
  );
  static const VerificationMeta _contextIdMeta = const VerificationMeta(
    'contextId',
  );
  @override
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
    'context_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('library_all'),
  );
  static const VerificationMeta _contextNameMeta = const VerificationMeta(
    'contextName',
  );
  @override
  late final GeneratedColumn<String> contextName = GeneratedColumn<String>(
    'context_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Entire Library'),
  );
  static const VerificationMeta _isShuffleEnabledMeta = const VerificationMeta(
    'isShuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> isShuffleEnabled = GeneratedColumn<bool>(
    'is_shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shuffle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _manualQueueJsonMeta = const VerificationMeta(
    'manualQueueJson',
  );
  @override
  late final GeneratedColumn<String> manualQueueJson = GeneratedColumn<String>(
    'manual_queue_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _automaticPoolJsonMeta = const VerificationMeta(
    'automaticPoolJson',
  );
  @override
  late final GeneratedColumn<String> automaticPoolJson =
      GeneratedColumn<String>(
        'automatic_pool_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _shuffleStateJsonMeta = const VerificationMeta(
    'shuffleStateJson',
  );
  @override
  late final GeneratedColumn<String> shuffleStateJson = GeneratedColumn<String>(
    'shuffle_state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentSongId,
    positionMs,
    contextType,
    contextId,
    contextName,
    isShuffleEnabled,
    repeatMode,
    manualQueueJson,
    automaticPoolJson,
    shuffleStateJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_song_id')) {
      context.handle(
        _currentSongIdMeta,
        currentSongId.isAcceptableOrUnknown(
          data['current_song_id']!,
          _currentSongIdMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('context_type')) {
      context.handle(
        _contextTypeMeta,
        contextType.isAcceptableOrUnknown(
          data['context_type']!,
          _contextTypeMeta,
        ),
      );
    }
    if (data.containsKey('context_id')) {
      context.handle(
        _contextIdMeta,
        contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta),
      );
    }
    if (data.containsKey('context_name')) {
      context.handle(
        _contextNameMeta,
        contextName.isAcceptableOrUnknown(
          data['context_name']!,
          _contextNameMeta,
        ),
      );
    }
    if (data.containsKey('is_shuffle_enabled')) {
      context.handle(
        _isShuffleEnabledMeta,
        isShuffleEnabled.isAcceptableOrUnknown(
          data['is_shuffle_enabled']!,
          _isShuffleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('manual_queue_json')) {
      context.handle(
        _manualQueueJsonMeta,
        manualQueueJson.isAcceptableOrUnknown(
          data['manual_queue_json']!,
          _manualQueueJsonMeta,
        ),
      );
    }
    if (data.containsKey('automatic_pool_json')) {
      context.handle(
        _automaticPoolJsonMeta,
        automaticPoolJson.isAcceptableOrUnknown(
          data['automatic_pool_json']!,
          _automaticPoolJsonMeta,
        ),
      );
    }
    if (data.containsKey('shuffle_state_json')) {
      context.handle(
        _shuffleStateJsonMeta,
        shuffleStateJson.isAcceptableOrUnknown(
          data['shuffle_state_json']!,
          _shuffleStateJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackStateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentSongId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_song_id'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      contextType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_type'],
      )!,
      contextId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_id'],
      )!,
      contextName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_name'],
      )!,
      isShuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shuffle_enabled'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      manualQueueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_queue_json'],
      )!,
      automaticPoolJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}automatic_pool_json'],
      )!,
      shuffleStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shuffle_state_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaybackStateTableTable createAlias(String alias) {
    return $PlaybackStateTableTable(attachedDatabase, alias);
  }
}

class PlaybackStateTableData extends DataClass
    implements Insertable<PlaybackStateTableData> {
  final int id;
  final String? currentSongId;
  final int positionMs;
  final String contextType;
  final String contextId;
  final String contextName;
  final bool isShuffleEnabled;
  final String repeatMode;
  final String manualQueueJson;
  final String automaticPoolJson;
  final String shuffleStateJson;
  final DateTime updatedAt;
  const PlaybackStateTableData({
    required this.id,
    this.currentSongId,
    required this.positionMs,
    required this.contextType,
    required this.contextId,
    required this.contextName,
    required this.isShuffleEnabled,
    required this.repeatMode,
    required this.manualQueueJson,
    required this.automaticPoolJson,
    required this.shuffleStateJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || currentSongId != null) {
      map['current_song_id'] = Variable<String>(currentSongId);
    }
    map['position_ms'] = Variable<int>(positionMs);
    map['context_type'] = Variable<String>(contextType);
    map['context_id'] = Variable<String>(contextId);
    map['context_name'] = Variable<String>(contextName);
    map['is_shuffle_enabled'] = Variable<bool>(isShuffleEnabled);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['manual_queue_json'] = Variable<String>(manualQueueJson);
    map['automatic_pool_json'] = Variable<String>(automaticPoolJson);
    map['shuffle_state_json'] = Variable<String>(shuffleStateJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackStateTableCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStateTableCompanion(
      id: Value(id),
      currentSongId: currentSongId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSongId),
      positionMs: Value(positionMs),
      contextType: Value(contextType),
      contextId: Value(contextId),
      contextName: Value(contextName),
      isShuffleEnabled: Value(isShuffleEnabled),
      repeatMode: Value(repeatMode),
      manualQueueJson: Value(manualQueueJson),
      automaticPoolJson: Value(automaticPoolJson),
      shuffleStateJson: Value(shuffleStateJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackStateTableData(
      id: serializer.fromJson<int>(json['id']),
      currentSongId: serializer.fromJson<String?>(json['currentSongId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      contextType: serializer.fromJson<String>(json['contextType']),
      contextId: serializer.fromJson<String>(json['contextId']),
      contextName: serializer.fromJson<String>(json['contextName']),
      isShuffleEnabled: serializer.fromJson<bool>(json['isShuffleEnabled']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      manualQueueJson: serializer.fromJson<String>(json['manualQueueJson']),
      automaticPoolJson: serializer.fromJson<String>(json['automaticPoolJson']),
      shuffleStateJson: serializer.fromJson<String>(json['shuffleStateJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentSongId': serializer.toJson<String?>(currentSongId),
      'positionMs': serializer.toJson<int>(positionMs),
      'contextType': serializer.toJson<String>(contextType),
      'contextId': serializer.toJson<String>(contextId),
      'contextName': serializer.toJson<String>(contextName),
      'isShuffleEnabled': serializer.toJson<bool>(isShuffleEnabled),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'manualQueueJson': serializer.toJson<String>(manualQueueJson),
      'automaticPoolJson': serializer.toJson<String>(automaticPoolJson),
      'shuffleStateJson': serializer.toJson<String>(shuffleStateJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackStateTableData copyWith({
    int? id,
    Value<String?> currentSongId = const Value.absent(),
    int? positionMs,
    String? contextType,
    String? contextId,
    String? contextName,
    bool? isShuffleEnabled,
    String? repeatMode,
    String? manualQueueJson,
    String? automaticPoolJson,
    String? shuffleStateJson,
    DateTime? updatedAt,
  }) => PlaybackStateTableData(
    id: id ?? this.id,
    currentSongId: currentSongId.present
        ? currentSongId.value
        : this.currentSongId,
    positionMs: positionMs ?? this.positionMs,
    contextType: contextType ?? this.contextType,
    contextId: contextId ?? this.contextId,
    contextName: contextName ?? this.contextName,
    isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
    repeatMode: repeatMode ?? this.repeatMode,
    manualQueueJson: manualQueueJson ?? this.manualQueueJson,
    automaticPoolJson: automaticPoolJson ?? this.automaticPoolJson,
    shuffleStateJson: shuffleStateJson ?? this.shuffleStateJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaybackStateTableData copyWithCompanion(PlaybackStateTableCompanion data) {
    return PlaybackStateTableData(
      id: data.id.present ? data.id.value : this.id,
      currentSongId: data.currentSongId.present
          ? data.currentSongId.value
          : this.currentSongId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      contextType: data.contextType.present
          ? data.contextType.value
          : this.contextType,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      contextName: data.contextName.present
          ? data.contextName.value
          : this.contextName,
      isShuffleEnabled: data.isShuffleEnabled.present
          ? data.isShuffleEnabled.value
          : this.isShuffleEnabled,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      manualQueueJson: data.manualQueueJson.present
          ? data.manualQueueJson.value
          : this.manualQueueJson,
      automaticPoolJson: data.automaticPoolJson.present
          ? data.automaticPoolJson.value
          : this.automaticPoolJson,
      shuffleStateJson: data.shuffleStateJson.present
          ? data.shuffleStateJson.value
          : this.shuffleStateJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStateTableData(')
          ..write('id: $id, ')
          ..write('currentSongId: $currentSongId, ')
          ..write('positionMs: $positionMs, ')
          ..write('contextType: $contextType, ')
          ..write('contextId: $contextId, ')
          ..write('contextName: $contextName, ')
          ..write('isShuffleEnabled: $isShuffleEnabled, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('manualQueueJson: $manualQueueJson, ')
          ..write('automaticPoolJson: $automaticPoolJson, ')
          ..write('shuffleStateJson: $shuffleStateJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentSongId,
    positionMs,
    contextType,
    contextId,
    contextName,
    isShuffleEnabled,
    repeatMode,
    manualQueueJson,
    automaticPoolJson,
    shuffleStateJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackStateTableData &&
          other.id == this.id &&
          other.currentSongId == this.currentSongId &&
          other.positionMs == this.positionMs &&
          other.contextType == this.contextType &&
          other.contextId == this.contextId &&
          other.contextName == this.contextName &&
          other.isShuffleEnabled == this.isShuffleEnabled &&
          other.repeatMode == this.repeatMode &&
          other.manualQueueJson == this.manualQueueJson &&
          other.automaticPoolJson == this.automaticPoolJson &&
          other.shuffleStateJson == this.shuffleStateJson &&
          other.updatedAt == this.updatedAt);
}

class PlaybackStateTableCompanion
    extends UpdateCompanion<PlaybackStateTableData> {
  final Value<int> id;
  final Value<String?> currentSongId;
  final Value<int> positionMs;
  final Value<String> contextType;
  final Value<String> contextId;
  final Value<String> contextName;
  final Value<bool> isShuffleEnabled;
  final Value<String> repeatMode;
  final Value<String> manualQueueJson;
  final Value<String> automaticPoolJson;
  final Value<String> shuffleStateJson;
  final Value<DateTime> updatedAt;
  const PlaybackStateTableCompanion({
    this.id = const Value.absent(),
    this.currentSongId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.contextType = const Value.absent(),
    this.contextId = const Value.absent(),
    this.contextName = const Value.absent(),
    this.isShuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.manualQueueJson = const Value.absent(),
    this.automaticPoolJson = const Value.absent(),
    this.shuffleStateJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaybackStateTableCompanion.insert({
    this.id = const Value.absent(),
    this.currentSongId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.contextType = const Value.absent(),
    this.contextId = const Value.absent(),
    this.contextName = const Value.absent(),
    this.isShuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.manualQueueJson = const Value.absent(),
    this.automaticPoolJson = const Value.absent(),
    this.shuffleStateJson = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<PlaybackStateTableData> custom({
    Expression<int>? id,
    Expression<String>? currentSongId,
    Expression<int>? positionMs,
    Expression<String>? contextType,
    Expression<String>? contextId,
    Expression<String>? contextName,
    Expression<bool>? isShuffleEnabled,
    Expression<String>? repeatMode,
    Expression<String>? manualQueueJson,
    Expression<String>? automaticPoolJson,
    Expression<String>? shuffleStateJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentSongId != null) 'current_song_id': currentSongId,
      if (positionMs != null) 'position_ms': positionMs,
      if (contextType != null) 'context_type': contextType,
      if (contextId != null) 'context_id': contextId,
      if (contextName != null) 'context_name': contextName,
      if (isShuffleEnabled != null) 'is_shuffle_enabled': isShuffleEnabled,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (manualQueueJson != null) 'manual_queue_json': manualQueueJson,
      if (automaticPoolJson != null) 'automatic_pool_json': automaticPoolJson,
      if (shuffleStateJson != null) 'shuffle_state_json': shuffleStateJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaybackStateTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? currentSongId,
    Value<int>? positionMs,
    Value<String>? contextType,
    Value<String>? contextId,
    Value<String>? contextName,
    Value<bool>? isShuffleEnabled,
    Value<String>? repeatMode,
    Value<String>? manualQueueJson,
    Value<String>? automaticPoolJson,
    Value<String>? shuffleStateJson,
    Value<DateTime>? updatedAt,
  }) {
    return PlaybackStateTableCompanion(
      id: id ?? this.id,
      currentSongId: currentSongId ?? this.currentSongId,
      positionMs: positionMs ?? this.positionMs,
      contextType: contextType ?? this.contextType,
      contextId: contextId ?? this.contextId,
      contextName: contextName ?? this.contextName,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      manualQueueJson: manualQueueJson ?? this.manualQueueJson,
      automaticPoolJson: automaticPoolJson ?? this.automaticPoolJson,
      shuffleStateJson: shuffleStateJson ?? this.shuffleStateJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentSongId.present) {
      map['current_song_id'] = Variable<String>(currentSongId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (contextType.present) {
      map['context_type'] = Variable<String>(contextType.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (contextName.present) {
      map['context_name'] = Variable<String>(contextName.value);
    }
    if (isShuffleEnabled.present) {
      map['is_shuffle_enabled'] = Variable<bool>(isShuffleEnabled.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (manualQueueJson.present) {
      map['manual_queue_json'] = Variable<String>(manualQueueJson.value);
    }
    if (automaticPoolJson.present) {
      map['automatic_pool_json'] = Variable<String>(automaticPoolJson.value);
    }
    if (shuffleStateJson.present) {
      map['shuffle_state_json'] = Variable<String>(shuffleStateJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStateTableCompanion(')
          ..write('id: $id, ')
          ..write('currentSongId: $currentSongId, ')
          ..write('positionMs: $positionMs, ')
          ..write('contextType: $contextType, ')
          ..write('contextId: $contextId, ')
          ..write('contextName: $contextName, ')
          ..write('isShuffleEnabled: $isShuffleEnabled, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('manualQueueJson: $manualQueueJson, ')
          ..write('automaticPoolJson: $automaticPoolJson, ')
          ..write('shuffleStateJson: $shuffleStateJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTableTable songsTable = $SongsTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistSongsTableTable playlistSongsTable =
      $PlaylistSongsTableTable(this);
  late final $PlaybackStateTableTable playbackStateTable =
      $PlaybackStateTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songsTable,
    playlistsTable,
    playlistSongsTable,
    playbackStateTable,
  ];
}

typedef $$SongsTableTableCreateCompanionBuilder = SongsTableCompanion Function({
  required String id,
  required String title,
  required String artist,
  required String album,
  Value<String?> albumArtist,
  Value<String?> genre,
  Value<int?> year,
  Value<int?> trackNumber,
  required int durationMs,
  required int fileSize,
  required String filePath,
  required String folder,
  Value<DateTime?> dateAdded,
  Value<DateTime?> dateModified,
  Value<String?> artworkUri,
  Value<String?> lrcPath,
  Value<bool> isFavorite,
  Value<int> playCount,
  Value<DateTime?> lastPlayed,
  Value<int> rowid,
});
typedef $$SongsTableTableUpdateCompanionBuilder = SongsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String?> albumArtist,
  Value<String?> genre,
  Value<int?> year,
  Value<int?> trackNumber,
  Value<int> durationMs,
  Value<int> fileSize,
  Value<String> filePath,
  Value<String> folder,
  Value<DateTime?> dateAdded,
  Value<DateTime?> dateModified,
  Value<String?> artworkUri,
  Value<String?> lrcPath,
  Value<bool> isFavorite,
  Value<int> playCount,
  Value<DateTime?> lastPlayed,
  Value<int> rowid,
});

class $$SongsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lrcPath => $composableBuilder(
    column: $table.lrcPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lrcPath => $composableBuilder(
    column: $table.lrcPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lrcPath =>
      $composableBuilder(column: $table.lrcPath, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );
}

class $$SongsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTableTable,
          SongsTableData,
          $$SongsTableTableFilterComposer,
          $$SongsTableTableOrderingComposer,
          $$SongsTableTableAnnotationComposer,
          $$SongsTableTableCreateCompanionBuilder,
          $$SongsTableTableUpdateCompanionBuilder,
          (
            SongsTableData,
            BaseReferences<_$AppDatabase, $SongsTableTable, SongsTableData>,
          ),
          SongsTableData,
          PrefetchHooks Function()
        > {
  $$SongsTableTableTableManager(_$AppDatabase db, $SongsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> folder = const Value.absent(),
                Value<DateTime?> dateAdded = const Value.absent(),
                Value<DateTime?> dateModified = const Value.absent(),
                Value<String?> artworkUri = const Value.absent(),
                Value<String?> lrcPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsTableCompanion(
                id: id,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                durationMs: durationMs,
                fileSize: fileSize,
                filePath: filePath,
                folder: folder,
                dateAdded: dateAdded,
                dateModified: dateModified,
                artworkUri: artworkUri,
                lrcPath: lrcPath,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artist,
                required String album,
                Value<String?> albumArtist = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                required int durationMs,
                required int fileSize,
                required String filePath,
                required String folder,
                Value<DateTime?> dateAdded = const Value.absent(),
                Value<DateTime?> dateModified = const Value.absent(),
                Value<String?> artworkUri = const Value.absent(),
                Value<String?> lrcPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsTableCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                durationMs: durationMs,
                fileSize: fileSize,
                filePath: filePath,
                folder: folder,
                dateAdded: dateAdded,
                dateModified: dateModified,
                artworkUri: artworkUri,
                lrcPath: lrcPath,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongsTableTable, SongsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SongsTableTable,
                    SongsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTableTable,
      SongsTableData,
      $$SongsTableTableFilterComposer,
      $$SongsTableTableOrderingComposer,
      $$SongsTableTableAnnotationComposer,
      $$SongsTableTableCreateCompanionBuilder,
      $$SongsTableTableUpdateCompanionBuilder,
      (
        SongsTableData,
        BaseReferences<_$AppDatabase, $SongsTableTable, SongsTableData>,
      ),
      SongsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> customArtworkPath,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isSmart,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> customArtworkPath,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isSmart,
      Value<int> rowid,
    });

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customArtworkPath => $composableBuilder(
    column: $table.customArtworkPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSmart => $composableBuilder(
    column: $table.isSmart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customArtworkPath => $composableBuilder(
    column: $table.customArtworkPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSmart => $composableBuilder(
    column: $table.isSmart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get customArtworkPath => $composableBuilder(
    column: $table.customArtworkPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSmart =>
      $composableBuilder(column: $table.isSmart, builder: (column) => column);
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (
            PlaylistsTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaylistsTableTable,
              PlaylistsTableData
            >,
          ),
          PlaylistsTableData,
          PrefetchHooks Function()
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> customArtworkPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isSmart = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                customArtworkPath: customArtworkPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSmart: isSmart,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> customArtworkPath = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isSmart = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                customArtworkPath: customArtworkPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSmart: isSmart,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTableTable, PlaylistsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaylistsTableTable,
                    PlaylistsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistsTableData,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (
        PlaylistsTableData,
        BaseReferences<_$AppDatabase, $PlaylistsTableTable, PlaylistsTableData>,
      ),
      PlaylistsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistSongsTableTableCreateCompanionBuilder =
    PlaylistSongsTableCompanion Function({
      required String playlistId,
      required String songId,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$PlaylistSongsTableTableUpdateCompanionBuilder =
    PlaylistSongsTableCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$PlaylistSongsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTableTable> {
  $$PlaylistSongsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistSongsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTableTable> {
  $$PlaylistSongsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistSongsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTableTable> {
  $$PlaylistSongsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$PlaylistSongsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongsTableTable,
          PlaylistSongsTableData,
          $$PlaylistSongsTableTableFilterComposer,
          $$PlaylistSongsTableTableOrderingComposer,
          $$PlaylistSongsTableTableAnnotationComposer,
          $$PlaylistSongsTableTableCreateCompanionBuilder,
          $$PlaylistSongsTableTableUpdateCompanionBuilder,
          (
            PlaylistSongsTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaylistSongsTableTable,
              PlaylistSongsTableData
            >,
          ),
          PlaylistSongsTableData,
          PrefetchHooks Function()
        > {
  $$PlaylistSongsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistSongsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsTableCompanion(
                playlistId: playlistId,
                songId: songId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsTableCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistSongsTableTable, PlaylistSongsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaylistSongsTableTable,
                    PlaylistSongsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistSongsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongsTableTable,
      PlaylistSongsTableData,
      $$PlaylistSongsTableTableFilterComposer,
      $$PlaylistSongsTableTableOrderingComposer,
      $$PlaylistSongsTableTableAnnotationComposer,
      $$PlaylistSongsTableTableCreateCompanionBuilder,
      $$PlaylistSongsTableTableUpdateCompanionBuilder,
      (
        PlaylistSongsTableData,
        BaseReferences<
          _$AppDatabase,
          $PlaylistSongsTableTable,
          PlaylistSongsTableData
        >,
      ),
      PlaylistSongsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaybackStateTableTableCreateCompanionBuilder =
    PlaybackStateTableCompanion Function({
      Value<int> id,
      Value<String?> currentSongId,
      Value<int> positionMs,
      Value<String> contextType,
      Value<String> contextId,
      Value<String> contextName,
      Value<bool> isShuffleEnabled,
      Value<String> repeatMode,
      Value<String> manualQueueJson,
      Value<String> automaticPoolJson,
      Value<String> shuffleStateJson,
      required DateTime updatedAt,
    });
typedef $$PlaybackStateTableTableUpdateCompanionBuilder =
    PlaybackStateTableCompanion Function({
      Value<int> id,
      Value<String?> currentSongId,
      Value<int> positionMs,
      Value<String> contextType,
      Value<String> contextId,
      Value<String> contextName,
      Value<bool> isShuffleEnabled,
      Value<String> repeatMode,
      Value<String> manualQueueJson,
      Value<String> automaticPoolJson,
      Value<String> shuffleStateJson,
      Value<DateTime> updatedAt,
    });

class $$PlaybackStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackStateTableTable> {
  $$PlaybackStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentSongId => $composableBuilder(
    column: $table.currentSongId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextName => $composableBuilder(
    column: $table.contextName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShuffleEnabled => $composableBuilder(
    column: $table.isShuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualQueueJson => $composableBuilder(
    column: $table.manualQueueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get automaticPoolJson => $composableBuilder(
    column: $table.automaticPoolJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shuffleStateJson => $composableBuilder(
    column: $table.shuffleStateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackStateTableTable> {
  $$PlaybackStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentSongId => $composableBuilder(
    column: $table.currentSongId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextName => $composableBuilder(
    column: $table.contextName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShuffleEnabled => $composableBuilder(
    column: $table.isShuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualQueueJson => $composableBuilder(
    column: $table.manualQueueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get automaticPoolJson => $composableBuilder(
    column: $table.automaticPoolJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shuffleStateJson => $composableBuilder(
    column: $table.shuffleStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackStateTableTable> {
  $$PlaybackStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currentSongId => $composableBuilder(
    column: $table.currentSongId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<String> get contextName => $composableBuilder(
    column: $table.contextName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isShuffleEnabled => $composableBuilder(
    column: $table.isShuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manualQueueJson => $composableBuilder(
    column: $table.manualQueueJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get automaticPoolJson => $composableBuilder(
    column: $table.automaticPoolJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shuffleStateJson => $composableBuilder(
    column: $table.shuffleStateJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackStateTableTable,
          PlaybackStateTableData,
          $$PlaybackStateTableTableFilterComposer,
          $$PlaybackStateTableTableOrderingComposer,
          $$PlaybackStateTableTableAnnotationComposer,
          $$PlaybackStateTableTableCreateCompanionBuilder,
          $$PlaybackStateTableTableUpdateCompanionBuilder,
          (
            PlaybackStateTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaybackStateTableTable,
              PlaybackStateTableData
            >,
          ),
          PlaybackStateTableData,
          PrefetchHooks Function()
        > {
  $$PlaybackStateTableTableTableManager(
    _$AppDatabase db,
    $PlaybackStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> currentSongId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> contextType = const Value.absent(),
                Value<String> contextId = const Value.absent(),
                Value<String> contextName = const Value.absent(),
                Value<bool> isShuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<String> manualQueueJson = const Value.absent(),
                Value<String> automaticPoolJson = const Value.absent(),
                Value<String> shuffleStateJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlaybackStateTableCompanion(
                id: id,
                currentSongId: currentSongId,
                positionMs: positionMs,
                contextType: contextType,
                contextId: contextId,
                contextName: contextName,
                isShuffleEnabled: isShuffleEnabled,
                repeatMode: repeatMode,
                manualQueueJson: manualQueueJson,
                automaticPoolJson: automaticPoolJson,
                shuffleStateJson: shuffleStateJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> currentSongId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> contextType = const Value.absent(),
                Value<String> contextId = const Value.absent(),
                Value<String> contextName = const Value.absent(),
                Value<bool> isShuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<String> manualQueueJson = const Value.absent(),
                Value<String> automaticPoolJson = const Value.absent(),
                Value<String> shuffleStateJson = const Value.absent(),
                required DateTime updatedAt,
              }) => PlaybackStateTableCompanion.insert(
                id: id,
                currentSongId: currentSongId,
                positionMs: positionMs,
                contextType: contextType,
                contextId: contextId,
                contextName: contextName,
                isShuffleEnabled: isShuffleEnabled,
                repeatMode: repeatMode,
                manualQueueJson: manualQueueJson,
                automaticPoolJson: automaticPoolJson,
                shuffleStateJson: shuffleStateJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaybackStateTableTable, PlaybackStateTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaybackStateTableTable,
                    PlaybackStateTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackStateTableTable,
      PlaybackStateTableData,
      $$PlaybackStateTableTableFilterComposer,
      $$PlaybackStateTableTableOrderingComposer,
      $$PlaybackStateTableTableAnnotationComposer,
      $$PlaybackStateTableTableCreateCompanionBuilder,
      $$PlaybackStateTableTableUpdateCompanionBuilder,
      (
        PlaybackStateTableData,
        BaseReferences<
          _$AppDatabase,
          $PlaybackStateTableTable,
          PlaybackStateTableData
        >,
      ),
      PlaybackStateTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableTableManager get songsTable =>
      $$SongsTableTableTableManager(_db, _db.songsTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistSongsTableTableTableManager get playlistSongsTable =>
      $$PlaylistSongsTableTableTableManager(_db, _db.playlistSongsTable);
  $$PlaybackStateTableTableTableManager get playbackStateTable =>
      $$PlaybackStateTableTableTableManager(_db, _db.playbackStateTable);
}
