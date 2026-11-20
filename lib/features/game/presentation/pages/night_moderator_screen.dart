import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/night_moderator_cubit.dart';
import '../cubit/night_moderator_state.dart';

/// Automated Night-1 Audio & Visual Moderator Screen ("الليدر الآلي — الليلة الأولى").
///
/// Enters a manual `NightOnePhase.standby` state after the final card is claimed
/// so players can place the phone in the center of the table and press
/// "بدء الليلة الأولى" when everyone is ready.
class NightModeratorScreen extends StatelessWidget {
  const NightModeratorScreen({
    super.key,
    this.onCompleted,
    this.audioPlayer,
  });

  /// Callback invoked when the Night Moderator finishes or is skipped.
  /// If null, pops the current route with `Navigator.of(context).maybePop()`.
  final VoidCallback? onCompleted;

  /// Optional custom [NightAudioPlayer] for testing.
  final NightAudioPlayer? audioPlayer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NightModeratorCubit>(
      create: (_) => NightModeratorCubit(audioPlayer: audioPlayer),
      child: _NightModeratorView(onCompleted: onCompleted),
    );
  }
}

class _NightModeratorView extends StatefulWidget {
  const _NightModeratorView({this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<_NightModeratorView> createState() => _NightModeratorViewState();
}

class _NightModeratorViewState extends State<_NightModeratorView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _didTriggerCompletion = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleCompleted() {
    if (_didTriggerCompletion || !mounted) {
      return;
    }
    _didTriggerCompletion = true;
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NightModeratorCubit, NightModeratorState>(
      listenWhen: (NightModeratorState previous, NightModeratorState current) =>
          !previous.isCompleted &&
          (current.isCompleted || current.phase == NightOnePhase.completed),
      listener: (BuildContext context, NightModeratorState state) {
        if (state.isCompleted || state.phase == NightOnePhase.completed) {
          _handleCompleted();
        }
      },
      builder: (BuildContext context, NightModeratorState state) {
        final NightModeratorCubit cubit = context.read<NightModeratorCubit>();
        final NightOnePhase phase = state.phase;

        if (phase == NightOnePhase.standby) {
          return _StandbyReadyContent(
            onStartNight: cubit.startNightSequence,
            onSkipToVault: cubit.skipNightModerator,
          );
        }

        final bool isMafiaWake = phase == NightOnePhase.mafiaWake;
        final bool isMorning = phase == NightOnePhase.everyoneWake;
        final Color activeAccent = isMafiaWake
            ? AppColors.syndicateCrimson
            : (isMorning ? AppColors.citizensTeam : AppColors.mutedSlateSilver);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Animated Pulsing Crimson Aura during `mafiaWake`
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (BuildContext context, Widget? _) {
                final double pulseAlpha = isMafiaWake
                    ? (0.14 + (_pulseAnimation.value * 0.22))
                    : (isMorning ? 0.12 : 0.04);

                return IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.15),
                        radius: 0.95,
                        colors: [
                          (isMafiaWake
                                  ? AppColors.syndicateCrimson
                                  : activeAccent)
                              .withValues(alpha: pulseAlpha),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top 2px countdown gauge
                LinearProgressIndicator(
                  value: state.phaseProgress,
                  minHeight: AppSpacing.countdownGaugeHeight,
                  backgroundColor: AppColors.charcoalCardTier2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMafiaWake
                        ? AppColors.syndicateCrimson
                        : AppColors.pureWhite,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.margin,
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Phase Stepper Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm + 4,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoalCardTier2,
                                    borderRadius: AppRadius.baseAll,
                                    border: Border.all(
                                      color: isMafiaWake
                                          ? AppColors.syndicateCrimson
                                          : AppColors.borderRaised,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.record_voice_over_outlined,
                                        size: 16,
                                        color: isMafiaWake
                                            ? AppColors.syndicateCrimson
                                            : AppColors.pureWhite,
                                      ),
                                      const SizedBox(width: AppSpacing.xs + 2),
                                      Text(
                                        'الليدر الآلي • الليلة الأولى',
                                        style:
                                            AppTypography.labelMedium.copyWith(
                                          color: AppColors.pureWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm + 2,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoalCardTier1,
                                    borderRadius: AppRadius.baseAll,
                                    border: Border.all(
                                      color: AppColors.borderResting,
                                    ),
                                  ),
                                  child: Text(
                                    'مرحلة ${phase.stepNumber} من ${NightOnePhase.totalSteps}',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: activeAccent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Centerpiece Pulsing Countdown Ring & Phase Icon
                            Center(
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (BuildContext context, Widget? child) {
                                  final double glowSpread = isMafiaWake
                                      ? (4.0 + (_pulseAnimation.value * 12.0))
                                      : 0.0;
                                  final double glowBlur = isMafiaWake
                                      ? (16.0 + (_pulseAnimation.value * 16.0))
                                      : 12.0;

                                  return Container(
                                    width: 168,
                                    height: 168,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.charcoalCardTier2,
                                      border: Border.all(
                                        color: isMafiaWake
                                            ? AppColors.syndicateCrimson
                                            : AppColors.borderRaised,
                                        width: isMafiaWake ? 2.0 : 1.0,
                                      ),
                                      boxShadow: isMafiaWake
                                          ? [
                                              BoxShadow(
                                                color: AppColors.crimsonGlow,
                                                blurRadius: glowBlur,
                                                spreadRadius: glowSpread,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 148,
                                          height: 148,
                                          child: CircularProgressIndicator(
                                            value: state.phaseProgress,
                                            strokeWidth: 4,
                                            backgroundColor:
                                                AppColors.charcoalCardTier1,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              isMafiaWake
                                                  ? AppColors.syndicateCrimson
                                                  : activeAccent,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _iconForPhase(phase),
                                              size: 28,
                                              color: isMafiaWake
                                                  ? AppColors.syndicateCrimson
                                                  : AppColors.pureWhite,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Text(
                                              '${state.remainingSeconds}',
                                              style: AppTypography.displayLarge
                                                  .copyWith(
                                                color: AppColors.pureWhite,
                                              ),
                                            ),
                                            Text(
                                              'ثانية',
                                              style: AppTypography.labelSmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Phase Title & Main Instruction Dossier Card
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: isMafiaWake
                                  ? AppElevation.tier3ActiveTarget(
                                      radius: AppRadius.xl,
                                    )
                                  : AppElevation.tier2RaisedPanel(
                                      radius: AppRadius.xl,
                                    ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    phase.title,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.labelLarge.copyWith(
                                      color: isMafiaWake
                                          ? AppColors.syndicateCrimson
                                          : activeAccent,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    phase.instruction,
                                    textAlign: TextAlign.center,
                                    style:
                                        AppTypography.headlineMedium.copyWith(
                                      color: AppColors.pureWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // 4-Step Progress Dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: NightOnePhase.activePhases.map(
                                (NightOnePhase item) {
                                  final bool isCurrent = item == phase;
                                  final bool isPassed =
                                      item.stepNumber < phase.stepNumber;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: isCurrent ? 28 : 10,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.fullAll,
                                      color: isCurrent
                                          ? AppColors.syndicateCrimson
                                          : (isPassed
                                              ? AppColors.pureWhite
                                              : AppColors.borderRaised),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Active Moderator Action Controls:
                            // 1. "إعادة الصوت" (replayCurrentPhaseAudio)
                            // 2. "إعادة من البداية" (restartNightModerator)
                            // 3. "تخطي" (skipNightModerator)
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      onPressed: cubit.replayCurrentPhaseAudio,
                                      icon: const Icon(
                                        Icons.volume_up_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('إعادة الصوت'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      onPressed: cubit.restartNightModerator,
                                      icon: const Icon(
                                        Icons.restart_alt_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('إعادة من البداية'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: cubit.skipNightModerator,
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  size: 22,
                                ),
                                label: const Text('تخطي'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  IconData _iconForPhase(NightOnePhase phase) {
    switch (phase) {
      case NightOnePhase.standby:
        return Icons.mic_none_rounded;
      case NightOnePhase.everyoneSleep:
        return Icons.nights_stay_outlined;
      case NightOnePhase.mafiaWake:
        return Icons.visibility_outlined;
      case NightOnePhase.mafiaSleep:
        return Icons.visibility_off_outlined;
      case NightOnePhase.everyoneWake:
      case NightOnePhase.completed:
        return Icons.wb_sunny_outlined;
    }
  }
}

/// Calm, focused Standby / Ready View rendered when `phase == NightOnePhase.standby`.
/// Allows players to set the phone in the center of the table before starting the voiceover.
class _StandbyReadyContent extends StatelessWidget {
  const _StandbyReadyContent({
    required this.onStartNight,
    required this.onSkipToVault,
  });

  final VoidCallback onStartNight;
  final VoidCallback onSkipToVault;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppElevation.tier1RestingCard(radius: AppRadius.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Crimson Microphone / Sound-Wave Icon Badge
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.crimsonOverlay,
                      border: Border.all(
                        color: AppColors.syndicateCrimson,
                        width: 1.5,
                      ),
                      boxShadow: const [AppElevation.activeCardGlow],
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      size: 40,
                      color: AppColors.syndicateCrimson,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Standby Title
                Text(
                  'اكتمل توزيع الأدوار بنجاح',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Standby Subtitle
                Text(
                  'ضع الهاتف في منتصف الطاولة، وعندما يكون الجميع جاهزاً اضغط لبدء الليلة الأولى',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.mutedSlateSilver,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Primary Large Crimson CTA Button: "بدء الليلة الأولى"
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: onStartNight,
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text('بدء الليلة الأولى'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Secondary Subtle Button: "تخطي والانتقال لخزنة التحقق"
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onSkipToVault,
                    icon: const Icon(Icons.skip_next_rounded, size: 20),
                    label: const Text('تخطي والانتقال لخزنة التحقق'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
