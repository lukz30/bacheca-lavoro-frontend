class Job {
  final int id;
  final String title;
  final String description;
  final String company;
  final String createdAt;
  final int applicationsCount;

  Job.fromJson(Map<String, dynamic> j)
      : id = j['id'] as int,
        title = j['title'] as String,
        description = j['description'] as String,
        company = (j['company'] ?? '') as String,
        createdAt = (j['created_at'] ?? '') as String,
        applicationsCount = (j['applications_count'] ?? 0) as int;
}

class Application {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String cvName;
  final String createdAt;

  Application.fromJson(Map<String, dynamic> j)
      : id = j['id'] as int,
        firstName = j['first_name'] as String,
        lastName = j['last_name'] as String,
        email = j['email'] as String,
        cvName = (j['cv_name'] ?? '') as String,
        createdAt = (j['created_at'] ?? '') as String;

  String get fullName => '$firstName $lastName';
}
