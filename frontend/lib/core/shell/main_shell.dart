import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ボトムナビゲーションバーを持つシェルウィジェット
class MainShell extends StatelessWidget {
  /// MainShellのコンストラクタ
  const MainShell({required this.navigationShell, super.key});

  /// go_router が管理するナビゲーションシェル
  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.sports_esports_outlined),
      selectedIcon: Icon(Icons.sports_esports),
      label: 'ゲーム',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'マップ',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: '履歴',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'プロフィール',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected:
            (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
        destinations: _destinations,
      ),
    );
  }
}
