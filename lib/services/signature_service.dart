import 'package:crypto/crypto.dart';
import 'dart:convert';

class SignatureService {
  static String generateSign(List<String> values, String ticket) {
    values.removeWhere((value) => value.isEmpty);
    values.add(ticket);
    values.sort();
    
    final buffer = StringBuffer();
    for (var value in values) {
      buffer.write(value);
    }
    
    final bytes = utf8.encode(buffer.toString());
    final digest = sha1.convert(bytes);
    return digest.toString().toUpperCase();
  }

  static String generateNonce() {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      List.generate(32, (index) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
}