import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom pull-to-refresh: a short red rule that grows with pull distance,
/// then becomes an indeterminate 2 px red bar (Part 6.6). Never a spinner.
class PullRuleIndicator extends StatefulWidget {
  const PullRuleIndicator({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<PullRuleIndicator> createState() => _PullRuleIndicatorState();
}

class _PullRuleIndicatorState extends State<PullRuleIndicator> {
  static const double _triggerDistance = 72;
  double _dragOffset = 0;
  bool _refreshing = false;

  bool _onNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical || _refreshing) return false;
    final atTop = notification.metrics.pixels <= notification.metrics.minScrollExtent;

    if (notification is ScrollUpdateNotification && notification.dragDetails != null && atTop) {
      setState(() {
        _dragOffset = (_dragOffset + notification.dragDetails!.delta.dy)
            .clamp(0.0, _triggerDistance * 1.4);
      });
    } else if (notification is OverscrollNotification && notification.dragDetails != null) {
      setState(() {
        _dragOffset = (_dragOffset - notification.overscroll).clamp(0.0, _triggerDistance * 1.4);
      });
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= _triggerDistance) {
        _startRefresh();
      } else if (_dragOffset > 0) {
        setState(() => _dragOffset = 0);
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    setState(() {
      _refreshing = true;
      _dragOffset = _triggerDistance;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _dragOffset = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final red = brightness == Brightness.light ? AppColors.lightRed : AppColors.darkRed;
    final growProgress = (_dragOffset / _triggerDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(onNotification: _onNotification, child: widget.child),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: _refreshing
                ? SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(red),
                    ),
                  )
                : growProgress > 0
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 2,
                          width: 32 * growProgress,
                          color: red,
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
