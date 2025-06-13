import 'dart:convert';

import 'package:camping_app/bloc/camp_list_event.dart';
import 'package:camping_app/bloc/camp_list_state.dart';
import 'package:bloc/bloc.dart';
import 'package:camping_app/models/camp_site.dart';
import 'package:camping_app/models/network/api_response.dart';

import '../configs/strings.dart';
import '../resources/network/camp_list_repository.dart';

class CampListBloc extends Bloc<CampListEvent, CampListState> {
  final CampListRepository campListRepository;

  CampListBloc(this.campListRepository) : super(CampListStateNotStarted());

  @override
  Stream<CampListState> mapEventToState(CampListEvent event) async* {
    if (event is CampListEventFetch) {
      yield* _mapFetchToState(event);
    }
  }

  Stream<CampListState> _mapFetchToState(CampListEventFetch event) async* {
    yield CampListStateLoading();
    try {
      ApiResponse apiResponse = await campListRepository.fetchCampList();

      if (apiResponse.status == Status.COMPLETED) {
        final List<CampSite> response =
        (apiResponse.data as List).map((item) => CampSite.fromJson(item)).toList();
        yield CampListStateSuccess(response);
      } else if (apiResponse.status == Status.ERROR) {
        yield CampListStateFailed(apiResponse!.apiError!.message!);
      }
    } catch (e) {
      yield CampListStateFailed(Strings.serverError);
    }
  }
}
