import 'package:dio/dio.dart';
import '../../core/networking/api_client.dart';
import '../../core/networking/api_exception.dart';
import '../models/admin_user.dart';
import '../models/ai_chat_models.dart';
import '../models/auth_requests.dart';
import '../models/booking.dart';
import '../models/commission.dart';
import '../models/group.dart';
import '../models/guide.dart';
import '../models/guide_availability.dart';
import '../models/guide_booking.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/notification_model.dart';
import '../models/payment.dart';
import '../models/pending_registrations_response.dart';
import '../models/provider.dart';
import '../models/ratings.dart';
import '../models/service_slot.dart';
import '../models/tourist.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<T> _execute<T>(Future<Response> Function() call, T Function(dynamic data) mapper) async {
    try {
      final response = await call();
      return mapper(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // ==========================================
  // Public Auth & Search Endpoints
  // ==========================================

  Future<Tourist> registerTourist(RegisterTouristRequest request) {
    return _execute(
      () => _dio.post('auth/register/tourist', data: request.toJson()),
      (data) => Tourist.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Guide> registerGuide(RegisterGuideRequest request) {
    return _execute(
      () => _dio.post('auth/register/guide', data: request.toJson()),
      (data) => Guide.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Provider> registerProvider(RegisterProviderRequest request) {
    return _execute(
      () => _dio.post('auth/register/provider', data: request.toJson()),
      (data) => Provider.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<LoginResponse> login(LoginRequest request) {
    return _execute(
      () => _dio.post('auth/login', data: request.toJson()),
      (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) {
    return _execute(
      () => _dio.post('auth/forgot-password', data: request.toJson()),
      (data) => MessageResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<MessageResponse> resetPassword(ResetPasswordRequest request) {
    return _execute(
      () => _dio.post('auth/reset-password', data: request.toJson()),
      (data) => MessageResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<ServiceSlot>> searchSlots({
    String? category,
    String? origin,
    String? destination,
    String? locationName,
    String? dateFrom,
    String? dateTo,
    double? minPrice,
    double? maxPrice,
  }) {
    final query = <String, dynamic>{};
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (origin != null && origin.isNotEmpty) query['origin'] = origin;
    if (destination != null && destination.isNotEmpty) query['destination'] = destination;
    if (locationName != null && locationName.isNotEmpty) query['locationName'] = locationName;
    if (dateFrom != null && dateFrom.isNotEmpty) query['dateFrom'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) query['dateTo'] = dateTo;
    if (minPrice != null) query['minPrice'] = minPrice;
    if (maxPrice != null) query['maxPrice'] = maxPrice;

    return _execute(
      () => _dio.get('slots/search', queryParameters: query),
      (data) => (data as List).map((e) => ServiceSlot.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ServiceSlot> getSlotById(int id) {
    return _execute(
      () => _dio.get('slots/$id'),
      (data) => ServiceSlot.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<GuideAvailability>> searchGuideAvailability({
    String? dateFrom,
    String? dateTo,
    String? location,
  }) {
    final query = <String, dynamic>{};
    if (dateFrom != null) query['dateFrom'] = dateFrom;
    if (dateTo != null) query['dateTo'] = dateTo;
    if (location != null) query['location'] = location;

    return _execute(
      () => _dio.get('guide-availability/search', queryParameters: query),
      (data) => (data as List).map((e) => GuideAvailability.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<GuideAvailability>> getGuideAvailabilityByGuideId(int guideId) {
    return _execute(
      () => _dio.get('guide-availability/guide/$guideId'),
      (data) => (data as List).map((e) => GuideAvailability.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<Guide>> getGuides({bool? available}) {
    final query = <String, dynamic>{};
    if (available != null) query['available'] = available;

    return _execute(
      () => _dio.get('guides', queryParameters: query),
      (data) => (data as List).map((e) => Guide.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<Guide> getGuideById(int id) {
    return _execute(
      () => _dio.get('guides/$id'),
      (data) => Guide.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<GuideRating>> getRatingsForGuide(int guideId) {
    return _execute(
      () => _dio.get('ratings/guide/$guideId'),
      (data) => (data as List).map((e) => GuideRating.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<ServiceRating>> getRatingsForProvider(int providerId) {
    return _execute(
      () => _dio.get('ratings/provider/$providerId'),
      (data) => (data as List).map((e) => ServiceRating.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // ==========================================
  // Generic Authenticated Endpoints (All Roles)
  // ==========================================

  Future<MessageResponse> changePassword(ChangePasswordRequest request) {
    return _execute(
      () => _dio.put('auth/change-password', data: request.toJson()),
      (data) => MessageResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<NotificationModel>> getNotifications(int userId) {
    return _execute(
      () => _dio.get('notifications/user/$userId'),
      (data) => (data as List).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<CountResponse> getUnreadNotificationCount(int userId) {
    return _execute(
      () => _dio.get('notifications/user/$userId/unread-count'),
      (data) => CountResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<NotificationModel> markNotificationAsRead(int id) {
    return _execute(
      () => _dio.put('notifications/$id/read'),
      (data) => NotificationModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==========================================
  // TOURIST Endpoints
  // ==========================================

  Future<Tourist> getTouristProfile(int id) {
    return _execute(
      () => _dio.get('tourists/$id'),
      (data) => Tourist.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Tourist> updateTouristProfile(int id, UpdateTouristRequest request) {
    return _execute(
      () => _dio.put('tourists/$id', data: request.toJson()),
      (data) => Tourist.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteTouristAccount(int id) {
    return _execute(
      () => _dio.delete('tourists/$id'),
      (_) {},
    );
  }

  Future<Booking> createBooking(BookingRequest request) {
    return _execute(
      () => _dio.post('bookings', data: request.toJson()),
      (data) => Booking.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Booking>> getBookingsForTourist(int touristId) {
    return _execute(
      () => _dio.get('bookings/tourist/$touristId'),
      (data) => (data as List).map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<Booking> updateBookingStatus(int id, StatusRequest request) {
    return _execute(
      () => _dio.put('bookings/$id/status', data: request.toJson()),
      (data) => Booking.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Payment> createPayment(PaymentRequest request) {
    return _execute(
      () => _dio.post('payments', data: request.toJson()),
      (data) => Payment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Payment> getPaymentById(int id) {
    return _execute(
      () => _dio.get('payments/$id'),
      (data) => Payment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Payment>> getPaymentsForBooking(int bookingId) {
    return _execute(
      () => _dio.get('payments/booking/$bookingId'),
      (data) => (data as List).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<GuideBooking> createGuideBooking(GuideBookingRequest request) {
    return _execute(
      () => _dio.post('guide-bookings', data: request.toJson()),
      (data) => GuideBooking.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<GuideBooking>> getGuideBookingsForTourist(int touristId) {
    return _execute(
      () => _dio.get('guide-bookings/tourist/$touristId'),
      (data) => (data as List).map((e) => GuideBooking.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<GuideRating> submitGuideRating(GuideRatingRequest request) {
    return _execute(
      () => _dio.post('ratings/guide', data: request.toJson()),
      (data) => GuideRating.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ServiceRating> submitServiceRating(ServiceRatingRequest request) {
    return _execute(
      () => _dio.post('ratings/service', data: request.toJson()),
      (data) => ServiceRating.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Group> createGroup(GroupCreateRequest request) {
    return _execute(
      () => _dio.post('groups', data: request.toJson()),
      (data) => Group.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Group> joinGroup(JoinGroupRequest request) {
    return _execute(
      () => _dio.post('groups/join', data: request.toJson()),
      (data) => Group.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Group> getGroupById(int id) {
    return _execute(
      () => _dio.get('groups/$id'),
      (data) => Group.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Group>> getGroupsForTourist(int touristId) {
    return _execute(
      () => _dio.get('groups/tourist/$touristId'),
      (data) => (data as List).map((e) => Group.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<GroupMember>> getGroupMembers(int id) {
    return _execute(
      () => _dio.get('groups/$id/members'),
      (data) => (data as List).map((e) => GroupMember.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<void> leaveOrRemoveGroupMember(int id, int touristId) {
    return _execute(
      () => _dio.delete('groups/$id/members/$touristId'),
      (_) {},
    );
  }

  Future<Group> linkGroupBooking(int id, GroupBookingRequest request) {
    return _execute(
      () => _dio.post('groups/$id/booking', data: request.toJson()),
      (data) => Group.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<GroupMember> markGroupMemberPaid(int id, int touristId) {
    return _execute(
      () => _dio.put('groups/$id/members/$touristId/paid'),
      (data) => GroupMember.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<GroupMessage>> getGroupMessages(int id) {
    return _execute(
      () => _dio.get('groups/$id/messages'),
      (data) => (data as List).map((e) => GroupMessage.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<GroupMessage> sendGroupMessage(int id, MessageRequest request) {
    return _execute(
      () => _dio.post('groups/$id/messages', data: request.toJson()),
      (data) => GroupMessage.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<LocationModel> getGuideLocation(int id) {
    return _execute(
      () => _dio.get('guides/$id/location'),
      (data) => LocationModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AiChatResponse> sendAiChatMessage(AiChatRequest request) {
    return _execute(
      () => _dio.post('ai/chat', data: request.toJson()),
      (data) => AiChatResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==========================================
  // TOUR_GUIDE Endpoints
  // ==========================================

  Future<Guide> updateGuideProfile(int id, UpdateGuideRequest request) {
    return _execute(
      () => _dio.put('guides/$id', data: request.toJson()),
      (data) => Guide.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteGuideAccount(int id) {
    return _execute(
      () => _dio.delete('guides/$id'),
      (_) {},
    );
  }

  Future<GuideAvailability> createGuideAvailability(CreateGuideAvailabilityRequest request) {
    return _execute(
      () => _dio.post('guide-availability', data: request.toJson()),
      (data) => GuideAvailability.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<GuideAvailability> updateGuideAvailability(int id, UpdateGuideAvailabilityRequest request) {
    return _execute(
      () => _dio.put('guide-availability/$id', data: request.toJson()),
      (data) => GuideAvailability.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteGuideAvailability(int id) {
    return _execute(
      () => _dio.delete('guide-availability/$id'),
      (_) {},
    );
  }

  Future<LocationModel> updateGuideLocation(int id, UpdateLocationRequest request) {
    return _execute(
      () => _dio.put('guides/$id/location', data: request.toJson()),
      (data) => LocationModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<GuideBooking>> getGuideBookingsForGuide(int guideId) {
    return _execute(
      () => _dio.get('guide-bookings/guide/$guideId'),
      (data) => (data as List).map((e) => GuideBooking.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<GuideBooking> updateGuideBookingStatus(int id, UpdateGuideBookingStatusRequest request) {
    return _execute(
      () => _dio.put('guide-bookings/$id/status', data: request.toJson()),
      (data) => GuideBooking.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<GuideBooking> markGuideBookingPaymentReceived(int id) {
    return _execute(
      () => _dio.put('guide-bookings/$id/payment-received'),
      (data) => GuideBooking.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==========================================
  // SERVICE_PROVIDER Endpoints
  // ==========================================

  Future<Provider> getProviderById(int id) {
    return _execute(
      () => _dio.get('providers/$id'),
      (data) => Provider.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Provider> updateProviderProfile(int id, UpdateProviderRequest request) {
    return _execute(
      () => _dio.put('providers/$id', data: request.toJson()),
      (data) => Provider.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteProviderAccount(int id) {
    return _execute(
      () => _dio.delete('providers/$id'),
      (_) {},
    );
  }

  Future<List<Commission>> getCommissionsForProvider(int id) {
    return _execute(
      () => _dio.get('providers/$id/commissions'),
      (data) => (data as List).map((e) => Commission.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<Payment>> getPaymentsForProvider(
    int id, {
    String? dateFrom,
    String? dateTo,
    String? status,
  }) {
    final query = <String, dynamic>{};
    if (dateFrom != null) query['dateFrom'] = dateFrom;
    if (dateTo != null) query['dateTo'] = dateTo;
    if (status != null) query['status'] = status;

    return _execute(
      () => _dio.get('providers/$id/payments', queryParameters: query),
      (data) => (data as List).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ServiceSlot> createSlot(CreateServiceSlotRequest request) {
    return _execute(
      () => _dio.post('slots', data: request.toJson()),
      (data) => ServiceSlot.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ServiceSlot> updateSlot(int id, UpdateServiceSlotRequest request) {
    return _execute(
      () => _dio.put('slots/$id', data: request.toJson()),
      (data) => ServiceSlot.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteSlot(int id) {
    return _execute(
      () => _dio.delete('slots/$id'),
      (_) {},
    );
  }

  Future<List<ServiceSlot>> getSlotsForProvider(int providerId) {
    return _execute(
      () => _dio.get('slots/provider/$providerId'),
      (data) => (data as List).map((e) => ServiceSlot.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // ==========================================
  // ADMIN Endpoints
  // ==========================================

  Future<PendingRegistrationsResponse> getPendingRegistrations() {
    return _execute(
      () => _dio.get('admin/pending-registrations'),
      (data) => PendingRegistrationsResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Provider> verifyProvider(int id, VerifyRequest request) {
    return _execute(
      () => _dio.put('admin/providers/$id/verify', data: request.toJson()),
      (data) => Provider.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Guide> verifyGuide(int id, VerifyRequest request) {
    return _execute(
      () => _dio.put('admin/guides/$id/verify', data: request.toJson()),
      (data) => Guide.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<AdminUser>> getAdminUsers({String? role, String? status}) {
    final query = <String, dynamic>{};
    if (role != null && role.isNotEmpty) query['role'] = role;
    if (status != null && status.isNotEmpty) query['status'] = status;

    return _execute(
      () => _dio.get('admin/users', queryParameters: query),
      (data) => (data as List).map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<AdminUser> updateUserStatus(int id, UpdateUserStatusRequest request) {
    return _execute(
      () => _dio.put('admin/users/$id/status', data: request.toJson()),
      (data) => AdminUser.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Payment>> getAdminPayments({
    String? dateFrom,
    String? dateTo,
    String? status,
    String? method,
  }) {
    final query = <String, dynamic>{};
    if (dateFrom != null) query['dateFrom'] = dateFrom;
    if (dateTo != null) query['dateTo'] = dateTo;
    if (status != null) query['status'] = status;
    if (method != null) query['method'] = method;

    return _execute(
      () => _dio.get('admin/payments', queryParameters: query),
      (data) => (data as List).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<Commission>> getAdminCommissions({
    String? dateFrom,
    String? dateTo,
    String? settlementStatus,
  }) {
    final query = <String, dynamic>{};
    if (dateFrom != null) query['dateFrom'] = dateFrom;
    if (dateTo != null) query['dateTo'] = dateTo;
    if (settlementStatus != null) query['settlementStatus'] = settlementStatus;

    return _execute(
      () => _dio.get('admin/commissions', queryParameters: query),
      (data) => (data as List).map((e) => Commission.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<Commission> settleCommission(int id) {
    return _execute(
      () => _dio.put('admin/commissions/$id/settle'),
      (data) => Commission.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<RevenueSummary> getRevenueSummary({String? dateFrom, String? dateTo, String? from, String? to}) {
    final query = <String, dynamic>{};
    final f = dateFrom ?? from;
    final t = dateTo ?? to;
    if (f != null) query['dateFrom'] = f;
    if (t != null) query['dateTo'] = t;

    return _execute(
      () => _dio.get('admin/reports/revenue-summary', queryParameters: query),
      (data) => RevenueSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<BookingsSummary> getBookingsSummary({String? dateFrom, String? dateTo, String? from, String? to}) {
    final query = <String, dynamic>{};
    final f = dateFrom ?? from;
    final t = dateTo ?? to;
    if (f != null) query['dateFrom'] = f;
    if (t != null) query['dateTo'] = t;

    return _execute(
      () => _dio.get('admin/reports/bookings-summary', queryParameters: query),
      (data) => BookingsSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<CommissionSummary> getCommissionSummary({String? dateFrom, String? dateTo, String? from, String? to}) {
    final query = <String, dynamic>{};
    final f = dateFrom ?? from;
    final t = dateTo ?? to;
    if (f != null) query['dateFrom'] = f;
    if (t != null) query['dateTo'] = t;

    return _execute(
      () => _dio.get('admin/reports/commission-summary', queryParameters: query),
      (data) => CommissionSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==========================================
  // Compatibility Aliases for Calling Screens
  // ==========================================

  Future<void> deleteTouristProfile(int id) => deleteTouristAccount(id);

  Future<List<Booking>> getTouristBookings(int id) => getBookingsForTourist(id);

  Future<List<GuideBooking>> getTouristGuideBookings(int id) => getGuideBookingsForTourist(id);

  Future<List<Group>> getTouristGroups(int id) => getGroupsForTourist(id);

  Future<List<GuideBooking>> getGuideBookings(int id) => getGuideBookingsForGuide(id);

  Future<List<AdminUser>> getUsers({String? role, String? status}) =>
      getAdminUsers(role: role, status: status);

  Future<List<Payment>> getAllPayments({
    String? status,
    String? method,
    String? from,
    String? to,
  }) =>
      getAdminPayments(
        dateFrom: from,
        dateTo: to,
        status: status,
        method: method,
      );

  Future<List<Commission>> getAllCommissions({
    String? status,
    String? from,
    String? to,
  }) =>
      getAdminCommissions(
        dateFrom: from,
        dateTo: to,
        settlementStatus: status,
      );

  Future<List<ServiceSlot>> getActiveSlots() => searchSlots();

  Future<List<ServiceSlot>> getSlots() => searchSlots();

  Future<List<Guide>> getActiveGuides() => getGuides(available: true);

  Future<List<GuideAvailability>> getGuideAvailability(int guideId) =>
      getGuideAvailabilityByGuideId(guideId);

  Future<List<GuideRating>> getGuideRatings(int guideId) => getRatingsForGuide(guideId);

  Future<GroupMessage> sendMessageToGroup(int groupId, MessageRequest req) =>
      sendGroupMessage(groupId, req);

  Future<Group> linkBookingToGroup(int groupId, GroupBookingRequest req) =>
      linkGroupBooking(groupId, req);

  Future<void> leaveGroup(int groupId, int touristId) =>
      leaveOrRemoveGroupMember(groupId, touristId);

  Future<AiChatResponse> chatWithAi(AiChatRequest request) => sendAiChatMessage(request);
}
