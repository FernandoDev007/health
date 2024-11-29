part of '../health.dart';

/// Configuration for handling heavy computations in an external isolate.
/// 
/// This configuration allows the health plugin to use an existing isolate
/// for processing data instead of creating new ones for each operation.
/// This is particularly useful when the app already maintains a long-running isolate.
class HealthIsolateConfig {
  /// Callback for processing duplicate removal operations in the main isolate.
  /// 
  /// This callback is used when the number of data points exceeds [threshold].
  /// It receives a [List<HealthDataPoint>] and should return a [List<HealthDataPoint>]
  /// with duplicates removed.
  final Future<List<HealthDataPoint>> Function(List<HealthDataPoint>)? duplicatesCallback;
  
  /// Callback for parsing health data in the main isolate.
  /// 
  /// This callback is used when the number of data points exceeds [threshold].
  /// It receives a [Map<String, dynamic>] containing the data type and points
  /// and should return a parsed [List<HealthDataPoint>].
  final Future<List<HealthDataPoint>> Function(Map<String, dynamic>)? parseCallback;
  
  /// The threshold of data points above which the isolate callbacks will be used.
  /// 
  /// If the number of data points is below this threshold, the computations
  /// will be done in the main thread. If it's above this threshold and a callback
  /// is provided, the computation will be delegated to the provided isolate callback.
  final int threshold;
  
  /// Creates a new [HealthIsolateConfig].
  /// 
  /// Both [duplicatesCallback] and [parseCallback] are optional. If not provided,
  /// the plugin will fall back to creating temporary isolates for the computations.
  /// 
  /// The [threshold] defaults to 100 data points.
  const HealthIsolateConfig({
    this.duplicatesCallback,
    this.parseCallback,
    this.threshold = 100,
  });

  /// Whether this configuration has a callback for handling duplicates removal
  bool get hasDuplicatesCallback => duplicatesCallback != null;

  /// Whether this configuration has a callback for parsing health data
  bool get hasParseCallback => parseCallback != null;
} 