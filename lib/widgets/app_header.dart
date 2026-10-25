import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';

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
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: AppColors.primary),
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
                          style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Apakah Anda yakin ingin keluar dari akun ini?',
              style: TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              state.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda telah logout.'),
                    backgroundColor: AppColors.onSurface,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
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
          children: const [
            Icon(Icons.notifications_active_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Notifikasi Terkini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.currentRole == UserRole.operator) ...[
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondaryFixed,
                    child: Icon(Icons.warning_amber_rounded, color: AppColors.secondary),
                  ),
                  title: Text('Prediksi Tekanan Gas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Gas hampir penuh dalam 8 jam ke depan.', style: TextStyle(fontSize: 11)),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLow,
                    child: Icon(Icons.delete_outline, color: AppColors.primary),
                  ),
                  title: Text('${state.pendingSubmissionsCount} Setoran Menunggu Verifikasi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Warga sedang menunggu konfirmasi di fasilitas.', style: TextStyle(fontSize: 11)),
                ),
              ] else if (state.currentRole == UserRole.warga) ...[
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLow,
                    child: Icon(Icons.stars, color: AppColors.primary),
                  ),
                  title: Text('Poin Masuk! +350 pts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Setoran sampah 3.5 kg Anda telah diverifikasi Operator.', style: TextStyle(fontSize: 11)),
                ),
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                  ),
                  title: Text('Voucher Digestate Siap Diambil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Tunjukkan kode VCR-7429 ke petugas TPS RW 05.', style: TextStyle(fontSize: 11)),
                ),
              ] else ...[
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.picture_as_pdf, color: Colors.white),
                  ),
                  title: Text('Laporan Bulanan Tersedia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Rekapitulasi partisipasi warga siap diekspor ke PDF.', style: TextStyle(fontSize: 11)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
      titleSpacing: 16,
      title: Row(
        children: [
          // GasKeun Logo Asset
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'GasKeun Warga',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${profile.rt} / ${profile.rw}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                customTitle ?? 'Portal Warga',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Notification bell with unread dot (Stitch style)
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurfaceVariant, size: 24),
              onPressed: () => _showNotificationsDialog(context, state),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        // User profile avatar chip with logout handler
        InkWell(
          onTap: () => _showLogoutDialog(context, state),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.primaryFixed,
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0] : 'W',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onPrimaryFixed),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  profile.name.split(' ').first,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
