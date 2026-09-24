import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/mission/presentation/store/mission_sheet_layout_store.dart';

/// シートに並べる 1 スポットの表示内容
@immutable
class MissionSheetSpot {
  /// [MissionSheetSpot] を作成する
  const MissionSheetSpot({
    required this.referenceImageBase64,
    required this.isCleared,
    required this.canCapture,
    this.photoPath,
    this.photoOwnerName,
    this.discovererName,
  });

  /// 見本の画像 (Base64)
  final String referenceImageBase64;

  /// クリア済みか (結果を見られる)
  final bool isCleared;

  /// 撮影できるか
  final bool canCapture;

  /// 見本に重ねて表示する写真 (自分の写真か、発見者のサムネ)
  final String? photoPath;

  /// [photoPath] を撮った人の表示名
  final String? photoOwnerName;

  /// 発見者の表示名 (協力プレイのみ。ソロでは null)
  final String? discovererName;

  /// スポットの状態の文言
  String get statusLabel {
    if (!isCleared) return 'まだ見つけていません';
    final name = discovererName;
    return name == null ? '撮影済み' : discovererLabel(name);
  }
}

/// Mission 画面の、スポットを並べるボトムシート
///
/// 高さは「最小 (見出しだけ)」と [maxSize] の 2 段で、それ以上は開かない。
/// 見出しには進み具合 (スポットごとのチップ) を出し、スポットは
/// [MissionSheetLayout] に応じて、横にめくるカードか縦のリストで並べる。
class MissionSpotSheet extends HookWidget {
  /// [MissionSpotSheet] を作成する
  const MissionSpotSheet({
    required this.spots,
    required this.layout,
    required this.onLayoutChanged,
    required this.onCapture,
    required this.onShowResult,
    this.capturingIndex,
    this.showPlayResultButton = false,
    this.onShowPlayResult,
    super.key,
  });

  /// シートを開いたときの高さ (画面に対する割合)
  static const maxSize = 0.6;

  /// 表示するスポット
  final List<MissionSheetSpot> spots;

  /// スポットの並べ方
  final MissionSheetLayout layout;

  /// 並べ方を切り替えたとき
  final ValueChanged<MissionSheetLayout> onLayoutChanged;

  /// 撮影ボタンを押したとき
  final ValueChanged<int> onCapture;

  /// 「結果を見る」を押したとき
  final ValueChanged<int> onShowResult;

  /// 撮影中のスポット (撮影ボタンを押せなくする)
  final int? capturingIndex;

  /// 見出しに「プレイ結果を見る」ボタンを出すか
  final bool showPlayResultButton;

  /// 「プレイ結果を見る」を押したとき (null なら押せない)
  final VoidCallback? onShowPlayResult;

  @override
  Widget build(BuildContext context) {
    final sheetController = useMemoized(DraggableScrollableController.new);
    useEffect(() => sheetController.dispose, [sheetController]);
    final headerHeight = useState(_estimatedHeaderHeight);
    final currentPage = useState(0);
    final width = MediaQuery.sizeOf(context).width;
    final pageController = usePageController(
      initialPage: currentPage.value,
      viewportFraction: _viewportFraction(width),
      keys: [width],
    );
    final rowKeys = useMemoized(
      () => List.generate(spots.length, (_) => GlobalKey()),
      [spots.length],
    );
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;
        // 閉じたときは、チップが端末下端のジェスチャーバーに重ならないよう下端の余白も含める
        double minSizeFor(double header) =>
            ((header + bottomInset) / available).clamp(0.05, maxSize);
        final minSize = minSizeFor(headerHeight.value);

        Future<void> expand() async {
          if (!sheetController.isAttached || sheetController.size >= maxSize) {
            return;
          }
          await sheetController.animateTo(
            maxSize,
            duration: _sheetAnimationDuration,
            curve: Curves.easeOutCubic,
          );
        }

        void toggleSize() {
          if (!sheetController.isAttached) return;
          final isOpen = sheetController.size > (minSize + maxSize) / 2;
          sheetController.animateTo(
            isOpen ? minSize : maxSize,
            duration: _sheetAnimationDuration,
            curve: Curves.easeOutCubic,
          );
        }

        Future<void> goToSpot(int index) async {
          currentPage.value = index;
          if (layout == MissionSheetLayout.carousel) {
            await Future.wait([
              expand(),
              if (pageController.hasClients)
                pageController.animateToPage(
                  index,
                  duration: _pageAnimationDuration,
                  curve: Curves.easeOutCubic,
                ),
            ]);
            return;
          }
          await expand();
          final rowContext = rowKeys[index].currentContext;
          if (rowContext != null && rowContext.mounted) {
            await Scrollable.ensureVisible(
              rowContext,
              duration: _pageAnimationDuration,
              curve: Curves.easeOutCubic,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            );
          }
        }

        // 見出しの高さが変わったら、最小の高さも合わせる (閉じていれば閉じたまま)
        void onHeaderHeight(double height) {
          if (!context.mounted || (height - headerHeight.value).abs() < 0.5) {
            return;
          }
          final wasClosed =
              sheetController.isAttached &&
              (sheetController.size - minSize).abs() < 0.001;
          headerHeight.value = height;
          if (wasClosed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted && sheetController.isAttached) {
                sheetController.jumpTo(minSizeFor(height));
              }
            });
          }
        }

        final header = _SheetHeader(
          spots: spots,
          layout: layout,
          currentIndex:
              layout == MissionSheetLayout.carousel ? currentPage.value : null,
          showPlayResultButton: showPlayResultButton,
          onShowPlayResult: onShowPlayResult,
          onLayoutChanged: onLayoutChanged,
          onTapSpot: goToSpot,
          onTap: toggleSize,
        );

        return DraggableScrollableSheet(
          controller: sheetController,
          initialChildSize: minSize,
          minChildSize: minSize,
          maxChildSize: maxSize,
          snap: true,
          builder: (context, scrollController) {
            return Material(
              color: colorScheme.surfaceContainerLow,
              elevation: 3,
              shadowColor: Colors.black,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // リストをスクロールしても、見出し (進み具合) は上に留める
                  PinnedHeaderSliver(
                    child: ColoredBox(
                      color: colorScheme.surfaceContainerLow,
                      child: _SizeReporter(
                        onHeight: onHeaderHeight,
                        child: header,
                      ),
                    ),
                  ),
                  // 下端の余白: 閉じているときだけ見出しの下に置き、開くと 0 にする
                  SliverToBoxAdapter(
                    child: ListenableBuilder(
                      listenable: sheetController,
                      builder: (context, _) {
                        final openness =
                            sheetController.isAttached && maxSize > minSize
                                ? ((sheetController.size - minSize) /
                                        (maxSize - minSize))
                                    .clamp(0.0, 1.0)
                                : 0.0;
                        return SizedBox(height: bottomInset * (1 - openness));
                      },
                    ),
                  ),
                  if (layout == MissionSheetLayout.carousel)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        // 開いたときにシートへちょうど収まる高さ
                        height: math.max(
                          available * maxSize - headerHeight.value,
                          _minCarouselHeight,
                        ),
                        child: _SpotCarousel(
                          spots: spots,
                          controller: pageController,
                          capturingIndex: capturingIndex,
                          bottomPadding: 16 + bottomInset,
                          onPageChanged: (index) => currentPage.value = index,
                          onCapture: onCapture,
                          onShowResult: onShowResult,
                        ),
                      ),
                    )
                  else ...[
                    SliverList.separated(
                      itemCount: spots.length,
                      itemBuilder:
                          (context, index) => _SpotListRow(
                            key: rowKeys[index],
                            index: index,
                            spot: spots[index],
                            isCapturing: capturingIndex == index,
                            onCapture: () => onCapture(index),
                            onShowResult: () => onShowResult(index),
                          ),
                      separatorBuilder:
                          (context, _) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: colorScheme.outlineVariant,
                          ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 16 + bottomInset),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// 見出しの高さの目安 (測るまでの最初の 1 フレームだけ使う)
const _estimatedHeaderHeight = 126.0;

/// カードの見本がこれ以上縮まないようにする、カルーセルの高さの下限
const _minCarouselHeight = 160.0;

/// カードの左右に見せる、隣のカードの幅
const _cardPeek = 26.0;

/// カードどうしの間隔
const _cardGap = 12.0;

const _sheetAnimationDuration = Duration(milliseconds: 250);
const _pageAnimationDuration = Duration(milliseconds: 350);

/// 左右に隣のカードが少し見える、1 ページの幅の割合
double _viewportFraction(double width) =>
    width <= 0 ? 1 : ((width - _cardPeek * 2) / width).clamp(0.5, 1.0);

/// 見出し: 取っ手・タイトル・進み具合・スポットのチップ
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.spots,
    required this.layout,
    required this.currentIndex,
    required this.showPlayResultButton,
    required this.onShowPlayResult,
    required this.onLayoutChanged,
    required this.onTapSpot,
    required this.onTap,
  });

  final List<MissionSheetSpot> spots;
  final MissionSheetLayout layout;
  final int? currentIndex;
  final bool showPlayResultButton;
  final VoidCallback? onShowPlayResult;
  final ValueChanged<MissionSheetLayout> onLayoutChanged;
  final ValueChanged<int> onTapSpot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clearedCount = spots.where((spot) => spot.isCleared).length;
    final isCarousel = layout == MissionSheetLayout.carousel;

    final Widget trailing;
    if (showPlayResultButton) {
      trailing = FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
        ),
        onPressed: onShowPlayResult,
        child: const Text('プレイ結果を見る'),
      );
    } else {
      trailing = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$clearedCount',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            TextSpan(text: ' / ${spots.length} クリア'),
          ],
        ),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 狭い幅では、進み具合を優先してタイトルを省略する
                  Flexible(
                    child: Text(
                      'ミッション',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    color: colorScheme.onSurfaceVariant,
                    tooltip: isCarousel ? 'リストで表示' : 'カードで表示',
                    icon: Icon(
                      isCarousel
                          ? Icons.view_list_outlined
                          : Icons.view_carousel_outlined,
                    ),
                    onPressed:
                        () => onLayoutChanged(
                          isCarousel
                              ? MissionSheetLayout.list
                              : MissionSheetLayout.carousel,
                        ),
                  ),
                  const Spacer(),
                  trailing,
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SpotChips(
              spots: spots,
              currentIndex: currentIndex,
              onTap: onTapSpot,
            ),
          ],
        ),
      ),
    );
  }
}

/// スポットごとの進み具合のチップ
///
/// 等分して「Spot n」→ 等分して番号だけ → 固定幅で横スクロール、の順に詰める。
class _SpotChips extends HookWidget {
  const _SpotChips({
    required this.spots,
    required this.currentIndex,
    required this.onTap,
  });

  static const _gap = 8.0;
  static const _labeledMinWidth = 84.0;
  static const _numberWidth = 44.0;
  static const _horizontalPadding = 16.0;

  final List<MissionSheetSpot> spots;
  final int? currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final count = spots.length;

    // 横スクロールのときは、見ているスポットのチップを中央へ寄せる
    useEffect(() {
      final index = currentIndex;
      if (index == null) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        final target =
            _horizontalPadding +
            index * (_numberWidth + _gap) -
            (position.viewportDimension - _numberWidth) / 2;
        scrollController.animateTo(
          target.clamp(position.minScrollExtent, position.maxScrollExtent),
          duration: _pageAnimationDuration,
          curve: Curves.easeOutCubic,
        );
      });
      return null;
    }, [currentIndex]);

    Widget chip(int index, {required bool showLabel}) => _SpotChip(
      index: index,
      isCleared: spots[index].isCleared,
      isCurrent: index == currentIndex,
      showLabel: showLabel,
      onTap: () => onTap(index),
    );

    return SizedBox(
      height: 36,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rowWidth = constraints.maxWidth - _horizontalPadding * 2;
          final perChip = (rowWidth - _gap * (count - 1)) / count;
          if (perChip >= _numberWidth) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    Expanded(
                      child: chip(i, showLabel: perChip >= _labeledMinWidth),
                    ),
                  ],
                ],
              ),
            );
          }
          // 端をぼかして、横に続きがあることを示す
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0, 0.05, 0.95, 1],
                ).createShader(bounds),
            child: ListView.separated(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: _gap),
              itemBuilder:
                  (context, index) => SizedBox(
                    width: _numberWidth,
                    child: chip(index, showLabel: false),
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _SpotChip extends StatelessWidget {
  const _SpotChip({
    required this.index,
    required this.isCleared,
    required this.isCurrent,
    required this.showLabel,
    required this.onTap,
  });

  final int index;
  final bool isCleared;
  final bool isCurrent;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground =
        isCleared
            ? colorScheme.onSecondaryContainer
            : isCurrent
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant;
    final BorderSide side;
    if (isCurrent) {
      side = BorderSide(color: colorScheme.primary, width: 2);
    } else if (isCleared) {
      side = BorderSide.none;
    } else {
      side = BorderSide(color: colorScheme.outlineVariant);
    }
    final shape = StadiumBorder(side: side);
    return Semantics(
      button: true,
      selected: isCurrent,
      onTap: onTap,
      label: 'Spot ${index + 1} ${isCleared ? 'クリア' : '未発見'}',
      excludeSemantics: true,
      child: Material(
        color: isCleared ? colorScheme.secondaryContainer : Colors.transparent,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCleared ? Icons.check : Icons.radio_button_unchecked,
                size: isCleared ? 16 : 14,
                color: isCleared ? colorScheme.primary : foreground,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  showLabel ? 'Spot ${index + 1}' : '${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1 スポットずつ大きなカードで、横にめくる
class _SpotCarousel extends StatelessWidget {
  const _SpotCarousel({
    required this.spots,
    required this.controller,
    required this.capturingIndex,
    required this.bottomPadding,
    required this.onPageChanged,
    required this.onCapture,
    required this.onShowResult,
  });

  final List<MissionSheetSpot> spots;
  final PageController controller;
  final int? capturingIndex;
  final double bottomPadding;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onCapture;
  final ValueChanged<int> onShowResult;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: spots.length,
      onPageChanged: onPageChanged,
      itemBuilder:
          (context, index) => Padding(
            padding: EdgeInsets.fromLTRB(
              _cardGap / 2,
              0,
              _cardGap / 2,
              bottomPadding,
            ),
            child: _SpotCard(
              index: index,
              spot: spots[index],
              isCapturing: capturingIndex == index,
              onCapture: () => onCapture(index),
              onShowResult: () => onShowResult(index),
            ),
          ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({
    required this.index,
    required this.spot,
    required this.isCapturing,
    required this.onCapture,
    required this.onShowResult,
  });

  final int index;
  final MissionSheetSpot spot;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onShowResult;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 見本は正方形を上限に、残りの高さに合わせて縮む
            Flexible(
              child: SizedBox(
                height: constraints.maxWidth,
                child: _SpotHero(index: index, spot: spot),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: _SpotTitle(index: index, spot: spot)),
                  const SizedBox(width: 12),
                  _CardAction(
                    spot: spot,
                    isCapturing: isCapturing,
                    onCapture: onCapture,
                    onShowResult: onShowResult,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// カードの見本 (撮った写真があれば右下に重ねる)
class _SpotHero extends StatelessWidget {
  const _SpotHero({required this.index, required this.spot});

  final int index;
  final MissionSheetSpot spot;

  @override
  Widget build(BuildContext context) {
    final photoPath = spot.photoPath;
    final hero = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pipSize = math.min(88, constraints.maxHeight * 0.42);
          return Stack(
            fit: StackFit.expand,
            children: [
              _Base64Image(base64: spot.referenceImageBase64),
              const Positioned(
                left: 8,
                top: 8,
                child: _ImageBadge(label: '見本'),
              ),
              const Positioned(right: 8, top: 8, child: _ZoomHint()),
              if (photoPath != null)
                Positioned(
                  right: 8,
                  bottom: 8,
                  width: pipSize.toDouble(),
                  height: pipSize.toDouble(),
                  child: Semantics(
                    container: true,
                    button: true,
                    label: '撮った写真を拡大',
                    child: GestureDetector(
                      onTap:
                          () => _showZoom(
                            context,
                            image: Image.file(
                              File(photoPath),
                              fit: BoxFit.contain,
                            ),
                            caption:
                                'Spot ${index + 1} · '
                                '${spot.photoOwnerName ?? 'あなた'}の写真',
                          ),
                      child: _PhotoThumb(
                        path: photoPath,
                        ownerName: spot.photoOwnerName,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
    return _ZoomableReference(index: index, spot: spot, child: hero);
  }
}

/// タップすると見本を拡大する (カードでは切り取って表示しているので、拡大で全体を見られる)
class _ZoomableReference extends StatelessWidget {
  const _ZoomableReference({
    required this.index,
    required this.spot,
    required this.child,
  });

  final int index;
  final MissionSheetSpot spot;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: 'Spot ${index + 1} の見本を拡大',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            () => _showZoom(
              context,
              image: _Base64Image(
                base64: spot.referenceImageBase64,
                fit: BoxFit.contain,
              ),
              caption: 'Spot ${index + 1} の見本',
            ),
        child: child,
      ),
    );
  }
}

/// 見本の右上の、拡大できることを示すアイコン
class _ZoomHint extends StatelessWidget {
  const _ZoomHint();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
      child: Padding(
        padding: EdgeInsets.all(7),
        child: Icon(Icons.open_in_full, size: 18, color: Colors.white),
      ),
    );
  }
}

/// 画像を画面の幅いっぱいに拡大して見せる (タップか閉じるボタンで閉じる。ピンチで拡大できる)
Future<void> _showZoom(
  BuildContext context, {
  required Widget image,
  required String caption,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder:
        (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: InteractiveViewer(maxScale: 4, child: image),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        caption,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    tooltip: '閉じる',
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

/// 見本に重ねる、撮った写真
class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.path, required this.ownerName});

  final String path;
  final String? ownerName;

  @override
  Widget build(BuildContext context) {
    final name = ownerName;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const ColoredBox(color: Colors.black12),
            ),
            if (name != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 6, bottom: 1),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 画像の左上に載せるラベル
class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// 「Spot n」と状態
class _SpotTitle extends StatelessWidget {
  const _SpotTitle({required this.index, required this.spot});

  final int index;
  final MissionSheetSpot spot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Spot ${index + 1}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(
          spot.statusLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                spot.isCleared
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// カードの右下のボタン (撮影する / 結果を見る)
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.spot,
    required this.isCapturing,
    required this.onCapture,
    required this.onShowResult,
  });

  final MissionSheetSpot spot;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onShowResult;

  @override
  Widget build(BuildContext context) {
    if (spot.isCleared) {
      return OutlinedButton(
        onPressed: onShowResult,
        child: const Text('結果を見る'),
      );
    }
    if (isCapturing) {
      return FilledButton.icon(
        onPressed: null,
        icon: const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: const Text('撮影する'),
      );
    }
    // 撮影できないスポット (協力プレイで共有中など) には、押せるように見えるボタンを出さない
    if (!spot.canCapture) return const SizedBox.shrink();
    return FilledButton.icon(
      onPressed: onCapture,
      icon: const Icon(Icons.add_a_photo, size: 18),
      label: const Text('撮影する'),
    );
  }
}

/// 全スポットを一覧するリストの 1 行
class _SpotListRow extends StatelessWidget {
  const _SpotListRow({
    required this.index,
    required this.spot,
    required this.isCapturing,
    required this.onCapture,
    required this.onShowResult,
    super.key,
  });

  final int index;
  final MissionSheetSpot spot;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onShowResult;

  @override
  Widget build(BuildContext context) {
    final photoPath = spot.photoPath;
    final Widget trailing;
    if (spot.isCleared) {
      trailing = InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onShowResult,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(photoPath),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const SizedBox.square(dimension: 40),
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                '結果',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      );
    } else if (isCapturing) {
      trailing = const SizedBox.square(
        dimension: 48,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (spot.canCapture) {
      trailing = IconButton.filledTonal(
        tooltip: '撮影する',
        iconSize: 24,
        style: IconButton.styleFrom(
          fixedSize: const Size.square(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onCapture,
        icon: const Icon(Icons.add_a_photo),
      );
    } else {
      trailing = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _ZoomableReference(
            index: index,
            spot: spot,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 64,
                child: _Base64Image(base64: spot.referenceImageBase64),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _SpotTitle(index: index, spot: spot)),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

/// Base64 の画像 (デコードは画像が変わったときだけ)
class _Base64Image extends HookWidget {
  const _Base64Image({required this.base64, this.fit = BoxFit.cover});

  final String base64;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final bytes = useMemoized(() => base64Decode(base64), [base64]);
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    if (bytes.isEmpty) return placeholder;
    return Image.memory(
      bytes,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

/// 子の高さが変わるたびに知らせる
class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onHeight, required super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeReporter(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeReporter renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onHeight);

  ValueChanged<double> onHeight;
  double? _lastHeight;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _lastHeight) return;
    _lastHeight = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
