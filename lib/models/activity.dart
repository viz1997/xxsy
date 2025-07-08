class Activity {
  final int activityId;
  final String title;
  final DateTime time;
  final DateTime? endTime;
  final String location;
  final String? address;
  final String participants;
  final String price;
  final String imageUrl;
  final String? theme;
  final String? description;

  Activity({
    required this.activityId,
    required this.title,
    required this.time,
    this.endTime,
    required this.location,
    this.address,
    required this.participants,
    required this.price,
    required this.imageUrl,
    this.theme,
    this.description,
  });

  // Factory method to create an Activity from API data
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'] as int,
      title: json['activityName'] ?? json['title'] ?? '无标题',
      time: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      location: json['locationName'] ?? json['location'] ?? '未知地点',
      address: json['address'],
      participants: '${json['registrationNum'] ?? 0}/${json['maxParticipants'] ?? 0}',
      price: (json['cost'] ?? 0).toString(),
      imageUrl: json['posterUrl'] ?? json['imageUrl'] ?? '',
      theme: json['activityTheme'],
      description: json['description'],
    );
  }
}