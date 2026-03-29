import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/weight_entry.dart';

@lazySingleton
class WeightRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _localKey = 'weight_history';
  static const String _currentWeightKey = 'user_weight';
  static const String _legacyCurrentWeightKey = 'user_current_weight';

  // 🔥 ИСПРАВЛЕНИЕ: Генерация ID с учетом ЛОКАЛЬНОГО часового пояса (Баг №8)
  String _getDateId(DateTime date) {
    final localDate = date.toLocal();
    return "${localDate.year.toString().padLeft(4, '0')}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
  }

  Future<List<WeightEntry>> getWeightHistory() async {
    final localList = await _getLocalHistory();
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .collection('weight_history')
            .orderBy('date', descending: false)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudList = snapshot.docs.map((doc) {
            return WeightEntry.fromMap(doc.data());
          }).toList();

          final Map<String, WeightEntry> mergedMap = {};

          for (var entry in cloudList) {
            mergedMap[_getDateId(entry.date)] = entry;
          }

          for (var entry in localList) {
            mergedMap[_getDateId(entry.date)] = entry;
          }

          final mergedList = mergedMap.values.toList();
          mergedList.sort((a, b) => a.date.compareTo(b.date));

          await _saveToLocal(mergedList);

          if (mergedList.isNotEmpty) {
            await _saveCurrentWeightLocal(mergedList.last.weight);
          }
          return mergedList;
        }
      } catch (e) {
        debugPrint("⚠️ Cloud fetch failed (using local): $e");
      }
    }

    if (localList.isNotEmpty) {
      await _saveCurrentWeightLocal(localList.last.weight);
    }

    return localList;
  }

  Future<void> addWeightEntry(WeightEntry entry) async {
    final user = _auth.currentUser;
    try {
      List<WeightEntry> history = await _getLocalHistory();
      _updateList(history, entry);
      await _saveToLocal(history);
      await _saveCurrentWeightLocal(entry.weight);

      if (user != null) {
        final docId = _getDateId(entry.date);
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('weight_history')
            .doc(docId)
            .set({...entry.toMap(), 'date': Timestamp.fromDate(entry.date)});
        debugPrint("☁️ Weight synced to cloud");
      }
    } catch (e) {
      debugPrint("❌ Error saving weight: $e");
      throw Exception("Failed to save weight");
    }
  }

  Future<double?> getCurrentWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_currentWeightKey) ??
          prefs.getDouble(_legacyCurrentWeightKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllData() async {
    await clearLocalCache();

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final batch = _db.batch();
        final col = _db
            .collection('users')
            .doc(user.uid)
            .collection('weight_history');
        var snaps = await col.get();
        for (var doc in snaps.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        debugPrint("🔥 Cloud weight data cleared");
      } catch (e) {
        debugPrint("Error deleting cloud data: $e");
        rethrow;
      }
    }
  }

  Future<bool> hasLocalData() async {
    final list = await _getLocalHistory();
    return list.isNotEmpty;
  }

  Future<bool> hasCloudData(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> migrateLocalToCloud(String uid) async {
    final localData = await _getLocalHistory();
    if (localData.isEmpty) return;

    debugPrint("🚀 Migrating ${localData.length} weight entries...");
    final batch = _db.batch();

    for (var entry in localData) {
      final docId = _getDateId(entry.date);
      final ref = _db
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .doc(docId);

      batch.set(ref, {
        ...entry.toMap(),
        'date': Timestamp.fromDate(entry.date),
      });
    }
    await batch.commit();
    debugPrint("✅ Weight migration complete");
  }

  Future<void> mergeLocalToCloud(String uid) async {
    debugPrint("🔄 Start Merging Weight Data...");

    final localData = await _getLocalHistory();

    List<WeightEntry> cloudData = [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .get();
      cloudData = snapshot.docs
          .map((doc) => WeightEntry.fromMap(doc.data()))
          .toList();
    } catch (_) {}

    final Map<String, WeightEntry> mergedMap = {};

    for (var entry in cloudData) {
      final key = _getDateId(entry.date);
      mergedMap[key] = entry;
    }

    for (var entry in localData) {
      final key = _getDateId(entry.date);
      mergedMap[key] = entry;
    }

    final mergedList = mergedMap.values.toList();
    mergedList.sort((a, b) => a.date.compareTo(b.date));

    final batch = _db.batch();
    for (var entry in mergedList) {
      final docId = _getDateId(entry.date);
      final ref = _db
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .doc(docId);
      batch.set(ref, {
        ...entry.toMap(),
        'date': Timestamp.fromDate(entry.date),
      });
    }
    await batch.commit();

    await _saveToLocal(mergedList);
    if (mergedList.isNotEmpty) {
      await _saveCurrentWeightLocal(mergedList.last.weight);
    }

    debugPrint("✅ Data Merged Successfully");
  }

  Future<void> discardLocalAndUseCloud(String _) async {
    debugPrint("🗑 Discarding local weight data...");
    await clearLocalCache();
    await getWeightHistory();
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    await prefs.remove(_currentWeightKey);
    await prefs.remove(_legacyCurrentWeightKey);
  }

  Future<List<WeightEntry>> _getLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_localKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => WeightEntry.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveToLocal(List<WeightEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_localKey, jsonString);
  }

  Future<void> _saveCurrentWeightLocal(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentWeightKey, weight);
    await prefs.setDouble(_legacyCurrentWeightKey, weight);
  }

  void _updateList(List<WeightEntry> history, WeightEntry entry) {
    final entryDateString = _getDateId(entry.date);
    int existingIndex = history.indexWhere(
      (e) => _getDateId(e.date) == entryDateString,
    );

    if (existingIndex != -1) {
      history[existingIndex] = entry;
    } else {
      history.add(entry);
    }
    history.sort((a, b) => a.date.compareTo(b.date));
  }
}
