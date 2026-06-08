import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_permission/app_permission_cubit.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/custom_button.dart';
import 'package:screen_graveyard/core/widgets/custom_outlined_button.dart';
import 'package:screen_graveyard/localization/localization.dart';

class PermissionView extends StatelessWidget {
  const PermissionView({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final List<_PermissionItem> items = <_PermissionItem>[
      _PermissionItem(
        permission: AppPermission.camera,
        icon: Icons.camera_alt_rounded,
        title: localization.camera,
        description: localization.cameraDesc,
      ),
      _PermissionItem(
        permission: AppPermission.location,
        icon: Icons.location_on_rounded,
        title: localization.location,
        description: localization.locationDesc,
      ),
      _PermissionItem(
        permission: AppPermission.notification,
        icon: Icons.notifications_rounded,
        title: localization.notifications,
        description: localization.notificationsDesc,
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localization.allowPermissions,
            style: AppTextStyles.headlineMedium,
          ),
          8.verticalSpace,
          Text(
            localization.permissionsSubtitle,
            style: AppTextStyles.bodyMedium,
          ),
          32.verticalSpace,
          BlocBuilder<AppPermissionCubit, AppPermissionState>(
            builder: (BuildContext context, AppPermissionState state) {
              return Column(
                children: items
                    .map(
                      (_PermissionItem item) => _PermissionTile(
                        item: item,
                        status: state.statuses[item.permission] ??
                            AppPermissionStatus.initial,
                        onTap: () async {
                          final AppPermissionStatus result = await context
                              .read<AppPermissionCubit>()
                              .request(item.permission);
                          if (result.isPermanentlyDenied) {
                            if (!context.mounted) {
                              return;
                            }
                            await context
                                .read<AppPermissionCubit>()
                                .openSettings();
                          }
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
          32.verticalSpace,
          CustomButton.text(
            label: localization.continueButton,
            onPressed: onNext,
            expanded: true,
          ),
          12.verticalSpace,
          CustomOutlinedButton.text(
            label: localization.skipForNow,
            onPressed: onNext,
            expanded: true,
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.item,
    required this.status,
    required this.onTap,
  });

  final _PermissionItem item;
  final AppPermissionStatus status;
  final VoidCallback onTap;

  Color _color(BuildContext context) {
    switch (status) {
      case AppPermissionStatus.granted:
        return Colors.green;
      case AppPermissionStatus.denied:
      case AppPermissionStatus.permanentlyDenied:
      case AppPermissionStatus.restricted:
        return Colors.red;
      case AppPermissionStatus.initial:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case AppPermissionStatus.granted:
        return Icons.check_circle_rounded;
      case AppPermissionStatus.denied:
      case AppPermissionStatus.restricted:
        return Icons.cancel_rounded;
      case AppPermissionStatus.permanentlyDenied:
        return Icons.settings_rounded;
      case AppPermissionStatus.initial:
        return Icons.chevron_right_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: status.isGranted ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.md),
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: _color(context).withValues(alpha: 0.3),
          ),
          color: _color(context).withValues(alpha: 0.05),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: _color(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                item.icon,
                color: _color(context),
                size: AppSizes.iconMd,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.title, style: AppTextStyles.labelLarge),
                  4.verticalSpace,
                  Text(
                    item.description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              _statusIcon(),
              color: _color(context),
              size: AppSizes.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionItem {
  const _PermissionItem({
    required this.permission,
    required this.icon,
    required this.title,
    required this.description,
  });

  final AppPermission permission;
  final IconData icon;
  final String title;
  final String description;
}
