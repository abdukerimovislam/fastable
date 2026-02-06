import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Для debugPrint и DateUtils
import 'package:flutter/material.dart'; // Для DateUtils
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/water_entry.dart';

@lazySingleton
class WaterRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _localKey = 'water_history_log';

  // Вспомогательный метод для генерации ID документа (YYYY-MM-DD)
  // Это гарантирует, что за один день будет только одна запись
  String _getDateId(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  // --- 1. ПОЛУЧЕНИЕ ИСТОРИИ (HYBRID) ---
  Future<List<WaterEntry>> getHistory() async {
    final user = _auth.currentUser;

    // A. Если юзер вошел -> пробуем взять из облака
    if (user != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .collection('water_history')
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudList = snapshot.docs.map((doc) {
            return WaterEntry.fromMap(doc.data());
          }).toList();

          // Обновляем локальный кэш
          await _saveToLocal(cloudList);
          return cloudList;
        }
      } catch (e) {
        debugPrint("⚠️ Water sync failed, using local: $e");
      }
    }

    // B. Берем локально (если офлайн или ошибка)
    return _getLocalHistory();
  }

  // --- 2. ДОБАВЛЕНИЕ / ОБНОВЛЕНИЕ (SYNC) ---
  Future<void> saveEntry(DateTime date, int cupCount) async {
    final entry = WaterEntry(date: date, cupCount: cupCount);

    // 1. Сохраняем локально (Мгновенно)
    final entries = await _getLocalHistory();

    // Ищем, есть ли запись за этот день
    final index = entries.indexWhere((e) => DateUtils.isSameDay(e.date, date));

    if (index != -1) {
      // Обновляем существующую (immutable replace)
      entries[index] = entry;
    } else {
      // Добавляем новую
      entries.add(entry);
    }

    await _saveToLocal(entries);
    debugPrint("💧 Water saved locally: $cupCount cups");

    // 2. Отправляем в облако (Фоном)
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docId = _getDateId(date);
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('water_history')
            .doc(docId)
            .set({
          'date': Timestamp.fromDate(date), // Firestore любит Timestamp
          'cupCount': cupCount,
        });
        debugPrint("☁️ Water synced to cloud");
      } catch (e) {
        debugPrint("❌ Water cloud sync error: $e");
      }
    }
  }

  // --- 3. ПОЛУЧЕНИЕ ЗА ДЕНЬ (Из кэша) ---
  Future<int> getWaterForDay(DateTime date) async {
    // Работаем с локальным кэшем, так как он всегда актуален (благодаря getHistory)
    final entries = await _getLocalHistory();
    try {
      final entry = entries.firstWhere(
            (e) => DateUtils.isSameDay(e.date, date),
        orElse: () => WaterEntry(date: date, cupCount: 0),
      );
      return entry.cupCount;
    } catch (e) {
      return 0;
    }
  }

  // --- 4. МИГРАЦИЯ (LOCAL -> CLOUD) ---
  // Вызывается AuthService при входе
  Future<void> migrateLocalToCloud(String uid) async {
    final localData = await _getLocalHistory();
    if (localData.isEmpty) return;

    debugPrint("🚀 Migrating ${localData.length} water entries...");
    final batch = _db.batch();

    for (var entry in localData) {
      final docId = _getDateId(entry.date);
      final ref = _db.collection('users').doc(uid).collection('water_history').doc(docId);

      batch.set(ref, {
        'date': Timestamp.fromDate(entry.date),
        'cupCount': entry.cupCount,
      });
    }

    await batch.commit();
    debugPrint("✅ Water history migration complete");
  }

  // --- 5. ОЧИСТКА ВСЕГО (GDPR) ---
  Future<void> clearAllData() async {
    // 1. Локально
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);

    // 2. Облако
    final user = _auth.currentUser;
    if (user != null) {
      final batch = _db.batch();
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('water_history')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint("🔥 Water history cleared from cloud");
    }
  }

  // --- HELPERS ---

  Future<List<WaterEntry>> _getLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_localKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => WaterEntry.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error parsing local water history: $e");
      return [];
    }
  }

  Future<void> _saveToLocal(List<WaterEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_localKey, jsonString);
  }
}