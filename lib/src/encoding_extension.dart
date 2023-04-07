// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// library encoding;
library encoding_extension;

import 'dart:convert';

import '../enough_convert.dart';

/// Open-ended Encoding enum.
extension EncodingExtension on Encoding {
  // All aliases (in lowercase) of supported encoding from
  // http://www.iana.org/assignments/character-sets/character-sets.xml.
  static final Map<String, Encoding> _nameToEncoding = <String, Encoding>{
    // ISO_8859-1:1987.
    'iso_8859-1:1987': latin1,
    'iso-ir-100': latin1,
    'iso_8859-1': latin1,
    'iso-8859-1': latin1,
    'latin1': latin1,
    'l1': latin1,
    'ibm819': latin1,
    'cp819': latin1,
    'csisolatin1': latin1,

    // US-ASCII.
    'iso-ir-6': ascii,
    'ansi_x3.4-1968': ascii,
    'ansi_x3.4-1986': ascii,
    'iso_646.irv:1991': ascii,
    'iso646-us': ascii,
    'us-ascii': ascii,
    'us': ascii,
    'ibm367': ascii,
    'cp367': ascii,
    'csascii': ascii,
    'ascii': ascii, // This is not in the IANA official names.

    // UTF-8.
    'csutf8': utf8,
    'utf-8': utf8,

    // ISO-2022-JP
    'jis': iso2022jp,
    'iso-2022-jp': iso2022jp
  };

  // /// Returns an [Encoding] for a named character set.
  // ///
  // /// The names used are the IANA official names for the character set (see
  // /// [IANA character sets][]). The names are case insensitive.
  // ///
  // /// [IANA character sets]: http://www.iana.org/assignments/character-sets/character-sets.xml
  // ///
  // /// If character set is not supported `null` is returned.
  // static Encoding? getByName(String? name) {
  //   if (name == null) {
  //     return null;
  //   }
  //   return _nameToEncoding[name.toLowerCase()];
  // }
}
