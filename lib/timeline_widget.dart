import 'dart:math';
import 'package:flutter/material.dart';
import '../timeline_event.dart';

const double _indicatorSize = 52.0;

class TimelineWidget extends StatefulWidget {
  final List<TimelineEvent> events;

  const TimelineWidget({
    super.key,
    required this.events,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMilestoneTap(int index) {
    setState(() {
      widget.events[index].isExpanded = !widget.events[index].isExpanded;
    });

    if (widget.events[index].isExpanded) {
      final itemPosition = (index * 160.0) - (_scrollController.position.viewportDimension / 3);
      _scrollController.animateTo(
        itemPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        return CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: widget.events.length,
                    (context, index) {
                  final event = widget.events[index];
                  final progressFraction = (index + 1) / widget.events.length;
                  final lineProgress = _lineAnimation.value * progressFraction;

                  return _buildTimelineItem(event, index, lineProgress);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, int index, double lineProgress) {
    final isFirst = index == 0;
    final isLast = index == widget.events.length - 1;

    return Stack(
      children: [
        // Timeline line centered through icons
        Positioned(
          left: _indicatorSize / 1.8 , // Center the line (half of stroke width)
          top: 0,
          bottom: 0,
          child: CustomPaint(
            size: const Size(3, double.infinity),
            painter: _TimelineLinePainter(
              itemIndex: index,
              totalItems: widget.events.length,
              lineProgress: lineProgress,
              isFirst: isFirst,
              isLast: isLast,
              lineColor: event.color,
            ),
          ),
        ),
        // Content card
        Padding(
          padding: EdgeInsets.only(
            left: _indicatorSize + 16,
            right: 16,
            top: isFirst ? 0 : 20,
            bottom: isLast ? 0 : 20,
          ),
          child: Hero(
            tag: 'timeline_card_${event.title}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onMilestoneTap(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: event.isExpanded
                        ? event.color.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: event.isExpanded
                          ? event.color.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: event.isExpanded
                            ? event.color.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: event.isExpanded ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildCardContent(event, context),
                ),
              ),
            ),
          ),
        ),
        // Timeline indicator
        Positioned(
          left: 5,
          top: isFirst ? 8 : 32,
          child: SizedBox(
            width: _indicatorSize,
            child: _buildMilestoneIndicator(event),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(TimelineEvent event, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                event.icon,
                color: event.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: event.isExpanded
                        ? event.color
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                event.isExpanded ? Icons.expand_less : Icons.expand_more,
                color: event.color.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(event),
              ],
            ),
            crossFadeState: event.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TimelineEvent event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () {
            // Add details view action
          },
          icon: Icon(Icons.remove_red_eye_outlined, color: event.color),
          label: Text(
            'View Details',
            style: TextStyle(color: event.color),
          ),
        ),

        FilledButton.icon(
          onPressed: () {
            // Add primary action
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next Step'),
          style: FilledButton.styleFrom(
            backgroundColor: event.color,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneIndicator(TimelineEvent event) {
    final size = event.isExpanded ? _indicatorSize * 1.2 : _indicatorSize;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.color,
                    event.color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: event.color.withOpacity(0.3),
                    blurRadius: event.isExpanded ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  event.icon,
                  color: Colors.white,
                  size: event.isExpanded ? 28 : 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimelineLinePainter extends CustomPainter {
  final int itemIndex;
  final int totalItems;
  final double lineProgress;
  final bool isFirst;
  final bool isLast;
  final Color lineColor;

  _TimelineLinePainter({
    required this.itemIndex,
    required this.totalItems,
    required this.lineProgress,
    required this.isFirst,
    required this.isLast,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double startY = isFirst ? _indicatorSize / 2 : 0;
    final double endY = isLast ? size.height - _indicatorSize / 2 : size.height;
    final double actualLineHeight = startY + (endY - startY) * lineProgress;

    // Draw background line
    final Paint backgroundPaint = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width / 2, startY),
      Offset(size.width / 2, endY),
      backgroundPaint,
    );

    // Draw glowing effect
    final Paint glowPaint = Paint()
      ..color = lineColor.withOpacity(0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(size.width / 2, startY),
      Offset(size.width / 2, actualLineHeight),
      glowPaint,
    );

    // Draw main line with gradient
    final Gradient lineGradient = LinearGradient(
      colors: [
        lineColor,
        lineColor.withOpacity(0.6),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Paint linePaint = Paint()
      ..shader = lineGradient.createShader(
        Rect.fromLTWH(0, startY, size.width, endY - startY),
      )
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width / 2, startY),
      Offset(size.width / 2, actualLineHeight),
      linePaint,
    );

    // Draw connecting nodes
    const double nodeSpacing = 80;
    const double nodeSize = 4;

    for (double y = startY; y < actualLineHeight; y += nodeSpacing) {
      if (y <= startY + (endY - startY) * lineProgress) {
        // Draw node glow
        final Paint nodeGlowPaint = Paint()
          ..color = lineColor.withOpacity(0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(
          Offset(size.width / 2, y),
          nodeSize,
          nodeGlowPaint,
        );

        // Draw node center
        final Paint nodePaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(size.width / 2, y),
          nodeSize / 2,
          nodePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) {
    return oldDelegate.lineProgress != lineProgress ||
        oldDelegate.lineColor != lineColor;
  }
}