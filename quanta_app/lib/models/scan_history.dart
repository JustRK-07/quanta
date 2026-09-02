import 'scan_subject.dart';

class ScanHistory {
  final String topic;
  final List<String> variables;
  final String imagePath;
  final Map<String, dynamic> notesJson;
  bool isStarred;
  final DateTime timestamp;
  List<Map<String, dynamic>> quizResults;

  /// Subject of the scan (physics/chem/math/bio/other). Persisted by name so
  /// reordering the enum is safe. Constructed via [detectSubject] when null.
  final ScanSubject subject;

  ScanHistory({
    required this.topic,
    required this.variables,
    required this.imagePath,
    required this.notesJson,
    this.isStarred = false,
    required this.timestamp,
    this.quizResults = const [],
    ScanSubject? subject,
  }) : subject = subject ??
            detectSubject(
              topic: topic,
              variables: variables,
              notesJson: notesJson,
            );

  Map<String, dynamic> toJson() {
    return {
      "topic": topic,
      "variables": variables,
      "imagePath": imagePath,
      "notesJson": notesJson,
      "isStarred": isStarred,
      "timestamp": timestamp.toIso8601String(),
      "quizResults": quizResults,
      "subject": subject.name,
    };
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    final parsedVars = List<String>.from(json["variables"] ?? []);
    final parsedNotes = Map<String, dynamic>.from(json["notesJson"] ?? {});
    final parsedQuiz = List<Map<String, dynamic>>.from(
      (json["quizResults"] ?? []).map((x) => Map<String, dynamic>.from(x)),
    );
    return ScanHistory(
      topic: json["topic"] ?? "Unknown",
      variables: parsedVars,
      imagePath: json["imagePath"] ?? "",
      notesJson: parsedNotes,
      isStarred: json["isStarred"] ?? false,
      timestamp: DateTime.tryParse(json["timestamp"] ?? "") ?? DateTime.now(),
      quizResults: parsedQuiz,
      // Self-healing: null or unknown stored value triggers re-detection.
      subject: ScanSubject.tryParse(json["subject"]),
    );
  }
}
