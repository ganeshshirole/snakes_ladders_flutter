class GridItem {
  int position;
  int goToPosition;
  bool isSnake;
  bool isLadder;

  GridItem({this.position, this.goToPosition, this.isSnake, this.isLadder});

  factory GridItem.fromJson(Map<String, dynamic> parsedJson) {
    return GridItem(
        position: parsedJson['position'],
        goToPosition: parsedJson['goToPosition'],
        isSnake: parsedJson['isSnake'],
        isLadder: parsedJson['isLadder']);
  }
}
