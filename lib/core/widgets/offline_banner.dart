import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../connectivity/connectivity_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: status == ConnectivityStatus.disconnected
              ? Offset.zero
              : const Offset(0, -1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: status == ConnectivityStatus.disconnected ? 1.0 : 0.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.warning,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.black),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'You are offline',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
