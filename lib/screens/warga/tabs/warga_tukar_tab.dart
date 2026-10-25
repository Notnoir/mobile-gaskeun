import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/reward_model.dart';
import '../../../providers/app_state.dart';

class WargaTukarTab extends StatefulWidget {
  const WargaTukarTab({super.key});

  @override
  State<WargaTukarTab> createState() => _WargaTukarTabState();
}

class _WargaTukarTabState extends State<WargaTukarTab> {
  String _selectedCategory = 'all';

  void _showRedemptionDialog(BuildContext context, RewardItem item) {
    final state = context.read<AppState>();
    final userPoints = state.wargaProfile.points;

    if (userPoints < item.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poin Anda (${userPoints} pts) belum mencukupi untuk ${item.name} (${item.pointsCost} pts).'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Penukaran Poin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda akan menukar poin dengan:',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo Saat Ini:', style: TextStyle(fontSize: 12)),
                      Text('$userPoints pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya Penukaran:', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                      Text('-${item.pointsCost} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    ],
                  ),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sisa Saldo Poin:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('${userPoints - item.pointsCost} pts', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = state.claimReward(item, 1);
              if (success) {
                _showSuccessClaimDialog(context, item);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Tukar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccessClaimDialog(BuildContext context, RewardItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 14),
            const Text(
              'Penukaran Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              'Anda telah menukar ${item.name}. Voucher pengambilan telah diterbitkan dan siap diambil di TPS RW 05.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context, String voucherCode, String rewardTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('QR Voucher Klaim', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.onSurface),
                  const SizedBox(height: 8),
                  Text(
                    voucherCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              rewardTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Arahkan layar ponsel ke scanner petugas di TPS RW 05 untuk verifikasi pengambilan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              foregroundColor: AppColors.onSurface,
              elevation: 0,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.wargaProfile;
    final rewards = state.rewards;
    final claims = state.claims;

    final activeClaim = claims.isNotEmpty ? claims.first : null;

    final filteredRewards = rewards.where((item) {
      if (_selectedCategory == 'all') return true;
      if (_selectedCategory == 'pupuk') {
        return item.name.toLowerCase().contains('pupuk') || item.name.toLowerCase().contains('kompos');
      }
      if (_selectedCategory == 'bibit') {
        return item.name.toLowerCase().contains('bibit');
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saldo Header Card (Stitch Ticket Glow)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.eco_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Saldo Poin Tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.stars_rounded, color: AppColors.secondary, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Warga Aktif',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Formatters.number(profile.points),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Poin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.recycling_rounded, color: AppColors.primaryContainer, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Hasil daur ulang ${profile.currentMonthKg} kg sampah organik di ${profile.rt}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                if (activeClaim != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.redeem_rounded, color: AppColors.primary, size: 16),
                            SizedBox(width: 6),
                            Text(
                              '1 voucher aktif dapat diambil hari ini',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setState(() => _selectedCategory = 'voucher');
                          },
                          child: const Text(
                            'Lihat',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Category Chips (Stitch)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Semua Produk'),
                const SizedBox(width: 8),
                _buildFilterChip('pupuk', 'Pupuk & Kompos'),
                const SizedBox(width: 8),
                _buildFilterChip('bibit', 'Bibit Tanaman'),
                const SizedBox(width: 8),
                _buildFilterChip('voucher', 'Voucher Saya'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Voucher Aktif Section (Stitch Ticket Aesthetic)
          if (_selectedCategory == 'all' || _selectedCategory == 'voucher') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.confirmation_number_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Voucher Siap Diambil',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    ),
                  ],
                ),
                Text(
                  '${claims.length} Tersedia',
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Active Voucher Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Siap Diambil di TPS RW 05',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeClaim != null ? activeClaim.rewardName : 'Pupuk Cair Digestate 1 Liter',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Berlaku s/d akhir bulan berjalan',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 28, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Voucher Code Display & Action
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KODE PENGAMBILAN',
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                                  ),
                                  Text(
                                    activeClaim != null ? activeClaim.voucherCode : 'VCR-7429',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.content_copy_rounded, size: 18, color: AppColors.onSurfaceVariant),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  final code = activeClaim != null ? activeClaim.voucherCode : 'VCR-7429';
                                  Clipboard.setData(ClipboardData(text: code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Kode voucher disalin!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final code = activeClaim != null ? activeClaim.voucherCode : 'VCR-7429';
                          final title = activeClaim != null ? activeClaim.rewardName : 'Pupuk Cair Digestate 1L';
                          _showQrCodeDialog(context, code, title);
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('Buka QR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryFixed,
                          foregroundColor: AppColors.onPrimaryFixed,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, color: AppColors.onSurfaceVariant, size: 14),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tunjukkan kode voucher ini ke petugas TPS saat pengambilan.',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Katalog Reward Section
          if (_selectedCategory != 'voucher') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.storefront_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Katalog Reward Organik',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    ),
                  ],
                ),
                Text(
                  '${filteredRewards.length} Pilihan',
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product Cards List
            ...filteredRewards.map((item) => _buildRewardCard(context, item)),
          ],

          // Gotong Royong Information Card (Stitch)
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Gotong Royong Sirkular',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Poin didapat dari tiap setoran sampah dapur Anda dan diproses bersama di biodigester komunal.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;

    return InkWell(
      onTap: () => setState(() => _selectedCategory = categoryId),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, RewardItem item) {
    String tagLabel = 'Bio-Digester';
    Color tagColor = AppColors.primary;
    if (item.name.toLowerCase().contains('bibit')) {
      tagLabel = 'Ketahanan Pangan';
      tagColor = AppColors.secondary;
    } else if (item.name.toLowerCase().contains('kompos')) {
      tagLabel = 'Siap Tanam';
      tagColor = AppColors.tertiary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Icon / Visual Box
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.name.toLowerCase().contains('bibit')
                      ? Icons.yard_rounded
                      : (item.name.toLowerCase().contains('kompos')
                          ? Icons.park_rounded
                          : Icons.water_drop_rounded),
                  color: tagColor,
                  size: 36,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tagLabel,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: tagColor),
                        ),
                        Text(
                          '${item.stock} stok',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${item.pointsCost}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Poin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('TPS RW 05', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: item.stock > 0 ? () => _showRedemptionDialog(context, item) : null,
                icon: const Icon(Icons.redeem_rounded, size: 15),
                label: const Text('Tukar Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
