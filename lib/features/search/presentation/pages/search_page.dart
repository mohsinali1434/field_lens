import 'dart:async';

import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_icons.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/constants/app_constants.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/animated_fade_slide.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/app_page_header.dart';
import 'package:field_lens/core/widgets/app_section_header.dart';
import 'package:field_lens/core/widgets/app_text_field.dart';
import 'package:field_lens/core/widgets/empty_state.dart';
import 'package:field_lens/core/widgets/error_view.dart';
import 'package:field_lens/core/widgets/loading_view.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Global search across local inspections and observations.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query, SearchBloc bloc) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () {
      bloc.add(SearchQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
        create: (_) => sl<SearchBloc>(),
        child: Builder(
          builder: (BuildContext context) {
            final bloc = context.read<SearchBloc>();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AppPageHeader(
                  title: 'Search',
                  subtitle: 'Find inspections, observations, and notes',
                  compact: true,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: AppTextField(
                    controller: _queryController,
                    hint: 'Search inspections, observations...',
                    prefixIcon: const Icon(AppIcons.search),
                    onChanged: (String value) => _onQueryChanged(value, bloc),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (BuildContext context, SearchState state) {
                      return switch (state) {
                        SearchInitial() => ListView(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.42,
                              child: const EmptyState(
                                title: 'Search your data',
                                message: 'Find inspections, observations, notes, and more.',
                                icon: AppIcons.search,
                              ),
                            ),
                          ],
                        ),
                        SearchLoading() => const LoadingView(
                          message: 'Searching...',
                        ),
                        SearchFailure(:final message) => ErrorView(
                          message: message,
                          onRetry: () => bloc.add(
                            SearchQueryChanged(_queryController.text),
                          ),
                        ),
                        SearchEmpty(:final query) => ListView(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.42,
                              child: EmptyState(
                                title: 'No results',
                                message: 'Nothing matched "$query".',
                                icon: AppIcons.search,
                              ),
                            ),
                          ],
                        ),
                        SearchLoaded(:final results, :final query) =>
                          _SearchResultsList(
                            query: query,
                            inspections: results.inspections,
                            observations: results.observations,
                          ),
                      };
                    },
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.query,
    required this.inspections,
    required this.observations,
  });

  final String query;
  final List<InspectionEntity> inspections;
  final List<ObservationEntity> observations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: <Widget>[
        if (inspections.isNotEmpty) ...<Widget>[
          AnimatedFadeSlide(
            child: AppSectionHeader(title: 'Inspections (${inspections.length})'),
          ),
          ...inspections.asMap().entries.map(
            (MapEntry<int, InspectionEntity> entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnimatedFadeSlide(
                index: entry.key + 1,
                child: AppCard(
                  elevated: true,
                  onTap: () =>
                      context.push(AppRoutes.inspectionDetailPath(entry.value.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(entry.value.title, style: context.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${entry.value.clientName} · ${entry.value.siteName}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (observations.isNotEmpty) ...<Widget>[
          AnimatedFadeSlide(
            index: inspections.length + 1,
            child: AppSectionHeader(title: 'Observations (${observations.length})'),
          ),
          ...observations.asMap().entries.map(
            (MapEntry<int, ObservationEntity> entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnimatedFadeSlide(
                index: inspections.length + entry.key + 2,
                child: AppCard(
                  elevated: true,
                  onTap: () => context.push(
                    AppRoutes.inspectionDetailPath(entry.value.inspectionId),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.value.title,
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        entry.value.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
