library iso2022jp;

import 'dart:convert';
import 'dart:typed_data';

import 'package:jcombu/jcombu.dart' as jcombu;
// import 'package:jcombu/src/jis_table.dart' as jisTable;

/// An instance of the default implementation of the [Iso2022JpCodec].
///
/// This instance provides a convenient access to the most common ISO Latin 1
/// use cases.
///
/// Examples:
/// ```dart
/// var encoded = iso2022jp.encode("^[$B$^$@!");
/// var decoded = iso2022jp.decode([0x62, 0x6c, 0xe5, 0x62, 0xe6,
///                              0x72, 0x67, 0x72, 0xf8, 0x64]);
/// ```
const Iso2022JpCodec iso2022jp = Iso2022JpCodec();

class Iso2022JpCodec extends Encoding {
  const Iso2022JpCodec({bool allowInvalid = false})
      : _allowInvalid = allowInvalid;

  final bool _allowInvalid;

  @override
  Uint8List encode(String source) => encoder.convert(source);

  @override
  String decode(List<int> codeUnits, {bool? allowInvalid}) =>
      Iso2022JpDecoder(allowInvalid: allowInvalid ?? _allowInvalid)
          .convert(codeUnits);

  @override
  Iso2022JpDecoder get decoder => _allowInvalid
      ? const Iso2022JpDecoder(allowInvalid: true)
      : const Iso2022JpDecoder();

  @override
  Iso2022JpEncoder get encoder => const Iso2022JpEncoder();

  @override
  String get name => 'ISO-2022-JP';
}

// class Iso2022JpEncoder extends Converter<String, List<int>> {
//   /// Creates a new [Iso2022JpEncoder]
//   const Iso2022JpEncoder();

//   @override
//   List<int> convert(String input) {
//     // TODO: implement convert
//     throw UnimplementedError();
//   }

//   /// Starts a chunked conversion.
//   ///
//   /// The converter works more efficiently if the given [sink] is a
//   @override
//   StringConversionSink startChunkedConversion(Sink<List<int>> sink) =>
//       throw UnimplementedError();

//   // Override the base-classes bind, to provide a better type.
//   @override
//   Stream<List<int>> bind(Stream<String> stream) => super.bind(stream);
// }

class Iso2022JpEncoder extends Converter<String, List<int>> {
  const Iso2022JpEncoder();

  @override
  Uint8List convert(String input) {
    final result = <int>[];
    for (var codeUnit in input.codeUnits) {
      if (codeUnit <= 0x7f) {
        result.addAll([codeUnit]);
      } else {
        throw UnsupportedError(
            'Not Only ASCII characters are supported in ISO-2022-JP encoding.');
      }
    }

    final hexString = convertCaretStringToHex(input);
    print('HexString: $hexString');
    final list = hexString.runes.toList() as Uint8List;
    print('Uint8List: $list');
    return list;
    // return jcombu.convertJis(result).runes.toList() as Uint8List;
    // return result;
  }
}

/// This class converts ISO2022JP code units (lists of unsigned 8-bit integers)
/// to a string.
class Iso2022JpDecoder extends Converter<List<int>, String> {
  /// Instantiates a new [Iso2022JpDecoder].
  ///
  /// The optional [allowInvalid] argument defines how [convert] deals
  /// with invalid or unterminated character sequences.
  ///
  /// If it is `true` [convert] replaces invalid (or unterminated) character
  /// sequences with the Unicode Replacement character `U+FFFD` (�). Otherwise
  /// it throws a [FormatException].
  const Iso2022JpDecoder({bool allowInvalid = false})
      : _allowInvalid = allowInvalid;

  final bool _allowInvalid;

  /// Decodes the UTF-8 [codeUnits] (a list of unsigned 8-bit integers) to the
  /// corresponding string.
  ///
  /// If the [codeUnits] start with the encoding of a
  /// [_unicodeBomCharacterRune], that character is discarded.
  ///
  /// If [allowInvalid] is `true` the decoder replaces invalid (or
  /// unterminated) character sequences with the Unicode Replacement character
  /// `U+FFFD` (�). Otherwise it throws a [FormatException].
  ///
  /// If [allowInvalid] is not given, it defaults to the `allowInvalid` that
  /// was used to instantiate `this`.
  @override
  String decode(List<int> codeUnits, {bool? allowInvalid}) =>
      Iso2022JpDecoder(allowInvalid: allowInvalid ?? _allowInvalid)
          .convert(codeUnits);

  /// Converts the ISO2022JP [codeUnits] (a list of unsigned 8-bit integers) to the
  /// corresponding string.
  ///
  /// Uses the code units from [start] to, but no including, [end].
  /// If [end] is omitted, it defaults to `codeUnits.length`.
  ///
  /// If the [codeUnits] start with the encoding of a
  /// [_unicodeBomCharacterRune], that character is discarded.
  @override
  String convert(List<int> codeUnits, [int start = 0, int? end]) {
    final length = codeUnits.length;
    final usedEnd = RangeError.checkValidRange(start, end, length);
    var usedStart = start;

    // Fast case for ASCII strings avoids StringBuffer / decodeMap.
    final oneBytes = _scanOneByteCharacters(codeUnits, start, usedEnd);
    StringBuffer buffer;
    if (oneBytes > 0) {
      final firstPart =
          String.fromCharCodes(codeUnits, usedStart, usedStart + oneBytes);
      usedStart += oneBytes;
      if (usedStart == usedEnd) {
        return firstPart;
      }
      buffer = StringBuffer(firstPart);
    } else {
      buffer = StringBuffer();
    }

    // TODO: Added this print
    print('codeUnits: $codeUnits');
    final result = jcombu.convertJis(codeUnits);
    print('result: $result');
    return result;
  }

  /// Starts a chunked conversion.
  ///
  /// The converter works more efficiently if the given [sink] is a
  /// [StringConversionSink].
  @override
  ByteConversionSink startChunkedConversion(Sink<String> sink) {
    StringConversionSink stringSink;
    if (sink is StringConversionSink) {
      stringSink = sink;
    } else {
      stringSink = StringConversionSink.from(sink);
    }

    throw UnimplementedError();
  }

  // Override the base-classes bind, to provide a better type.
  @override
  Stream<String> bind(Stream<List<int>> stream) => super.bind(stream);
}

int _scanOneByteCharacters(List<int> units, int from, int endIndex) {
  final to = endIndex;
  for (var i = from; i < to; i++) {
    final unit = units[i];
    if ((unit & _oneByteLimit) != unit) {
      return i - from;
    }
  }
  return to - from;
}

///
///  For a character outside the Basic Multilingual Plane (plane 0) that is
///  composed of a surrogate pair, runes combines the pair and returns a
///  single integer.  For example, the Unicode character for a
///  musical G-clef ('𝄞') with rune value 0x1D11E consists of a UTF-16
///  surrogate
///  pair: `0xD834` and `0xDD1E`. Using codeUnits returns the surrogate pair,
///  and using `runes` returns their combined value:
///
///      var clef = '\u{1D11E}';
///      clef.codeUnits;         // [0xD834, 0xDD1E]
///      clef.runes.toList();    // [0x1D11E]
///
/// UTF-16 constants.
/// https://zh.wikipedia.org/wiki/UTF-16
const int _surrogateTagMask = 0xFC00;
//const int _SURROGATE_VALUE_MASK = 0x3FF;
const int _leadSurrogateMin = 0xD800;
const int _tailSurrogateMin = 0xDC00;

bool _isLeadSurrogate(int codeUnit) =>
    (codeUnit & _surrogateTagMask) == _leadSurrogateMin;

bool _isTailSurrogate(int codeUnit) =>
    (codeUnit & _surrogateTagMask) == _tailSurrogateMin;

const int _oneByteLimit = 0x7f; // 7 bits
bool _isAscii(int codeUnit) => codeUnit <= _oneByteLimit;

String convertCaretStringToHex(String caretString) {
  List<int> hexList = [];

  for (int i = 0; i < caretString.length; i++) {
    if (caretString[i] == '^' && i + 2 < caretString.length) {
      int code = caretString.codeUnitAt(i + 1);
      hexList.add(code - 64);
      i += 2;
    } else {
      hexList.add(caretString.codeUnitAt(i));
    }
  }

  return hexList.map((e) => '\\x${e.toRadixString(16).padLeft(2, '0')}').join();
}
