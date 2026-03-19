import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/water_entry.dart';

@lazySingleton
class WaterRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _localKey = 'water_history_log';

  // 🔥 ИСПРАВЛЕНИЕ: Генерация ID с учетом ЛОКАЛЬНОГО часового пояса (Баг №8)
  String _getDateId(DateTime date) {
    final localDate = date.toLocal();
    return "${localDate.year.toString().padLeft(4, '0')}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
  }

  Future<List<WaterEntry>> getHistory() async {
    final localList = await _getLocalHistory();
    final user = _auth.currentUser;

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

          final Map<String, WaterEntry> mergedMap = {};

          for (var entry in cloudList) {
            mergedMap[_getDateId(entry.date)] = entry;
          }

          for (var entry in localList) {
            final dateId = _getDateId(entry.date);
            if (mergedMap.containsKey(dateId)) {
              final cloudCups = mergedMap[dateId]!.cupCount;
              final localCups = entry.cupCount;
              mergedMap[dateId] = WaterEntry(
                date: entry.date,
                cupCount: localCups > cloudCups ? localCups : cloudCups,
              );
            } else {
              mergedMap[dateId] = entry;
            }
          }

          final mergedList = mergedMap.values.toList();
          mergedList.sort((a, b) => a.date.compareTo(b.date));

          await _saveToLocal(mergedList);
          return mergedList;
        }
      } catch (e) {
        debugPrint("⚠️ Water sync failed, using local: $e");
      }
    }

    return localList;
  }

  Future<void> saveEntry(DateTime date, int cupCount) async {
    final entry = WaterEntry(date: date, cupCount: cupCount);
    final entries = await _getLocalHistory();
    final index = entries.indexWhere((e) => DateUtils.isSameDay(e.date, date));

    if (index != -1) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }

    await _saveToLocal(entries);
    debugPrint("💧 Water saved locally: $cupCount cups");

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
          'date': Timestamp.fromDate(date),
          'cupCount': cupCount,
        });
        debugPrint("☁️ Water synced to cloud");
      } catch (e) {
        debugPrint("❌ Water cloud sync error: $e");
      }
    }
  }

  Future<int> getWaterForDay(DateTime date) async {
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

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);

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

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    await prefs.remove('health_water_last_liters');
  }

  Future<void> _saveToLocal(List<WaterEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_localKey, jsonString);
  }
}