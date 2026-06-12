import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_locale/app_locale_cubit.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLocaleCubit, AppLocale>(
      builder: (BuildContext context, AppLocale current) {
        return Container(
          padding: EdgeInsets.all(AppSizes.xs),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: AppLocale.values
                .map(
                  (AppLocale lang) => _LangOptionWidget(
                    lang: lang,
                    current: current,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _LangOptionWidget extends StatelessWidget {
  const _LangOptionWidget({
    required this.lang,
    required this.current,
  });

  final AppLocale lang;
  final AppLocale current;

  bool get _isSelected => current == lang;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: lang.displayName,
      child: GestureDetector(
        onTap: () => context.read<AppLocaleCubit>().setLocale(lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: AppSizes.xs),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: _isSelected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            boxShadow: _isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                lang.flag,
                style: AppTextStyles.labelSmall,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                lang.short,
                style: AppTextStyles.labelSmall.copyWith(
                  color: _isSelected ? context.colors.onPrimary : context.colors.onSurface,
                  fontWeight: _isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
