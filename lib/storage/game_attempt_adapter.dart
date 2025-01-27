import 'package:hive/hive.dart';
import '../models/statistics_model.dart';

class GameAttemptAdapter extends TypeAdapter<GameAttempt> {
  @override
  final int typeId = 1;

  @override
  GameAttempt read(BinaryReader reader) {
    final Map<dynamic, dynamic> rawMap = reader.readMap();
    final Map<String, dynamic> jsonMap = rawMap.cast<String, dynamic>();
    return GameAttempt.fromJson(jsonMap);
  }

  @override
  void write(BinaryWriter writer, GameAttempt obj) {
    final Map<String, dynamic> jsonMap = obj.toJson();
    final Map<dynamic, dynamic> rawMap = jsonMap.cast<dynamic, dynamic>();
    writer.writeMap(rawMap);
  }
}
