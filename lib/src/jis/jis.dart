import '../base.dart';

/// Contains base classes for JIS codecs

/// Provides a JIS decoder.
class JisDecoder extends BaseDecoder {
  /// Creates a new [JisDecoder].
  ///
  /// The [symbols] need to be exactly `128` characters long.
  ///
  /// Set [allowInvalid] to true in case invalid characters sequences
  /// should be at least readable.
  const JisDecoder(String symbols, {bool allowInvalid = false})
      : super(symbols, 0x7F, allowInvalid: allowInvalid);
}

/// Provides a simple JIS encoder.
class JisEncoder extends BaseEncoder {
  /// Creates a new [JisEncoder].
  ///
  /// Set [allowInvalid] to true in case invalid characters
  /// should be translated to question marks.
  const JisEncoder(Map<int, int> encodingMap, {bool allowInvalid = false})
      : super(encodingMap, 0x7f, allowInvalid: allowInvalid);
}
