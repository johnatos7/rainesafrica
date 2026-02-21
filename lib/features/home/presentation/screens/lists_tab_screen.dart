import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListsTabScreen extends ConsumerWidget {
  const ListsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lists',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Color(0xFF999999)),
            SizedBox(height: 16),
            Text(
              'Your Lists',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create and manage your shopping lists',
              style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
            ),
            SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0066CC),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
