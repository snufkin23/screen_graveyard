import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/history/domain/entities/weekly_stats.dart';
import 'package:screen_graveyard/features/history/presentation/blocs/history/history_cubit.dart';
import 'package:screen_graveyard/features/history/presentation/widget/history_empty_view.dart';
import 'package:screen_graveyard/features/history/presentation/widget/history_error_view.dart';
import 'package:screen_graveyard/features/history/presentation/widget/history_loaded_view.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryCubit>(
      create: (_) => getIt<HistoryCubit>()..load(),
      child: Builder(
        builder: (BuildContext context) {
          return CustomScaffold(
            usePadding: false,
            showAppBar: true,
            title: localization.historyTitle,
            body: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (BuildContext context, HistoryState state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loaded: (WeeklyStats stats) => HistoryLoadedView(stats: stats),
                  empty: () => const HistoryEmptyView(),
                  error: (AppException error) => HistoryErrorView(error: error),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
