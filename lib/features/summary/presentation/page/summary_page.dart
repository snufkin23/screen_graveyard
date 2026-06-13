import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/presentation/blocs/summary/summary_cubit.dart';
import 'package:screen_graveyard/features/summary/presentation/widget/summary_empty_view.dart';
import 'package:screen_graveyard/features/summary/presentation/widget/summary_error_view.dart';
import 'package:screen_graveyard/features/summary/presentation/widget/summary_loaded_view.dart';
import 'package:screen_graveyard/features/summary/presentation/widget/summary_loading_view.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SummaryCubit>(
      create: (_) => getIt<SummaryCubit>()..load(),
      child: Builder(
        builder: (BuildContext context) {
          return CustomScaffold(
            usePadding: false,
            showAppBar: true,
            title: localization.todaysReport,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.history_rounded),
                onPressed: () => context.router.push(const HistoryRoute()),
              ),
            ],
            body: BlocBuilder<SummaryCubit, SummaryState>(
              builder: (BuildContext context, SummaryState state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const SummaryLoadingView(),
                  loaded: (DailySnapshot snapshot) => SummaryLoadedView(snapshot: snapshot),
                  empty: () => const SummaryEmptyView(),
                  error: (AppException error) => SummaryErrorView(error: error),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
