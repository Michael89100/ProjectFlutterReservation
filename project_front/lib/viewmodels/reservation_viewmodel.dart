import 'package:flutter/material.dart';
import '../models/reservation.dart';

class ReservationViewModel extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _telephone = '';
  int _nombreCouverts = 1;
  bool _isLoading = false;

  GlobalKey<FormState> get formKey => _formKey;
  String get nom => _nom;
  String get telephone => _telephone;
  int get nombreCouverts => _nombreCouverts;
  bool get isLoading => _isLoading;

  void setNom(String value) {
    _nom = value;
    notifyListeners();
  }

  void setTelephone(String value) {
    _telephone = value;
    notifyListeners();
  }

  void setNombreCouverts(int value) {
    _nombreCouverts = value;
    notifyListeners();
  }

  Future<bool> submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implémenter l'appel API pour sauvegarder la réservation
      final reservation = Reservation(
        nom: _nom,
        telephone: _telephone,
        nombreCouverts: _nombreCouverts,
      );

      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 