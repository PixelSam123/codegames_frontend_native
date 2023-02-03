class UserPreview {
  final String name;
  final int acceptedSubmissionCount;

  const UserPreview({
    required this.name,
    required this.acceptedSubmissionCount,
  });

  factory UserPreview.fromJson(Map<String, dynamic> json) {
    return UserPreview(
      name: json['name'],
      acceptedSubmissionCount: json['acceptedSubmissionCount'],
    );
  }
}

class ProblemPreview {
  final String title;
  final String description;

  const ProblemPreview({
    required this.title,
    required this.description,
  });

  factory ProblemPreview.fromJson(Map<String, dynamic> json) {
    return ProblemPreview(
      title: json['title'],
      description: json['description'],
    );
  }
}
