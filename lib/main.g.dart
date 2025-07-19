// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameScoreAdapter extends TypeAdapter<GameScore> {
  @override
  final int typeId = 0;

  @override
  GameScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameScore(
      score: fields[0] as int,
      date: fields[1] as DateTime,
      level: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameScore obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 1;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      playerName: fields[0] as String,
      highScore: fields[1] as int,
      totalGamesPlayed: fields[2] as int,
      totalScore: fields[3] as int,
      lastPlayDate: fields[4] as DateTime,
      achievements: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.playerName)
      ..writeByte(1)
      ..write(obj.highScore)
      ..writeByte(2)
      ..write(obj.totalGamesPlayed)
      ..writeByte(3)
      ..write(obj.totalScore)
      ..writeByte(4)
      ..write(obj.lastPlayDate)
      ..writeByte(5)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameSettingsAdapter extends TypeAdapter<GameSettings> {
  @override
  final int typeId = 2;

  @override
  GameSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameSettings(
      soundEnabled: fields[0] as bool,
      vibrationEnabled: fields[1] as bool,
      gameSpeed: fields[2] as double,
      theme: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GameSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.soundEnabled)
      ..writeByte(1)
      ..write(obj.vibrationEnabled)
      ..writeByte(2)
      ..write(obj.gameSpeed)
      ..writeByte(3)
      ..write(obj.theme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
