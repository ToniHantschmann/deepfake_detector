import 'package:hive/hive.dart';
import '../models/statistics_model.dart';

class GameAttemptAdapter extends TypeAdapter<GameAttempt> {
  @override
  final int typeId = 1;

  @override
  GameAttempt read(BinaryReader reader) {
    final map = reader.readMap();
    final jsonMap = map.cast<String, dynamic>();
    return GameAttempt.fromJson(jsonMap);
  }

  @override
  void write(BinaryWriter writer, GameAttempt obj) {
    writer.writeMap(obj.toJson());
  }
}
