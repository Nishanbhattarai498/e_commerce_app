import 'package:flutter/foundation.dart';
import '../models/address.dart';
import 'supabase_service.dart';

class AddressService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Address> _addresses = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Address> get addresses => _addresses;
  Address? get defaultAddress => _addresses.isNotEmpty
      ? _addresses.firstWhere((a) => a.isDefault,
          orElse: () => _addresses.first)
      : null;

  Future<void> fetchAddresses() async {
    if (!_supabaseService.isAuthenticated) return;

    _setLoading(true);
    try {
      final response = await _supabaseService.client
          .from('addresses')
          .select()
          .eq('user_id', _supabaseService.currentUser!.id)
          .order('is_default', ascending: false);

      _addresses =
          response.map<Address>((json) => Address.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Address?> addAddress({
    required String name,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    bool isDefault = false,
  }) async {
    if (!_supabaseService.isAuthenticated) return null;

    _setLoading(true);
    try {
      // If this is the default address, unset any existing default
      if (isDefault) {
        await _unsetDefaultAddresses();
      }

      final response = await _supabaseService.client.from('addresses').insert({
        'user_id': _supabaseService.currentUser!.id,
        'name': name,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      }).select();

      final newAddress = Address.fromJson(response[0]);
      _addresses = [newAddress, ..._addresses];
      notifyListeners();
      return newAddress;
    } catch (e) {
      debugPrint('Error adding address: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Address?> updateAddress({
    required int id,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) async {
    if (!_supabaseService.isAuthenticated) return null;

    _setLoading(true);
    try {
      // If this is being set as the default address, unset any existing default
      if (isDefault == true) {
        await _unsetDefaultAddresses();
      }

      final updateData = {
        if (name != null) 'name': name,
        if (addressLine1 != null) 'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (postalCode != null) 'postal_code': postalCode,
        if (country != null) 'country': country,
        if (isDefault != null) 'is_default': isDefault,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('addresses')
          .update(updateData)
          .eq('id', id)
          .eq('user_id', _supabaseService.currentUser!.id)
          .select();

      if (response.isEmpty) return null;

      final updatedAddress = Address.fromJson(response[0]);
      _addresses = _addresses.map((address) {
        return address.id == id ? updatedAddress : address;
      }).toList();
      notifyListeners();
      return updatedAddress;
    } catch (e) {
      debugPrint('Error updating address: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAddress(int id) async {
    if (!_supabaseService.isAuthenticated) return false;

    _setLoading(true);
    try {
      await _supabaseService.client
          .from('addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', _supabaseService.currentUser!.id);

      _addresses = _addresses.where((address) => address.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _unsetDefaultAddresses() async {
    try {
      await _supabaseService.client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', _supabaseService.currentUser!.id)
          .eq('is_default', true);
    } catch (e) {
      debugPrint('Error unsetting default addresses: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
