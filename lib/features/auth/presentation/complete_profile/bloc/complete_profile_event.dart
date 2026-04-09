import 'package:equatable/equatable.dart';

abstract class CompleteProfileEvent extends Equatable {
  const CompleteProfileEvent();
  @override
  List<Object?> get props => [];
}

class CompleteProfileSubmitted extends CompleteProfileEvent {
  final String username;
  final String address;
  final int municipalityId;

  const CompleteProfileSubmitted({
    required this.username,
    required this.address,
    required this.municipalityId,
  });

  @override
  List<Object?> get props => [username, address, municipalityId];
}
