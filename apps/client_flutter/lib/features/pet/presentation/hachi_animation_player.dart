import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HachiAnimationPlayer extends StatefulWidget {
  const HachiAnimationPlayer({
    required this.animationAsset,
    super.key,
    this.loopOverride,
    this.onCompleted,
    this.semanticLabel,
  });

  final String animationAsset;
  final bool? loopOverride;
  final VoidCallback? onCompleted;
  final String? semanticLabel;

  @override
  State<HachiAnimationPlayer> createState() => _HachiAnimationPlayerState();
}

class _HachiAnimationPlayerState extends State<HachiAnimationPlayer> {
  Timer? _frameTimer;
  List<_AnimationFrame> _frames = const [];
  bool _loops = true;
  int _frameIndex = 0;
  bool _isLoading = true;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadAnimation();
  }

  @override
  void didUpdateWidget(covariant HachiAnimationPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationAsset != widget.animationAsset ||
        oldWidget.loopOverride != widget.loopOverride) {
      _frameTimer?.cancel();
      _loadAnimation();
    }
  }

  Future<void> _loadAnimation() async {
    final loadGeneration = ++_loadGeneration;
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
    final frames = (animation['frames'] as List<dynamic>).map((entry) {
      final frame = entry as Map<String, dynamic>;
      return _AnimationFrame(
        assetPath: '$basePath${frame['file'] as String}',
        duration: Duration(milliseconds: frame['duration_ms'] as int),
      );
    }).toList(growable: false);

    if (!mounted || loadGeneration != _loadGeneration) {
      return;
    }

    setState(() {
      _frames = frames;
      _loops = widget.loopOverride ?? (animation['loop'] as bool? ?? true);
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
      if (isLastFrame) {
        if (_loops) {
          setState(() => _frameIndex = 0);
          _scheduleNextFrame();
        } else {
          widget.onCompleted?.call();
        }
        return;
      }

      setState(() => _frameIndex += 1);
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
