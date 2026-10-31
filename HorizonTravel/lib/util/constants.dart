class Role {
  static const String tourist = 'TOURIST';
  static const String tourGuide = 'TOUR_GUIDE';
  static const String serviceProvider = 'SERVICE_PROVIDER';
  static const String admin = 'ADMIN';
}

class UserStatus {
  static const String active = 'ACTIVE';
  static const String pendingVerification = 'PENDING_VERIFICATION';
  static const String suspended = 'SUSPENDED';
  static const String revoked = 'REVOKED';
}

class VerificationStatus {
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
}

class BookingStatus {
  static const String pending = 'PENDING';
  static const String confirmed = 'CONFIRMED';
  static const String cancelled = 'CANCELLED';
  static const String completed = 'COMPLETED';
}

class PaymentStatus {
  static const String unpaid = 'UNPAID';
  static const String paid = 'PAID';
  static const String refunded = 'REFUNDED';
}

class PaymentTxStatus {
  static const String pending = 'PENDING';
  static const String success = 'SUCCESS';
  static const String failed = 'FAILED';
  static const String refunded = 'REFUNDED';
}

class PaymentMethod {
  static const String card = 'CARD';
  static const String creditCard = 'CREDIT_CARD';
  static const String mobileBanking = 'MOBILE_BANKING';
  static const String cash = 'CASH';
}

class GuideBookingStatus {
  static const String requested = 'REQUESTED';
  static const String accepted = 'ACCEPTED';
  static const String declined = 'DECLINED';
  static const String completed = 'COMPLETED';
}

class ServiceCategory {
  static const String bus = 'BUS';
  static const String microbus = 'MICROBUS';
  static const String launch = 'LAUNCH';
  static const String train = 'TRAIN';
  static const String airplane = 'AIRPLANE';
  static const String ship = 'SHIP';
  static const String hotel = 'HOTEL';
  static const String resort = 'RESORT';
  static const String conventionCenter = 'CONVENTION_CENTER';
  static const String buffet = 'BUFFET';
  static const String amusementPark = 'AMUSEMENT_PARK';

  static const List<String> all = [
    hotel,
    resort,
    bus,
    train,
    airplane,
    amusementPark,
    buffet,
    microbus,
    launch,
    ship,
    conventionCenter,
  ];
}

class SlotStatus {
  static const String open = 'OPEN';
  static const String full = 'FULL';
  static const String closed = 'CLOSED';
  static const String cancelled = 'CANCELLED';
}

class AvailabilityStatus {
  static const String open = 'OPEN';
  static const String booked = 'BOOKED';
  static const String cancelled = 'CANCELLED';
}

class GroupMemberStatus {
  static const String invited = 'INVITED';
  static const String joined = 'JOINED';
  static const String declined = 'DECLINED';
}

class SettlementStatus {
  static const String pending = 'PENDING';
  static const String settled = 'SETTLED';
}

class AiActionType {
  static const String filterSlots = 'FILTER_SLOTS';
  static const String recommendBundle = 'RECOMMEND_BUNDLE';
  static const String recommendGroupBundle = 'RECOMMEND_GROUP_BUNDLE';
  static const String browseGuides = 'BROWSE_GUIDES';
  static const String none = 'NONE';
}
