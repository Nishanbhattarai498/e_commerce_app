class Review {
  final int id;
  final int productId;
  final String userId;
  final int rating;
  final String? title;
  final String? content;
  final DateTime createdAt;
  final String? userFullName;
  final String? userAvatarUrl;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.title,
    this.content,
    required this.createdAt,
    this.userFullName,
    this.userAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      rating: json['rating'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userFullName: json['user_full_name'],
      userAvatarUrl: json['user_avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
