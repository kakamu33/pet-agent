import 'package:flutter/material.dart';

import 'hachi_animation_player.dart';
import 'hachi_behavior_controller.dart';

class HachiInteractiveAnimation extends StatefulWidget {
  const HachiInteractiveAnimation({super.key});

  @override
  State<HachiInteractiveAnimation> createState() =>
      _HachiInteractiveAnimationState();
}

class _HachiInteractiveAnimationState extends State<HachiInteractiveAnimation> {
  late final HachiBehaviorController _controller;
  String? _lastZone;

  @override
  void initState() {
    super.initState();
    _controller = HachiBehaviorController();
  }

  void _handlePointerMove(PointerEvent event, Size size) {
    if (!_controller.isReady || size.isEmpty) {
      return;
    }
    final zone = _controller.zoneAt(
      event.localPosition.dx / size.width,
      event.localPosition.dy / size.height,
    );
    if (zone == _lastZone) {
      return;
    }
    _lastZone = zone;
    _controller.tryHover(zone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onExit: (_) => _lastZone = null,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: (event) =>
              _handlePointerMove(event, constraints.biggest),
          onPointerMove: (event) =>
              _handlePointerMove(event, constraints.biggest),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final animationAsset = _controller.animationAsset;
              if (animationAsset == null) {
                return const SizedBox.expand();
              }
              return HachiAnimationPlayer(
                key: ValueKey('$animationAsset-${_controller.isInteraction}'),
                animationAsset: animationAsset,
                loopOverride: _controller.isInteraction ? false : true,
                onCompleted: _controller.completeInteraction,
                semanticLabel: '动态猫咪桌宠 Hachi',
              );
            },
          ),
        ),
      ),
    );
  }
}
