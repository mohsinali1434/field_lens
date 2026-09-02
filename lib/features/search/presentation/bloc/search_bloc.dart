import 'package:equatable/equatable.dart';
import 'package:field_lens/features/search/domain/usecases/search_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => <Object?>[];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded(this.results, this.query);

  final SearchResults results;
  final String query;

  @override
  List<Object?> get props => <Object?>[results, query];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class SearchFailure extends SearchState {
  const SearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Debounced local search across inspections and observations.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchData searchData})
    : _searchData = searchData,
      super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  final SearchData _searchData;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());
    final result = await _searchData(query);
    result.fold(
      onSuccess: (SearchResults results) {
        if (results.isEmpty) {
          emit(SearchEmpty(query));
        } else {
          emit(SearchLoaded(results, query));
        }
      },
      onFailure: (failure) => emit(SearchFailure(failure.message)),
    );
  }
}
