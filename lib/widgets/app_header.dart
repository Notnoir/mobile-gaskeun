import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? customTitle;
  final bool showRoleSwitcher;

  const AppHeader({
    super.key,
    this.customTitle,
    this.showRoleSwitcher = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _showRoleSwitcherDialog(BuildContext context) {
    final state = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Mode / Peran Pengguna',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Beralih dengan cepat antara portal Warga, Operator, dan Pengawas untuk pengujian alur.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _buildRoleOption(
                  context: ctx,
                  state: state,
                  role: UserRole.warga,
                  title: 'Portal Warga',
                  subtitle: 'Budi Pratama — Setor sampah & tukar poin reward',
                  icon: Icons.person_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                _buildRoleOption(
                  context: ctx,
                  state: state,
                  role: UserRole.operator,
                  title: 'Portal Operator',
                  subtitle: 'Pak Anton — Monitoring IoT & verifikasi setoran',
                  icon: Icons.precision_manufacturing_outlined,
                  color: AppColors.info,
                ),
                const SizedBox(height: 10),
                _buildRoleOption(
                  context: ctx,
                  state: state,
                  role: UserRole.pengawas,
                  title: 'Portal Pengawas RW',
                  subtitle: 'Bu Sari Handayani — Ringkasan metrik & ekspor PDF',
                  icon: Icons.assessment_outlined,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required AppState state,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = state.currentRole == role;

    return InkWell(
      onTap: () {
        state.setRole(role);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Notifikasi Terkini', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.currentRole == UserRole.operator) ...[
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.warningLight,
                    child: Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  ),
                  title: const Text('Prediksi Tekanan Gas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Gas hampir penuh dalam 8 jam ke depan.', style: TextStyle(fontSize: 11)),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.delete_outline, color: AppColors.primary),
                  ),
                  title: Text('${state.pendingSubmissionsCount} Setoran Menunggu Verifikasi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Warga sedang menunggu konfirmasi di fasilitas.', style: TextStyle(fontSize: 11)),
                ),
              ] else if (state.currentRole == UserRole.warga) ...[
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.stars, color: AppColors.primary),
                  ),
                  title: Text('Poin Masuk! +350 pts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Setoran sampah 3.5 kg Anda telah diverifikasi Pak Anton.', style: TextStyle(fontSize: 11)),
                ),
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.infoLight,
                    child: Icon(Icons.local_shipping_outlined, color: AppColors.info),
                  ),
                  title: Text('Voucher Digestate Siap Diambil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Tunjukkan kode VCR-7790 ke petugas biodigester.', style: TextStyle(fontSize: 11)),
                ),
              ] else ...[
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.picture_as_pdf, color: Colors.white),
                  ),
                  title: Text('Laporan Bulanan Tersedia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Rekapitulasi partisipasi warga bulan ini siap diekspor ke format PDF.', style: TextStyle(fontSize: 11)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;

    Color roleColor;
    switch (state.currentRole) {
      case UserRole.warga:
        roleColor = AppColors.primary;
        break;
      case UserRole.operator:
        roleColor = AppColors.info;
        break;
      case UserRole.pengawas:
        roleColor = Colors.deepPurple;
        break;
    }

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 16,
      title: Row(
        children: [
          // GasKeun Logo Badge
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.eco,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'GasKeun',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      state.currentRole.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (showRoleSwitcher)
          TextButton.icon(
            onPressed: () => _showRoleSwitcherDialog(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.primaryDark),
            label: const Text(
              'Ganti Peran',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
            ),
          ),
        const SizedBox(width: 6),
        // Notification bell with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
              onPressed: () => _showNotificationsDialog(context, state),
            ),
            if (state.unreadNotificationsCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${state.unreadNotificationsCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
