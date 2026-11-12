import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n.dart';

class Cfg {
  static const checkinPts = 20;
  static const adPts = 10;
  static const maxAdsPerDay = 10;
  static const maxGamesPerDay = 3;
  static const quizPtsPerAnswer = 10;
  static const referralBonus = 50;
  static const minWithdraw = 5000;
  static const pointsPerUsd = 1000;
  static const adminPin = '1234';
}

class AppState extends ChangeNotifier {
  late SharedPreferences _p;
  bool ready = false;

  int points = 0;
  int totalEarned = 0;
  String lang = 'ar';
  String refCode = '';
  bool usedReferral = false;
  int refCount = 0;
  String day = '';
  int adsToday = 0;
  int gamesToday = 0;
  bool checkedIn = false;
  bool quizDone = false;
  List<Map<String, dynamic>> withdrawals = [];

  String t(String k) => tr(lang, k);
  bool get rtl => lang == 'ar';

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    points = _p.getInt('points') ?? 0;
    totalEarned = _p.getInt('totalEarned') ?? 0;
    lang = _p.getString('lang') ?? 'ar';
    usedReferral = _p.getBool('usedReferral') ?? false;
    refCount = _p.getInt('refCount') ?? 0;
    day = _p.getString('day') ?? '';
    adsToday = _p.getInt('adsToday') ?? 0;
    gamesToday = _p.getInt('gamesToday') ?? 0;
    checkedIn = _p.getBool('checkedIn') ?? false;
    quizDone = _p.getBool('quizDone') ?? false;
    final w = _p.getString('withdrawals');
    if (w != null) {
      withdrawals = (jsonDecode(w) as List).cast<Map<String, dynamic>>();
    }
    refCode = _p.getString('refCode') ?? _makeCode();
    _rollDay();
    await _save();
    ready = true;
    notifyListeners();
  }

  String _makeCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return 'DZ${List.generate(6, (_) => chars[r.nextInt(chars.length)]).join()}';
  }

  void _rollDay() {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    if (day != today) {
      day = today;
      adsToday = 0;
      gamesToday = 0;
      checkedIn = false;
      quizDone = false;
    }
  }

  Future<void> _save() async {
    await _p.setInt('points', points);
    await _p.setInt('totalEarned', totalEarned);
    await _p.setString('lang', lang);
    await _p.setString('refCode', refCode);
    await _p.setBool('usedReferral', usedReferral);
    await _p.setInt('refCount', refCount);
    await _p.setString('day', day);
    await _p.setInt('adsToday', adsToday);
    await _p.setInt('gamesToday', gamesToday);
    await _p.setBool('checkedIn', checkedIn);
    await _p.setBool('quizDone', quizDone);
    await _p.setString('withdrawals', jsonEncode(withdrawals));
  }

  Future<void> _commit() async {
    await _save();
    notifyListeners();
  }

  void _add(int n) {
    points += n;
    totalEarned += n;
  }

  Future<void> setLang(String l) async {
    lang = l;
    await _commit();
  }

  Future<bool> claimCheckin() async {
    _rollDay();
    if (checkedIn) return false;
    checkedIn = true;
    _add(Cfg.checkinPts);
    await _commit();
    return true;
  }

  bool get canWatchAd {
    _rollDay();
    return adsToday < Cfg.maxAdsPerDay;
  }

  Future<void> rewardAd() async {
    adsToday++;
    _add(Cfg.adPts);
    await _commit();
  }

  bool get canPlayGame {
    _rollDay();
    return gamesToday < Cfg.maxGamesPerDay;
  }

  Future<void> finishGame(bool won) async {
    gamesToday++;
    if (won) _add(15);
    await _commit();
  }

  Future<void> finishQuiz(int correct) async {
    quizDone = true;
    _add(correct * Cfg.quizPtsPerAnswer);
    await _commit();
  }

  Future<bool> applyReferral(String code) async {
    code = code.trim().toUpperCase();
    if (usedReferral || code == refCode) return false;
    if (!RegExp(r'^DZ[A-Z0-9]{6}$').hasMatch(code)) return false;
    usedReferral = true;
    _add(Cfg.referralBonus);
    await _commit();
    return true;
  }

  Future<bool> requestWithdraw(String method, String account, int amount) async {
    if (amount < Cfg.minWithdraw || amount > points || account.trim().length < 6) {
      return false;
    }
    points -= amount;
    withdrawals.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      'account': account.trim(),
      'amount': amount,
      'status': 'pending',
      'date': DateTime.now().toIso8601String().substring(0, 10),
    });
    await _commit();
    return true;
  }

  Future<void> setWithdrawStatus(int id, String status) async {
    final w = withdrawals.firstWhere((e) => e['id'] == id);
    w['status'] = status;
    if (status == 'rejected') points += w['amount'] as int;
    await _commit();
  }
}
