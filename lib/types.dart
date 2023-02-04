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

class ProblemDetailedView extends ProblemPreview {
  final String initialCode;

  const ProblemDetailedView({
    required String title,
    required String description,
    required this.initialCode,
  }) : super(title: title, description: description);

  factory ProblemDetailedView.fromJson(Map<String, dynamic> json) {
    return ProblemDetailedView(
      title: json['title'],
      description: json['description'],
      initialCode: json['initialCode'],
    );
  }
}

class Submission {
  final String username;
  final String content;
  final String status;

  const Submission({
    required this.username,
    required this.content,
    required this.status,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      username: json['username'],
      content: json['content'],
      status: json['status'],
    );
  }
}
