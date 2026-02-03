import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Для DateUtils
import 'package:fastable/models/water_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WaterRepository {
  static const String _kWaterKey = 'water_history_log';

  User? get _user => FirebaseAuth.instance.currentUser;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Вспомогательный метод для генерации ID документа из даты (YYYY-MM-DD)
  String _getDateId(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  // --- Загрузка всей истории воды ---
  Future<List<WaterEntry>> loadWaterEntries() async {
    if (_user != null) {
      // --- ОБЛАКО ---
      try {
        final snapshot = await _db
            .collection('users')
            .doc(_user!.uid)
            .collection('water_history')
            .get();

        return snapshot.docs.map((doc) => WaterEntry.fromJson(doc.data())).toList();
      } catch (e) {
        print("Ошибка загрузки воды: $e");
        return [];
      }
    } else {
      // --- ЛОКАЛЬНО ---
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_kWaterKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WaterEntry.fromJson(json)).toList();
    }
  }

  // --- Добавление или Обновление воды за день ---
  Future<void> addOrUpdateWaterForDay(DateTime date, int newCupCount) async {
    final entry = WaterEntry(date: date, cupCount: newCupCount);

    if (_user != null) {
      // --- ОБЛАКО ---
      // Используем дату как ID документа, чтобы легко обновлять
      final docId = _getDateId(date);
      await _db
          .collection('users')
          .doc(_user!.uid)
          .collection('water_history')
          .doc(docId)
          .set(entry.toJson()); // set() перезапишет или создаст документ
    } else {
      // --- ЛОКАЛЬНО ---
      final prefs = await SharedPreferences.getInstance();
      final entries = await loadWaterEntries(); // Загружаем локальные

      final int index = entries.indexWhere(
              (e) => DateUtils.isSameDay(e.date, date)
      );

      if (index != -1) {
        entries[index].cupCount = newCupCount;
      } else {
        entries.add(entry);
      }

      // Сохраняем обратно
      final List<Map<String, dynamic>> jsonList =
      entries.map((e) => e.toJson()).toList();
      await prefs.setString(_kWaterKey, jsonEncode(jsonList));
    }
  }

  // --- Получение воды за конкретный день ---
  Future<int> getWaterForDay(DateTime date) async {
    if (_user != null) {
      // --- ОБЛАКО ---
      final docId = _getDateId(date);
      final doc = await _db
          .collection('users')
          .doc(_user!.uid)
          .collection('water_history')
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        return WaterEntry.fromJson(doc.data()!).cupCount;
      }
      return 0;
    } else {
      // --- ЛОКАЛЬНО ---
      final entries = await loadWaterEntries();
      try {
        final WaterEntry entry = entries.firstWhere(
                (e) => DateUtils.isSameDay(e.date, date)
        );
        return entry.cupCount;
      } catch (e) {
        return 0;
      }
    }
  }
}