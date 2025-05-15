part of 'user_profile_bloc.dart';

abstract class UserProfileState {
  const UserProfileState();

  List<Object> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class UserProfileInitial extends UserProfileState {}
