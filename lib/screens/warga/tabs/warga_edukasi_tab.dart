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
            const SnackBar(content: Text('Menghubungi Koordinator WhatsApp RT 02...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menghubungi Koordinator WhatsApp RT 02')),
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
          // Header Title & Subtitle (Stitch)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.eco_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Kompos & Energi Bersih',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pusat Edukasi Warga',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Panduan praktis memilah sampah organik dan manfaat energi biogas untuk RT/RW kita.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Do's & Don'ts Toggle Selector (Stitch)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Panduan Pemilahan Sampah',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
              ),
              Text(
                'Standar RT 02',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-tab Pill Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
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
                                  color: Colors.black.withValues(alpha: 0.05),
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
                              fontWeight: FontWeight.w800,
                              color: _showAllowed ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
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
                                  color: Colors.black.withValues(alpha: 0.05),
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
                              fontWeight: FontWeight.w800,
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

          // Content Box Diterima vs Dilarang
          if (_showAllowed)
            _buildGuidelineCard(
              title: 'Kategori Sampah Diterima',
              subtitle: 'Langsung dicerna bakteri biodigester',
              icon: Icons.check_rounded,
              iconColor: AppColors.primary,
              items: const [
                _GuideItem(
                  icon: Icons.eco_rounded,
                  title: 'Sisa Sayuran Mentah & Matang',
                  desc: 'Sawi, kangkung, wortel, sop sisa tanpa plastik pengikat.',
                ),
                _GuideItem(
                  icon: Icons.restaurant_rounded,
                  title: 'Kulit Buah-buahan',
                  desc: 'Kulit pisang, pepaya, mangga, semangka (potong kecil).',
                ),
                _GuideItem(
                  icon: Icons.rice_bowl_rounded,
                  title: 'Nasi Sisa & Roti Basi',
                  desc: 'Karbohidrat cepat difermentasi menghasilkan metana tinggi.',
                ),
                _GuideItem(
                  icon: Icons.bakery_dining_rounded,
                  title: 'Ampas Kelapa, Tahu & Kopi',
                  desc: 'Kaya nutrisi bagi mikroorganisme pengurai.',
                ),
                _GuideItem(
                  icon: Icons.yard_rounded,
                  title: 'Dedaunan Kering Halus',
                  desc: 'Rontokan daun halaman yang sudah dicacah/diremas.',
                ),
              ],
            )
          else
            _buildGuidelineCard(
              title: 'Kategori Dilarang Keras',
              subtitle: 'Dapat merusak & meracuni bakteri anaerob',
              icon: Icons.close_rounded,
              iconColor: AppColors.danger,
              isDangerous: true,
              items: const [
                _GuideItem(
                  icon: Icons.warning_rounded,
                  title: 'Tulang Sapi & Kambing Besar',
                  desc: 'Tidak bisa hancur dan menyumbat pipa intake biodigester.',
                ),
                _GuideItem(
                  icon: Icons.block_rounded,
                  title: 'Plastik, Karet, & Styrofoam',
                  desc: 'Anorganik tidak terurai, harus masuk tong daur ulang.',
                ),
                _GuideItem(
                  icon: Icons.smoking_rooms_rounded,
                  title: 'Puntung Rokok & Obat Kedaluwarsa',
                  desc: 'Racun nikotin & kimia membunuh mikroflora biogas aktif.',
                ),
                _GuideItem(
                  icon: Icons.soap_rounded,
                  title: 'Minyak Jelantah & Air Sabun Deterjen',
                  desc: 'Membunuh bakteri metanogen secara permanen.',
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Visual Break / Illustrated Feature Box
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006C49), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_rounded, color: AppColors.primaryFixed, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Fasilitas Komunal RT 02 / RW 05',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Mengolah Sampah Dapur Menjadi Energi Bersih',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Setiap ember sampah yang Anda pilah berkontribusi langsung pada kompor warga dan pupuk tanaman lingkungan.',
                        style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Proses Anaerobik Alami',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        Text(
                          '100% tanpa bahan kimia tambahan',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Higienis & Aman',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fakta Edukatif Lingkungan (Eco Trivia Cards - Stitch)
          Row(
            children: const [
              Icon(Icons.lightbulb_rounded, color: AppColors.secondaryContainer, size: 20),
              SizedBox(width: 8),
              Text(
                'Fakta Edukatif Lingkungan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Trivia Card 1: Siklus Sirkular Biogas
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.sync_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Siklus Sirkular Biogas',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Fakta #1',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '10 kg sampah organik warga menghasilkan biogas setara memasak 2-3 jam kompor gas ramah lingkungan tanpa emisi berbahaya.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.3),
                ),
                const SizedBox(height: 10),
                // Mini Graphic Metric
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Sampah Organik', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                            SizedBox(height: 2),
                            Text('10 Kilogram', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Text('Dari 4-5 Dapur Warga', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Output Energi', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                            SizedBox(height: 2),
                            Text('2 - 3 Jam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Text('Nyalakan Kompor', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trivia Card 2: Keunggulan Pupuk Digestate
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.compost_rounded, color: AppColors.tertiary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Keunggulan Pupuk Digestate',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.tertiary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Fakta #2',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cairan hasil proses biodigester mengandung mikroba baik yang menyuburkan tanah lebih cepat dari pupuk kimia buatan tanpa merusak ekosistem cacing tanah lokal.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurface, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.water_drop_rounded, color: AppColors.tertiary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Gratis untuk Warga RT 02',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                            Text(
                              'Bisa diambil di depo TPS untuk tanaman pot & kebun pekarangan.',
                              style: TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tanya Jawab Komunitas (FAQ Ringkas)
          Row(
            children: const [
              Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Tanya Jawab Komunitas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFaqItem(
            q: 'Apakah sampah berkuah boleh disetor?',
            a: 'Tiriskan kuah terlebih dahulu agar tidak terlalu cair. Biodigester membutuhkan konsistensi bubur padat yang seimbang agar proses fermentasi tetap optimal.',
          ),
          const SizedBox(height: 8),
          _buildFaqItem(
            q: 'Kapan jadwal buka TPS Biodigester?',
            a: 'Setiap hari pukul 06.30 – 17.00 WIB. Petugas operator warga siap membantu penimbangan dan pencatatan poin Anda.',
          ),
          const SizedBox(height: 16),

          // Callout Bantuan RT/RW
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
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Butuh Bantuan Pemilahan?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                          ),
                          Text(
                            'Koordinator lingkungan RT 02 siap menjawab pertanyaan Anda.',
                            style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _launchWhatsApp,
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text(
                      'Chat WhatsApp Koordinator',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<_GuideItem> items,
    bool isDangerous = false,
  }) {
    return Container(
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
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDangerous ? AppColors.errorContainer : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDangerous ? AppColors.danger : AppColors.onSurface,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDangerous ? AppColors.errorContainer.withValues(alpha: 0.2) : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 18, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.desc,
                          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
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

  Widget _buildFaqItem({required String q, required String a}) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'T',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              a,
              style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant, height: 1.35),
            ),
          ),
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
