import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:hive/hive.dart';

class HiveKeyValueStore {

  // TODO should we support lazy box also?
  final Box<String> hiveBox;
  final Serializers serializers;

  HiveKeyValueStore(this.hiveBox, this.serializers);

  // All other methods depend on getString() and setString()
  Future<void> setString(String key, String value) async {
    return hiveBox.put(key, value);
  }

  String getString(String key, [String defaultValue]) {
    return hiveBox.get(key, defaultValue: defaultValue);
  }


  Future<void> setInt(String key, int value) async {
    return setString(key, value?.toString());
  }

  int getInt(String key, [int defaultValue]) {
    String strValue = getString(key);
    return strValue != null? int.parse(strValue): defaultValue;
  }

  Future<void> setBool(String key, bool value) {
    return setInt(key, value ? 1 : 0);
  }

  bool getBool(String key, [bool defaultValue = false]) {
    return getInt(key, defaultValue ? 1 : 0) == 1;
  }

  Future<void> setDateTime(String key, DateTime value) {
    return setString(key, value?.toIso8601String());
  }

  DateTime getDateTime(String key, [DateTime defaultValue]) {
    String strValue = getString(key);
    return strValue != null? DateTime.parse(strValue): defaultValue;
  }

  Future<void> setList<T>(String key, List<T> value) {
    return setString(key, value != null? jsonEncode(value): null);
  }

  List<T> getList<T>(String key, [List<T> defaultValue]) {
    String strValue = getString(key);
    // jsonDecode() returns JsArray here... (check this... maybe only in dart web this happens)
    return strValue != null? jsonDecode(strValue).map<T>((e) => e as T).toList(): defaultValue;
  }

  Future<void> setObject<T>(String key, T obj, Serializer<T> serializer) {
    return setString(
        key, jsonEncode(serializers.serializeWith(serializer, obj)));
  }

  T getObject<T>(String key, Serializer<T> serializer, [T defaultValue]) {
    String value = getString(key);
    return value != null? serializers.deserializeWith(serializer, jsonDecode(value)): defaultValue;
  }

  Future<void> delete(String key) async {
    return hiveBox.delete(key);
  }

}
