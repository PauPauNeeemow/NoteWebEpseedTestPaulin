class Note {
  double x;
  double y;
  String content;

  Note({
    required this.x,
    required this.y,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'x': x.toString(),
      'y': y.toString(),
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      x: map['x'],
      y: map['y'],
      content: map['content'],
    );
  }
}