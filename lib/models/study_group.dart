class StudyGroup {
  final String id;
  final String name;
  final List<String> characterIds;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.characterIds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'characterIds': characterIds,
      };

  factory StudyGroup.fromJson(Map<String, dynamic> json) => StudyGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        characterIds: (json['characterIds'] as List).cast<String>(),
      );

  /// True if this group's characters exactly match [ids] (order-insensitive).
  bool matches(List<String> ids) {
    if (characterIds.length != ids.length) return false;
    final a = characterIds.toSet();
    final b = ids.toSet();
    return a.containsAll(b) && b.containsAll(a);
  }
}
