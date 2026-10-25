import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_header.dart';
import 'tabs/warga_home_tab.dart';
import 'tabs/warga_setor_tab.dart';
import 'tabs/warga_tukar_tab.dart';
import 'tabs/warga_edukasi_tab.dart';

class WargaMainScreen extends StatefulWidget {
  const WargaMainScreen({super.key});

  @override
  State<WargaMainScreen> createState() => _WargaMainScreenState();
}

class _WargaMainScreenState extends State<WargaMainScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = [
    'Beranda',
    'Setor Sampah',
    'Tukar Poin',
    'Edukasi',
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      WargaHomeTab(
        onNavigateToSetor: () => setState(() => _currentIndex = 1),
        onNavigateToTukar: () => setState(() => _currentIndex = 2),
      ),
      const WargaSetorTab(),
      const WargaTukarTab(),
      const WargaEdukasiTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        customTitle: _tabTitles[_currentIndex],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.98),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.recycling_rounded,
                  label: 'Setor',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.redeem_rounded,
                  label: 'Tukar Poin',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.menu_book_rounded,
                  label: 'Edukasi',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
