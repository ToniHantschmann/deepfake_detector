import 'package:hive/hive.dart';
import '../models/statistics_model.dart';

class UserStatisticsAdapter extends TypeAdapter<UserStatistics> {
  @override
  final int typeId = 0;

  @override
  UserStatistics read(BinaryReader reader) {
    final Map<dynamic, dynamic> rawMap = reader.readMap();
    final Map<String, dynamic> jsonMap = rawMap.cast<String, dynamic>();
    return UserStatistics.fromJson(jsonMap);
  }

  @override
  void write(BinaryWriter writer, UserStatistics obj) {
    final Map<String, dynamic> jsonMap = obj.toJson();
    final Map<dynamic, dynamic> rawMap = jsonMap.cast<dynamic, dynamic>();
    writer.writeMap(rawMap);
  }
}
