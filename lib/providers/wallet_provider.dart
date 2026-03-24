import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WalletProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  double _walletBalance = 0.00;
  double _walletAmountToUse = 0.00;
  bool _isLoading = false;
  
  double get walletBalance => _walletBalance;
  double get walletAmountToUse => _walletAmountToUse;
  bool get isLoading => _isLoading;

  Future<void> loadWalletBalance() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.getWalletTransactions(page: 1, perPage: 1);
      
      if (response['success']) {
        if (response['balance'] != null) {
          final balance = response['balance'];
          _walletBalance = double.parse(balance['balance']?.toString() ?? '0');
        }
      }
    } catch (e) {
      _walletBalance = 0.00;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setWalletAmountToUse(double amount) {
    if (amount < 0) {
      _walletAmountToUse = 0;
    } else if (amount > _walletBalance) {
      _walletAmountToUse = _walletBalance;
    } else {
      _walletAmountToUse = amount;
    }
    notifyListeners();
  }
  
  void useMaxWalletAmount(double orderTotal) {
    _walletAmountToUse = _walletBalance > orderTotal ? orderTotal : _walletBalance;
    notifyListeners();
  }
  
  void clearWalletAmount() {
    _walletAmountToUse = 0.00;
    notifyListeners();
  }
  
  double getFinalAmountToPay(double orderTotal) {
    return orderTotal - _walletAmountToUse;
  }
  
  bool canCoverFullAmount(double orderTotal) {
    return _walletBalance >= orderTotal;
  }
}