import 'dart:convert';

import 'package:crypto/crypto.dart';

class SignServices {
  static getSign(Map json) {
    List jsonKeys = json.keys.toList();
    //按照 ASCII 字符顺序进行升序排列（也就是所谓的自然顺序）
    jsonKeys.sort();

    String str = '';
    for (var i = 0; i < jsonKeys.length; i++) {
      str += "${jsonKeys[i]}${json[jsonKeys[i]]}";
    }

    var sign = md5.convert(utf8.encode(str));

    return sign;
  }
}
