import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class WargaEdukasiTab extends StatefulWidget {
  const WargaEdukasiTab({super.key});

  @override
  State<WargaEdukasiTab> createState() => _WargaEdukasiTabState();
}

class _WargaEdukasiTabState extends State<WargaEdukasiTab> {
  bool _showAllowed = true;

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/6281234567890?text=Halo%20Koordinator%20GasKeun%20RT%2002,%20saya%20ingin%20tanya%20seputar%20pemilahan%20sampah',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menghubungi Koordinator WhatsApp...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menghubungi Koordinator WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Panduan Pemilahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Pilah sampah dapur untuk hasilkan energi biogas',
                    style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2-tab Pill Selector (Diterima vs Dilarang)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showAllowed = true),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _showAllowed ? AppColors.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _showAllowed
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: _showAllowed ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Diterima (Bisa)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _showAllowed ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showAllowed = false),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_showAllowed ? AppColors.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_showAllowed
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_rounded,
                            size: 16,
                            color: !_showAllowed ? AppColors.danger : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Dilarang (Bahaya)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !_showAllowed ? AppColors.danger : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Guideline Card
          if (_showAllowed)
            _buildGuidelineCard(
              title: 'Sampah yang Diterima',
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.primary,
              items: const [
                _GuideItem(
                  icon: Icons.eco_rounded,
                  title: 'Sayuran & Kulit Buah',
                  desc: 'Sisa sayur sop, kangkung, kulit pisang, pepaya, semangka.',
                ),
                _GuideItem(
                  icon: Icons.rice_bowl_rounded,
                  title: 'Nasi Sisa & Roti Basi',
                  desc: 'Karbohidrat cepat terurai menghasilkan metana tinggi.',
                ),
                _GuideItem(
                  icon: Icons.bakery_dining_rounded,
                  title: 'Ampas Kelapa, Tahu & Kopi',
                  desc: 'Sumber nutrisi baik bagi mikroorganisme pengurai.',
                ),
                _GuideItem(
                  icon: Icons.yard_rounded,
                  title: 'Dedaunan Kering Halus',
                  desc: 'Rontokan daun taman yang sudah dicacah kecil.',
                ),
              ],
            )
          else
            _buildGuidelineCard(
              title: 'Sampah yang Dilarang',
              icon: Icons.cancel_rounded,
              iconColor: AppColors.danger,
              isDangerous: true,
              items: const [
                _GuideItem(
                  icon: Icons.warning_rounded,
                  title: 'Tulang Hewan Keras',
                  desc: 'Tulang sapi/kambing menyumbat pipa biodigester.',
                ),
                _GuideItem(
                  icon: Icons.block_rounded,
                  title: 'Plastik & Karet',
                  desc: 'Anorganik tidak terurai, harus masuk tong daur ulang.',
                ),
                _GuideItem(
                  icon: Icons.soap_rounded,
                  title: 'Minyak Jelantah & Sabun',
                  desc: 'Dapat meracuni bakteri anaerob penghasil gas.',
                ),
                _GuideItem(
                  icon: Icons.smoking_rooms_rounded,
                  title: 'Puntung Rokok & Baterai',
                  desc: 'Zat kimia berbahaya merusak reaktor.',
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Ringkasan Manfaat
          const Text(
            'Manfaat Energi Bersih',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.local_fire_department_rounded, color: AppColors.secondary, size: 22),
                      SizedBox(height: 6),
                      Text(
                        'Biogas Dapur',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '10 kg sampah = 2-3 jam api kompor warga.',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 22),
                      SizedBox(height: 6),
                      Text(
                        'Pupuk Alami',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Digestate cair subur siap pakai untuk kebun.',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hubungi Koordinator
          Container(
            padding: const EdgeInsets.all(14),
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
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tanya Koordinator RT',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      Text(
                        'Konsultasi cara pemilahan sampah',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  icon: const Icon(Icons.chat_rounded, size: 14),
                  label: const Text('Chat', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildGuidelineCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_GuideItem> items,
    bool isDangerous = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDangerous ? AppColors.danger : AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDangerous
                          ? AppColors.errorContainer.withValues(alpha: 0.25)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(item.icon, size: 15, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        Text(
                          item.desc,
                          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GuideItem {
  final IconData icon;
  final String title;
  final String desc;

  const _GuideItem({
    required this.icon,
    required this.title,
    required this.desc,
  });
}
