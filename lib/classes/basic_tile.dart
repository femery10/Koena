class BasicTile {
  final String title;
  final int id;
  final List<BasicTile> devices;
  bool isExpanded;

  BasicTile({
    required this.title,
    this.id = 0,
    this.devices = const [],
    this.isExpanded = false,
  });
}
