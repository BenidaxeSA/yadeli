import 'package:shared_preferences/shared_preferences.dart';

/// Adresses favorites (Maison, Travail) — inspiré Uber, Citymapper
class AddressService {
  static const _homeKey = 'yadeli_address_home';
  static const _workKey = 'yadeli_address_work';
  static const _schoolKey = 'yadeli_address_school';
  static const _hospitalKey = 'yadeli_address_hospital';
  static const _pharmacyKey = 'yadeli_address_pharmacy';
  static const _verifiedKey = 'yadeli_profile_verified';

  static Future<void> setHome(String address) async {
    final prefs = await SharedPreferences.getInstance();
    if (address.isEmpty) {
      await prefs.remove(_homeKey);
    } else {
      await prefs.setString(_homeKey, address);
    }
  }

  static Future<void> setWork(String address) async {
    final prefs = await SharedPreferences.getInstance();
    if (address.isEmpty) {
      await prefs.remove(_workKey);
    } else {
      await prefs.setString(_workKey, address);
    }
  }

  static Future<String?> getHome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_homeKey);
  }

  static Future<String?> getWork() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_workKey);
  }

  static Future<void> setSchool(String address) async {
    final prefs = await SharedPreferences.getInstance();
    if (address.isEmpty) await prefs.remove(_schoolKey);
    else await prefs.setString(_schoolKey, address);
  }

  static Future<String?> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_schoolKey);
  }

  static Future<void> setHospital(String address) async {
    final prefs = await SharedPreferences.getInstance();
    if (address.isEmpty) await prefs.remove(_hospitalKey);
    else await prefs.setString(_hospitalKey, address);
  }

  static Future<String?> getHospital() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hospitalKey);
  }

  static Future<void> setPharmacy(String address) async {
    final prefs = await SharedPreferences.getInstance();
    if (address.isEmpty) await prefs.remove(_pharmacyKey);
    else await prefs.setString(_pharmacyKey, address);
  }

  static Future<String?> getPharmacy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pharmacyKey);
  }

  static Future<Map<String, String?>> getAll() async {
    return {
      'home': await getHome(),
      'work': await getWork(),
      'school': await getSchool(),
      'hospital': await getHospital(),
      'pharmacy': await getPharmacy(),
    };
  }

  static Future<void> setVerified(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_verifiedKey, v);
  }

  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_verifiedKey) ?? false;
  }
}
