import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HachiBehaviorController extends ChangeNotifier {
  HachiBehaviorController() {
    _load();
  }

  final _random = Random();
  Timer? _idleTimer;
  Map<String, dynamic>? _config;
  String? _action;
  bool _isInteraction = false;

  String? get animationAsset => _assetFor(_action);
  bool get isInteraction => _isInteraction;
  bool get isReady => _config != null;

  Future<void> _load() async {
    final source =
        await rootBundle.loadString('assets/images/hachi/behaviors.json');
    _config = jsonDecode(source) as Map<String, dynamic>;
    _startIdle((_config!['idle'] as Map<String, dynamic>)['initial'] as String);
  }

  void _startIdle(String action) {
    _idleTimer?.cancel();
    final state = _idleStates[action] as Map<String, dynamic>;
    final seconds = state['stay_seconds'] as List<dynamic>;
    final min = seconds.first as int;
    final max = seconds.last as int;
    _action = action;
    _isInteraction = false;
    notifyListeners();
    _idleTimer =
        Timer(Duration(seconds: min + _random.nextInt(max - min + 1)), () {
      _startIdle(_pick(state['next'] as List<dynamic>));
    });
  }

  void tryHover(String? zone) {
    if (zone == null || !isReady || _isInteraction) {
      return;
    }
    final rule = ((_config!['hover_actions'] as Map<String, dynamic>)[zone])
        as Map<String, dynamic>;
    if (_random.nextDouble() > (rule['chance'] as num).toDouble()) {
      return;
    }
    _idleTimer?.cancel();
    _action = _pick(rule['candidates'] as List<dynamic>);
    _isInteraction = true;
    notifyListeners();
  }

  void completeInteraction() {
    if (_isInteraction) {
      _startIdle('sitting');
    }
  }

  String? zoneAt(double x, double y) {
    if (!isReady) {
      return null;
    }
    final zones = _config!['interaction_zones'] as Map<String, dynamic>;
    for (final name in ['head', 'body']) {
      final rect =
          (zones[name] as Map<String, dynamic>)['rect'] as List<dynamic>;
      final left = (rect[0] as num).toDouble();
      final top = (rect[1] as num).toDouble();
      final width = (rect[2] as num).toDouble();
      final height = (rect[3] as num).toDouble();
      if (x >= left && x <= left + width && y >= top && y <= top + height) {
        return name;
      }
    }
    return null;
  }

  Map<String, dynamic> get _idleStates =>
      ((_config!['idle'] as Map<String, dynamic>)['states']
          as Map<String, dynamic>);

  String _pick(List<dynamic> candidates) {
    final total = candidates.fold<int>(0,
        (sum, item) => sum + ((item as Map<String, dynamic>)['weight'] as int));
    var ticket = _random.nextInt(total);
    for (final item in candidates) {
      final candidate = item as Map<String, dynamic>;
      ticket -= candidate['weight'] as int;
      if (ticket < 0) {
        return candidate['action'] as String;
      }
    }
    return (candidates.last as Map<String, dynamic>)['action'] as String;
  }

  String? _assetFor(String? action) {
    if (action == null || _config == null) {
      return null;
    }
    final idle = _idleStates[action] as Map<String, dynamic>?;
    if (idle != null) {
      return idle['animation'] as String;
    }
    for (final item
        in (_config!['hover_actions'] as Map<String, dynamic>).values) {
      for (final entry
          in (item as Map<String, dynamic>)['candidates'] as List<dynamic>) {
        final candidate = entry as Map<String, dynamic>;
        if (candidate['action'] == action) {
          return candidate['animation'] as String;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }
}
