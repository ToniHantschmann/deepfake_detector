import 'package:hive/hive.dart';
import '../models/statistics_model.dart';

class UserStatisticsAdapter extends TypeAdapter<UserStatistics> {
  @override
  final int typeId = 0;

  @override
  UserStatistics read(BinaryReader reader) {
    final map = reader.readMap();
    final jsonMap = map.cast<String, dynamic>();
    return UserStatistics.fromJson(jsonMap);
  }

  @override
  void write(BinaryWriter writer, UserStatistics obj) {
    writer.writeMap(obj.toJson());
  }
}
