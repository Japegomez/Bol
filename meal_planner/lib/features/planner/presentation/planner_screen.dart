import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_targets.dart';
import 'package:meal_planner/features/planner/domain/planner_constants.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/planner/presentation/planner_share.dart';
import 'package:meal_planner/features/planner/presentation/widgets/meal_slot.dart';
import 'package:meal_planner/features/planner/presentation/widgets/recipe_palette.dart';
import 'package:share_plus/share_plus.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  bool _paletteOpen = false;

  final _scrollController = ScrollController();
  final _listKey = GlobalKey();
  Timer? _autoScrollTimer;
  int _autoScrollDirection = 0;

  static const _edgeZone = 90.0;
  static const _scrollStep = 14.0;

  void _togglePalette() => setState(() => _paletteOpen = !_paletteOpen);

  @override
  void dispose() {
    _stopAutoScroll();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDragUpdate(Offset globalPosition) {
    final renderBox =
        _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final top = renderBox.localToGlobal(Offset.zero).dy;
    final bottom = top + renderBox.size.height;
    final y = globalPosition.dy;

    if (y < top + _edgeZone) {
      _startAutoScroll(-1);
    } else if (y > bottom - _edgeZone) {
      _startAutoScroll(1);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(int direction) {
    if (_autoScrollTimer != null && _autoScrollDirection == direction) return;
    _stopAutoScroll();
    _autoScrollDirection = direction;
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final next = (position.pixels + direction * _scrollStep)
          .clamp(position.minScrollExtent, position.maxScrollExtent);
      if (next == position.pixels) {
        _stopAutoScroll();
        return;
      }
      _scrollController.jumpTo(next);
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollDirection = 0;
  }

  String _planText(List<SlotItem> slots) {
    final localeName = Localizations.localeOf(context).languageCode;
    return formatWeeklyPlanForShare(
      l10n: context.l10n,
      weekStart: ref.read(currentWeekProvider),
      localeName: localeName,
      slots: slots,
    );
  }

  Future<void> _copyPlan(List<SlotItem> slots) async {
    if (!weeklyPlanHasMeals(slots)) return;

    await Clipboard.setData(ClipboardData(text: _planText(slots)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.plannerCopied)),
    );
  }

  Future<void> _sharePlan(List<SlotItem> slots) async {
    if (!weeklyPlanHasMeals(slots)) return;

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 1, 1);

    await Share.share(_planText(slots), sharePositionOrigin: origin);
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = ref.watch(currentWeekProvider);
    final planAsync = ref.watch(weeklyPlanProvider);
    final slotsAsync = ref.watch(planSlotsProvider);
    final l10n = context.l10n;
    final slots = slotsAsync.valueOrNull ?? const <SlotItem>[];
    final hasMeals = weeklyPlanHasMeals(slots);

    final screenWidth = MediaQuery.of(context).size.width;
    final paletteWidth = (screenWidth * 0.55).clamp(190.0, 280.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plannerTitle),
        actions: [
          IconButton(
            onPressed: hasMeals ? () => _copyPlan(slots) : null,
            icon: const Icon(Icons.copy_outlined),
            tooltip: l10n.copyPlannerTooltip,
          ),
          IconButton(
            onPressed: hasMeals ? () => _sharePlan(slots) : null,
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.sharePlannerTooltip,
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const PlannerSkeleton(),
        error: (error, _) => Center(child: Text(l10n.errorWithMessage('$error'))),
        data: (_) => Stack(
          children: [
            Column(
              children: [
                KeyedSubtree(
                  key: OnboardingTargets.keyFor(
                    OnboardingTarget.plannerWeekHeader,
                  ),
                  child: _WeekNavigationHeader(weekStart: weekStart),
                ),
                Expanded(
                  child: slotsAsync.when(
                    loading: () =>
                        const PlannerSkeleton(showWeekHeader: false),
                    error: (error, _) =>
                        Center(child: Text(l10n.errorWithMessage('$error'))),
                    data: (slots) => _VerticalPlanner(
                      listKey: _listKey,
                      scrollController: _scrollController,
                      weekStart: weekStart,
                      slots: slots,
                      onDragUpdate: _onDragUpdate,
                      onDragEnd: _stopAutoScroll,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              right: _paletteOpen ? 0 : -paletteWidth,
              width: paletteWidth,
              child: RecipePalette(
                onClose: _togglePalette,
                onDragUpdate: _onDragUpdate,
                onDragEnd: _stopAutoScroll,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _paletteOpen
          ? null
          : FloatingActionButton(
              key: OnboardingTargets.keyFor(OnboardingTarget.plannerFab),
              onPressed: _togglePalette,
              tooltip: l10n.showRecipeBookTooltip,
              child: const Icon(Icons.menu_book),
            ),
    );
  }
}

class _WeekNavigationHeader extends ConsumerWidget {
  const _WeekNavigationHeader({required this.weekStart});

  final DateTime weekStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrentWeek = weekStart == startOfIsoWeek(DateTime.now());
    final localeName = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(currentWeekProvider.notifier).state =
                  weekStart.subtract(const Duration(days: 7));
            },
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  formatWeekRange(weekStart, localeName),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (isCurrentWeek)
                  Text(
                    l10n.thisWeek,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(currentWeekProvider.notifier).state =
                  weekStart.add(const Duration(days: 7));
            },
          ),
        ],
      ),
    );
  }
}

class _VerticalPlanner extends StatelessWidget {
  const _VerticalPlanner({
    required this.listKey,
    required this.scrollController,
    required this.weekStart,
    required this.slots,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final Key listKey;
  final ScrollController scrollController;
  final DateTime weekStart;
  final List<SlotItem> slots;
  final void Function(Offset globalPosition) onDragUpdate;
  final VoidCallback onDragEnd;

  List<SlotItem> _slotsForCell(int dayOfWeek, String mealType) {
    return slots
        .where(
          (item) =>
              item.slot.dayOfWeek == dayOfWeek && item.slot.mealType == mealType,
        )
        .toList()
      ..sort((a, b) => a.slot.position.compareTo(b.slot.position));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: listKey,
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayOfWeek = index + 1;
        final date = weekStart.add(Duration(days: index));
        return _DayCard(
          dayOfWeek: dayOfWeek,
          date: date,
          slotsForCell: _slotsForCell,
          onDragUpdate: onDragUpdate,
          onDragEnd: onDragEnd,
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayOfWeek,
    required this.date,
    required this.slotsForCell,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final int dayOfWeek;
  final DateTime date;
  final List<SlotItem> Function(int dayOfWeek, String mealType) slotsForCell;
  final void Function(Offset globalPosition) onDragUpdate;
  final VoidCallback onDragEnd;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final colorScheme = Theme.of(context).colorScheme;
    final localeName = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    final todayBackground = isToday
        ? Color.lerp(
            colorScheme.surface,
            colorScheme.primary,
            colorScheme.brightness == Brightness.light ? 0.28 : 0.38,
          )
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: todayBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday
            ? BorderSide(color: colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      elevation: isToday ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  formatDayHeader(date, localeName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday ? colorScheme.primary : null,
                      ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.today,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            for (final mealType in MealType.all)
              MealSlot(
                dayOfWeek: dayOfWeek,
                mealType: mealType,
                slots: slotsForCell(dayOfWeek, mealType),
                onDragUpdate: onDragUpdate,
                onDragEnd: onDragEnd,
              ),
          ],
        ),
      ),
    );
  }
}
