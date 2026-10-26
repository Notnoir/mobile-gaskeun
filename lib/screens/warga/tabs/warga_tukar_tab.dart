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
          content: Text('Poin Anda ($userPoints pts) belum mencukupi untuk ${item.name} (${item.pointsCost} pts).'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Penukaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      Text('${item.pointsCost} Poin', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sisa Poin:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      Text('${userPoints - item.pointsCost} Poin', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
            child: const Text('Tukar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccessClaimDialog(BuildContext context, RewardItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'Penukaran Berhasil!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              'Voucher untuk ${item.name} siap diambil di TPS RW 05.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
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
          // Saldo Card - Clean & Minimalist
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Saldo Poin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Warga Aktif',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Formatters.number(profile.points),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Poin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Setara ${(profile.points / 100).toStringAsFixed(1)} kg sampah daur ulang',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                ),
                if (activeClaim != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => setState(() => _selectedCategory = 'voucher'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 15),
                              SizedBox(width: 6),
                              Text(
                                'Ada 1 voucher siap diambil',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                              ),
                            ],
                          ),
                          const Text(
                            'Lihat Voucher →',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filter Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Semua'),
                const SizedBox(width: 8),
                _buildFilterChip('pupuk', 'Pupuk & Kompos'),
                const SizedBox(width: 8),
                _buildFilterChip('bibit', 'Bibit'),
                const SizedBox(width: 8),
                _buildFilterChip('voucher', 'Voucher Saya'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Voucher Aktif Section (Clean - Tanpa QR Code)
          if ((_selectedCategory == 'all' || _selectedCategory == 'voucher') && claims.isNotEmpty) ...[
            const Text(
              'Voucher Saya',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),

            // Active Voucher Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Siap Diambil di TPS RW 05',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.date(activeClaim!.requestedAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeClaim.rewardName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Voucher Code Display Box (Clean, Copyable, No QR)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              'KODE VOUCHER',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeClaim.voucherCode,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: activeClaim.voucherCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode voucher disalin!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.content_copy_rounded, size: 14),
                          label: const Text('Salin', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primaryContainer),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tunjukkan kode ini ke petugas saat pengambilan barang.',
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Katalog Reward Section
          if (_selectedCategory != 'voucher') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Katalog Reward',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                Text(
                  '${filteredRewards.length} Pilihan',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product Cards List
            ...filteredRewards.map((item) => _buildRewardCard(context, item)),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;

    return InkWell(
      onTap: () => setState(() => _selectedCategory = categoryId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
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
    Color tagColor = AppColors.primary;
    if (item.name.toLowerCase().contains('bibit')) {
      tagColor = AppColors.secondary;
    } else if (item.name.toLowerCase().contains('kompos')) {
      tagColor = AppColors.tertiary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.name.toLowerCase().contains('bibit')
                  ? Icons.yard_rounded
                  : (item.name.toLowerCase().contains('kompos')
                      ? Icons.park_rounded
                      : Icons.water_drop_rounded),
              color: tagColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.pointsCost} Poin',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  Stok ${item.stock}',
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tukar Button
          ElevatedButton(
            onPressed: item.stock > 0 ? () => _showRedemptionDialog(context, item) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tukar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
