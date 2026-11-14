import 'package:flutter/cupertino.dart';
import 'package:sanovault/features/log/log_page.dart';
import 'package:sanovault/features/home/home_page.dart';
import 'package:sanovault/features/medicines/medicines_page.dart';
import 'package:sanovault/features/more/more_page.dart';
import 'package:sanovault/features/reports/reports_page.dart';
import 'package:sanovault/session/session_scope.dart';
import 'package:sanovault/theme/sv_colors.dart';

class TabShell extends StatefulWidget {
  const TabShell({super.key});

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  late final CupertinoTabController _tabs = CupertinoTabController(
    initialIndex: 0,
  );
  int _needsReviewCount = 0;
  int _countGeneration = 0;

  Future<void> _refreshNeedsReviewCount() async {
    final generation = ++_countGeneration;
    try {
      final records = await SessionScope.of(context).api.healthRecords(
        tag: 'needs_review',
      );
      if (!mounted || generation != _countGeneration) return;
      setState(() => _needsReviewCount = records.length);
    } catch (_) {
      // Keep the last known count when the network is unavailable.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshNeedsReviewCount();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabs,
      backgroundColor: SvColors.groupedBackground,
      tabBar: CupertinoTabBar(
        backgroundColor: SvColors.surface,
        activeColor: SvColors.brandStrong,
        inactiveColor: SvColors.slate,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _needsReviewCount == 0
                ? const Icon(CupertinoIcons.doc_text)
                : _ReviewBadge(count: _needsReviewCount),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.capsule),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.ellipsis),
            label: 'More',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const HomePage();
              case 1:
                return ReportsPage(
                  onNeedsReviewCountChanged: _refreshNeedsReviewCount,
                  needsReviewCount: _needsReviewCount,
                );
              case 2:
                return const LogPage();
              case 3:
                return const MedicinesPage();
              default:
                return const MorePage();
            }
          },
        );
      },
    );
  }
}

class _ReviewBadge extends StatelessWidget {
  const _ReviewBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(CupertinoIcons.doc_text),
          Positioned(
            right: -10,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: SvColors.peach,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: SvColors.ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
}
