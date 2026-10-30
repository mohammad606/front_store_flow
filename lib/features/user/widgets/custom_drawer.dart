import 'package:flutter/material.dart';

const Color _primaryBlue = Color(0xFF2563EB);
const Color _secondaryGray = Color(0xFF64748B);

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <_MenuItemData>[
      _MenuItemData(icon: Icons.dashboard_outlined, label: 'الرئيسية'),
      _MenuItemData(icon: Icons.inventory_2_outlined, label: 'المخزون'),
      _MenuItemData(icon: Icons.shopping_cart_outlined, label: 'الطلبات'),
      _MenuItemData(icon: Icons.people_alt_outlined, label: 'العملاء'),
      _MenuItemData(icon: Icons.settings_outlined, label: 'الإعدادات'),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StoreFlow',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'القائمة الرئيسية',
                    style: TextStyle(
                      color: _secondaryGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...menuItems.map(
              (item) => ListTile(
                leading: Icon(item.icon, color: _primaryBlue),
                title: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;

  const _MenuItemData({
    required this.icon,
    required this.label,
  });
}
