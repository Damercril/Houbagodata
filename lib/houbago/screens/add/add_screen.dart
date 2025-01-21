import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter',
          style: HoubagoTheme.textTheme.titleLarge?.copyWith(
            color: HoubagoTheme.textLight,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Page Ajouter',
          style: HoubagoTheme.textTheme.headlineMedium,
        ),
      ),
    );
  }
}
