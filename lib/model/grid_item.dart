class GridItem {
  int position;
  int goToPosition;

  GridItem({this.position, this.goToPosition});

  factory GridItem.fromJson(Map<String, dynamic> parsedJson) {
    return GridItem(
        position: parsedJson['position'],
        goToPosition: parsedJson['goToPosition']);
  }
}
