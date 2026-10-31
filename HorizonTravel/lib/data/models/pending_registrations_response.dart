export 'admin_user.dart' show VerifyRequest;
import 'guide.dart';
import 'provider.dart';

class PendingRegistrationsResponse {
  final List<Provider> providers;
  final List<Guide> guides;

  PendingRegistrationsResponse({
    this.providers = const [],
    this.guides = const [],
  });

  List<Provider> get pendingProviders => providers;
  List<Guide> get pendingGuides => guides;

  factory PendingRegistrationsResponse.fromJson(Map<String, dynamic> json) {
    var pList = <Provider>[];
    if (json['providers'] is List) {
      pList = (json['providers'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Provider.fromJson(e))
          .toList();
    }

    var gList = <Guide>[];
    if (json['guides'] is List) {
      gList = (json['guides'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Guide.fromJson(e))
          .toList();
    }

    return PendingRegistrationsResponse(
      providers: pList,
      guides: gList,
    );
  }

  Map<String, dynamic> toJson() => {
        'providers': providers.map((e) => e.toJson()).toList(),
        'guides': guides.map((e) => e.toJson()).toList(),
      };
}
