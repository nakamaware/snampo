import 'package:flutter/material.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/expand_photo_icon.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';

/// 判定の色で塗った上の帯 (判定・場所の名前・写真)
class SpotResultBand extends StatelessWidget {
  /// [SpotResultBand] を作成する
  const SpotResultBand({
    required this.caption,
    required this.rank,
    required this.pointName,
    required this.chips,
    required this.photo,
    super.key,
  });

  /// 判定の上の小さな文字 (「SPOT 2 / 5 · 商店街」など)
  final String caption;

  /// 判定 (採点が共有されていない古いクリアでは null。帯を灰色にする)
  final PhotoJudgeRank? rank;

  /// 場所の名前
  final String pointName;

  /// 判定の下に並べる札 (「みさきの採点」「発見済み」など)
  final List<String> chips;

  /// 右に置く写真 ([SpotResultPhoto])
  final Widget photo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rank = this.rank;
    final accent = rank?.color ?? theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: rank?.containerColor ?? theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + MapTopBar.height + 4,
          16,
          26,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (rank != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        rank.label,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 44,
                          height: 1.1,
                          color: accent,
                        ),
                      ),
                    ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [for (final chip in chips) _BandChip(chip)],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(pointName, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(width: 132, child: photo),
          ],
        ),
      ),
    );
  }
}

class _BandChip extends StatelessWidget {
  const _BandChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

/// 撮った写真と、左下に重ねた見本の小窓
///
/// 小窓をタップすると大小を入れ替える。大きい写真をタップすると、2 枚を並べた全画面を開く。
class SpotResultPhoto extends StatefulWidget {
  /// [SpotResultPhoto] を作成する
  const SpotResultPhoto({
    required this.photo,
    required this.reference,
    required this.ownerLabel,
    required this.onOpen,
    super.key,
  });

  /// 撮った写真 (読めなければ null)
  final ImageProvider? photo;

  /// 見本 (読めなければ null。小窓を出さない)
  final ImageProvider? reference;

  /// 撮った人の名札 (ソロでは null)
  final String? ownerLabel;

  /// 大きい写真をタップしたとき
  final VoidCallback onOpen;

  @override
  State<SpotResultPhoto> createState() => _SpotResultPhotoState();
}

class _SpotResultPhotoState extends State<SpotResultPhoto> {
  bool _swapped = false;

  @override
  Widget build(BuildContext context) {
    final hasReference = widget.reference != null;
    final showReferenceLarge = _swapped && hasReference;
    final large = showReferenceLarge ? widget.reference : widget.photo;
    final small = showReferenceLarge ? widget.photo : widget.reference;
    final largeLabel = showReferenceLarge ? '見本' : widget.ownerLabel;
    // ソロでは自分の写真に名札を付けない
    final smallLabel = showReferenceLarge ? widget.ownerLabel : '見本';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Semantics(
          button: true,
          label: '写真を大きく見る',
          child: GestureDetector(
            onTap: widget.onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SquareImage(image: large),
                    if (largeLabel != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _PhotoLabel(
                          largeLabel,
                          isMine: largeLabel == 'あなた',
                        ),
                      ),
                    const Positioned(
                      right: 6,
                      bottom: 6,
                      child: ExpandPhotoIcon(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasReference)
          Positioned(
            left: -14,
            bottom: -14,
            width: 58,
            height: 58,
            child: Semantics(
              button: true,
              label: '見本と入れ替える',
              child: GestureDetector(
                onTap: () => setState(() => _swapped = !_swapped),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.5),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _SquareImage(image: small),
                        if (smallLabel != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ColoredBox(
                              color: Colors.black54,
                              child: Text(
                                smallLabel,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SquareImage extends StatelessWidget {
  const _SquareImage({required this.image});

  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    final image = this.image;
    if (image == null) return placeholder;
    return Image(
      image: image,
      fit: BoxFit.cover,
      // 協力プレイで共有に失敗すると、表示中に写真を捨てることがある
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _PhotoLabel extends StatelessWidget {
  const _PhotoLabel(this.text, {required this.isMine});

  final String text;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isMine
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
