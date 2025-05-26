import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/role_protected_widget.dart';
import '../../viewmodels/reservation_management_viewmodel.dart';
import 'reservation_management_screen.dart';

class ProtectedReservationManagementScreen extends StatelessWidget {
  const ProtectedReservationManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoleProtectedWidget(
      allowedRoles: const ['serveur'],
      child: ChangeNotifierProvider(
        create: (context) => ReservationManagementViewModel(),
        child: const ReservationManagementScreen(),
      ),
    );
  }
} 