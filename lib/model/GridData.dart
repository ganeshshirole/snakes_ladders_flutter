import 'package:snakes_ladders/model/GridItem.dart';

class GridData {
  List<GridItem> gridItems;

  GridData({this.gridItems});

  factory GridData.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['gridData'] as List;
    return GridData(gridItems: list.map((i) => GridItem.fromJson(i)).toList());
  }
}
