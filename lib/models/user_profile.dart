class UserProfile {
  final String id;
  final DateTime? updatedAt;
  final String? stripeCustomerId;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiresAt;
  final String? subscriptionPriceId;
  final int? dailyConversions;
  final int? monthlyConversions;
  final DateTime? lastConversionDate;

  UserProfile({
    required this.id,
    this.updatedAt,
    this.stripeCustomerId,
    this.subscriptionStatus,
    this.subscriptionExpiresAt,
    this.subscriptionPriceId,
    this.dailyConversions,
    this.monthlyConversions,
    this.lastConversionDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      subscriptionPriceId: json['subscription_price_id'] as String?,
      dailyConversions: json['daily_conversions'] as int?,
      monthlyConversions: json['monthly_conversions'] as int?,
      lastConversionDate: json['last_conversion_date'] != null
          ? DateTime.parse(json['last_conversion_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updated_at': updatedAt?.toIso8601String(),
      'stripe_customer_id': stripeCustomerId,
      'subscription_status': subscriptionStatus,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'subscription_price_id': subscriptionPriceId,
      'daily_conversions': dailyConversions,
      'monthly_conversions': monthlyConversions,
      'last_conversion_date': lastConversionDate?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    DateTime? updatedAt,
    String? stripeCustomerId,
    String? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    String? subscriptionPriceId,
    int? dailyConversions,
    int? monthlyConversions,
    DateTime? lastConversionDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      subscriptionPriceId: subscriptionPriceId ?? this.subscriptionPriceId,
      dailyConversions: dailyConversions ?? this.dailyConversions,
      monthlyConversions: monthlyConversions ?? this.monthlyConversions,
      lastConversionDate: lastConversionDate ?? this.lastConversionDate,
    );
  }

  bool get hasActiveSubscription {
    return subscriptionStatus == 'active' &&
           subscriptionExpiresAt != null &&
           subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get isSubscriptionExpired {
    return subscriptionExpiresAt != null &&
           subscriptionExpiresAt!.isBefore(DateTime.now());
  }

  bool get isFreeTier {
    return subscriptionStatus == null || 
           subscriptionStatus == 'inactive' || 
           isSubscriptionExpired;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, subscriptionStatus: $subscriptionStatus, expiresAt: $subscriptionExpiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
           other.id == id &&
           other.subscriptionStatus == subscriptionStatus &&
           other.subscriptionExpiresAt == subscriptionExpiresAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           subscriptionStatus.hashCode ^ 
           subscriptionExpiresAt.hashCode;
  }
}
