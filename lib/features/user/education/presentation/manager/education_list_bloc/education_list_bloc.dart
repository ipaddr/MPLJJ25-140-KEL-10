import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'education_list_event.dart';
part 'education_list_state.dart';

abstract class EducationListEvent {}

abstract class EducationListState {}

class EducationListInitial extends EducationListState {}

class EducationListBloc extends Bloc<EducationListEvent, EducationListState> {
  EducationListBloc() : super(EducationListInitial());
}
