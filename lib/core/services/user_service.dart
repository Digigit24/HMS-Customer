import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends GetxService {
  static UserService get instance => Get.find<UserService>();

  final _userName = RxnString();
  final _userEmail = RxnString();
  final _userPhone = RxnString();
  final _userAddress = RxnString();

  String? get userName => _userName.value;
  String? get userEmail => _userEmail.value;
  String? get userPhone => _userPhone.value;
  String? get userAddress => _userAddress.value;

  Future<UserService> init() async {
    await _loadUserData();
    return this;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName.value = prefs.getString('user_name');
    _userEmail.value = prefs.getString('user_email');
    _userPhone.value = prefs.getString('user_phone');
    _userAddress.value = prefs.getString('user_address');
  }

  Future<void> updateUserData({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      _userName.value = name;
      await prefs.setString('user_name', name);
    }
    if (email != null) {
      _userEmail.value = email;
      await prefs.setString('user_email', email);
    }
    if (phone != null) {
      _userPhone.value = phone;
      await prefs.setString('user_phone', phone);
    }
    if (address != null) {
      _userAddress.value = address;
      await prefs.setString('user_address', address);
    }
  }

  Future<void> setUserFromLoginResponse(Map<String, dynamic> response) async {
    // TODO: Update this method based on actual API response structure
    // Example structure:
    // {
    //   "user": {
    //     "name": "John Doe",
    //     "email": "john@example.com",
    //     "phone": "+1234567890",
    //     "address": "123 Main St"
    //   }
    // }

    final user = response['user'] as Map<String, dynamic>?;
    if (user != null) {
      await updateUserData(
        name: user['name'] as String? ?? user['first_name'] as String?,
        email: user['email'] as String?,
        phone: user['phone'] as String?,
        address: user['address'] as String?,
      );
    }

    print('User data loaded: ${_userName.value}'); // For debugging
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');

    _userName.value = null;
    _userEmail.value = null;
    _userPhone.value = null;
    _userAddress.value = null;
  }
}
