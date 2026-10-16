import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hachi_interactive_animation.dart';

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});
  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  static const _channel = MethodChannel('pet_agent/window');
  bool _hover = false;
  Future<void> _drag(DragStartDetails _) =>
      _channel.invokeMethod<void>('startDragging');
  Future<void> _resize(DragUpdateDetails d) => _channel.invokeMethod<void>(
      'resizeFromHandle', <String, double>{'deltaX': d.delta.dx});
  Future<void> _menu(Offset p) => _channel.invokeMethod<void>(
      'showPetMenu', <String, double>{'x': p.dx, 'y': p.dy});
  @override
  Widget build(BuildContext c) => Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: MouseRegion(
                  onEnter: (_) => setState(() => _hover = true),
                  onExit: (_) => setState(() => _hover = false),
                  child: Stack(fit: StackFit.expand, children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 14),
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: _drag,
                            onSecondaryTapDown: (d) => _menu(d.globalPosition),
                            child: const HachiInteractiveAnimation())),
                    Positioned(
                        right: 1,
                        bottom: 1,
                        child: IgnorePointer(
                            ignoring: !_hover,
                            child: AnimatedOpacity(
                                opacity: _hover ? 1 : 0,
                                duration: const Duration(milliseconds: 150),
                                child: GestureDetector(
                                    onPanUpdate: _resize,
                                    child: MouseRegion(
                                        cursor: SystemMouseCursors
                                            .resizeUpLeftDownRight,
                                        child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                                color: const Color(0xBFFFFFFF),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: const Icon(
                                                Icons.open_in_full_rounded,
                                                size: 8,
                                                color: Color(0xFF5E5E5E))))))))
                  ])))));
}
