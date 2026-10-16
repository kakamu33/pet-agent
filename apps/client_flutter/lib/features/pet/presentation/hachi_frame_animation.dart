import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HachiFrameAnimation extends StatefulWidget {
  const HachiFrameAnimation({
    required this.animationAsset,
    super.key,
    this.semanticLabel,
  });

  final String animationAsset;
  final String? semanticLabel;

  @override
  State<HachiFrameAnimation> createState() => _HachiFrameAnimationState();
}

class _HachiFrameAnimationState extends State<HachiFrameAnimation> {
  Timer? _frameTimer;
  List<_AnimationFrame> _frames = const [];
  bool _loops = true;
  int _frameIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimation();
  }

  @override
  void didUpdateWidget(covariant HachiFrameAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationAsset != widget.animationAsset) {
      _frameTimer?.cancel();
      _loadAnimation();
    }
  }

  Future<void> _loadAnimation() async {
    setState(() {
      _isLoading = true;
      _frameIndex = 0;
    });

    final animationJson = await rootBundle.loadString(widget.animationAsset);
    final animation = jsonDecode(animationJson) as Map<String, dynamic>;
    final basePath = widget.animationAsset.substring(
      0,
      widget.animationAsset.lastIndexOf('/') + 1,
    );
    final frames = (animation['frames'] as List<dynamic>)
        .map((frame) {
          final data = frame as Map<String, dynamic>;
          return _AnimationFrame(
            assetPath: '$basePath${data['file'] as String}',
            duration: Duration(milliseconds: data['duration_ms'] as int),
          );
        })
        .toList(growable: false);

    if (!mounted) {
      return;
    }

    setState(() {
      _frames = frames;
      _loops = animation['loop'] as bool? ?? true;
      _isLoading = false;
    });
    _scheduleNextFrame();
  }

  void _scheduleNextFrame() {
    _frameTimer?.cancel();
    if (_frames.isEmpty || !mounted) {
      return;
    }

    _frameTimer = Timer(_frames[_frameIndex].duration, () {
      if (!mounted) {
        return;
      }
      final isLastFrame = _frameIndex == _frames.length - 1;
      if (isLastFrame && !_loops) {
        return;
      }
      setState(() {
        _frameIndex = isLastFrame ? 0 : _frameIndex + 1;
      });
      _scheduleNextFrame();
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _frames.isEmpty) {
      return const SizedBox.expand();
    }

    return Image.asset(
      _frames[_frameIndex].assetPath,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      semanticLabel: widget.semanticLabel,
    );
  }
}

class _AnimationFrame {
  const _AnimationFrame({required this.assetPath, required this.duration});

  final String assetPath;
  final Duration duration;
}

