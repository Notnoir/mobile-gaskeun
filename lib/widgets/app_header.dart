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

  void _showLogoutDialog(BuildContext context, AppState state) {
    final profile = state.activeProfile;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.danger, size: 24),
            SizedBox(width: 10),
            Text(
              'Ganti / Keluar Akun',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${profile.role.displayName} • ${profile.email}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Untuk berganti ke akun lain (Warga, Operator, atau Pengawas), Anda harus logout terlebih dahulu lalu memasukkan email dan password akun yang diinginkan.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anda telah logout. Silakan login dengan akun yang diinginkan.'),
                  backgroundColor: AppColors.textPrimary,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
                      color: roleColor.withValues(alpha: 0.12),
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
            onPressed: () => _showLogoutDialog(context, state),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.danger.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.danger.withValues(alpha: 0.25)),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 15, color: AppColors.danger),
            label: const Text(
              'Keluar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger),
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
