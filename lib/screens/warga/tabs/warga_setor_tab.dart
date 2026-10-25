import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/waste_submission_model.dart';
import '../../../providers/app_state.dart';

class WargaSetorTab extends StatefulWidget {
  const WargaSetorTab({super.key});

  @override
  State<WargaSetorTab> createState() => _WargaSetorTabState();
}

class _WargaSetorTabState extends State<WargaSetorTab> {
  double _currentWeight = 2.5;
  late final TextEditingController _weightController;
  String _selectedCategory = 'Sisa Dapur & Sayuran';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Sisa Dapur & Sayuran',
    'Nasi, Roti & Olahan Biji',
    'Kulit Buah-buahan',
    'Ampas Kelapa & Teh/Kopi',
    'Sisa Makanan Matang (Tanpa Tulang Keras)',
  ];

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: _currentWeight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  int get _estimatedPoints => (_currentWeight * 100).round();

  void _adjustWeight(double delta) {
    setState(() {
      _currentWeight = (_currentWeight + delta).clamp(0.5, 50.0);
      _currentWeight = double.parse(_currentWeight.toStringAsFixed(1));
      _weightController.text = _currentWeight.toStringAsFixed(1);
    });
  }

  void _resetWeight() {
    setState(() {
      _currentWeight = 1.0;
      _weightController.text = _currentWeight.toStringAsFixed(1);
    });
  }

  void _onWeightTextChanged(String text) {
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      setState(() {
        _currentWeight = parsed;
      });
    }
  }

  Future<void> _openGoogleMapsRoute() async {
    const googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=-6.200000,106.816666';
    final uri = Uri.parse(googleMapsUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka rute ke Fasilitas Biodigester RW 05...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menavigasi ke Fasilitas Biodigester RW 05')),
        );
      }
    }
  }

  void _submitWaste() {
    if (_currentWeight <= 0) return;

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final state = context.read<AppState>();
      final submission = state.submitWaste(
        weightKg: _currentWeight,
        category: _selectedCategory,
      );

      setState(() {
        _isSubmitting = false;
        _currentWeight = 2.5;
      });

      _showTicketDialog(submission);
    });
  }

  void _showTicketDialog(WasteSubmission submission) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tiket Setoran Dibuat!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tunjukkan kode tiket ini kepada petugas operator biodigester saat menyerahkan ember sampah di TPS.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryContainer, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'KODE TIKET DIGITAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${submission.ticketCode}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimasi Berat: ${submission.weightKg} kg',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '+${submission.points} Poin',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 44),
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
    final activeSubmission = state.submissions.isNotEmpty
        ? state.submissions.firstWhere(
            (s) => s.status == SubmissionStatus.menunggu,
            orElse: () => state.submissions.first,
          )
        : null;

    final estimatedGasHours = (_currentWeight * 0.12).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Banner RT/RW Edukasi Ramah (Stitch)
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compost_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Formulir Setor Sampah Dapur',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Hanya menerima sampah basah dapur (sisa sayur, buah, nasi, ampas kelapa) untuk diolah di instalasi biodigester warga.',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Waste Converter Calculator (Stitch)
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
                        Icon(Icons.scale_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Estimasi Berat Sampah',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '1 kg = 100 Poin',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Stepper & Weight Display (Stitch)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _adjustWeight(-0.5),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.remove_rounded, color: AppColors.onSurface, size: 22),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: IntrinsicWidth(
                                child: TextField(
                                  controller: _weightController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  onChanged: _onWeightTextChanged,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'kg',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _adjustWeight(0.5),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: AppColors.onSurface, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Add Pills & Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickAddPill('+0.5 kg', 0.5),
                    const SizedBox(width: 8),
                    _buildQuickAddPill('+1.0 kg', 1.0),
                    const SizedBox(width: 8),
                    _buildQuickAddPill('+2.0 kg', 2.0),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _resetWeight,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Estimated Reward Highlight Card (Stitch)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Taksiran Perolehan',
                                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                '+$_estimatedPoints Poin',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Setara Gas ~$estimatedGasHours Jam',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryFixedVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Micro Disclaimer
                Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppColors.outline, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Timbangan final akan divalidasi langsung secara digital oleh Operator di TPS.',
                        style: TextStyle(fontSize: 11, color: AppColors.outline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dropdown Kategori Sampah
                const Text(
                  'Kategori Sampah',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Action Submission Button (Stitch)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitWaste,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.qr_code_2_rounded, size: 20),
              label: Text(
                _isSubmitting ? 'Menerbitkan Tiket...' : 'Konfirmasi & Buat Tiket Setoran',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TPS Location & Navigation Card (Stitch)
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
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'TPS Biodigester RW 05',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                            ),
                            Text(
                              'Pusat Pengolahan Organik Komunal',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Buka',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryFixedVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text('150 m dari domisili Anda', style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant)),
                    SizedBox(width: 10),
                    Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                    SizedBox(width: 10),
                    Icon(Icons.schedule_rounded, color: AppColors.secondary, size: 16),
                    SizedBox(width: 4),
                    Text('Buka s/d 17.00 WIB', style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _openGoogleMapsRoute,
                    icon: const Icon(Icons.near_me_rounded, size: 18, color: AppColors.primary),
                    label: const Text(
                      'Buka Rute Google Maps',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Visual Sorting Guide (Diterima vs Ditolak - Stitch)
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
                const Text(
                  'Panduan Pilah Cepat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diterima
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Diterima',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Kulit buah, sayuran hijau, nasi basi, ampas tahu & kelapa parut.',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Ditolak
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.cancel_rounded, color: AppColors.danger, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Ditolak',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.danger),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Plastik, tulang keras besar, puntung rokok, baterai, minyak.',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active / Recent Ticket Card (Stitch)
          if (activeSubmission != null)
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
                          Icon(Icons.confirmation_number_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tiket Aktif Saat Ini',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activeSubmission.status.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kode Tiket Penimbangan',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              '#${activeSubmission.ticketCode}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Target Berat',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              '${activeSubmission.weightKg} kg',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.contactless_rounded, color: AppColors.onSurfaceVariant, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tunjukkan kode ini kepada Operator TPS saat Anda menyerahkan ember sampah.',
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
      ),
    );
  }

  Widget _buildQuickAddPill(String label, double addValue) {
    return InkWell(
      onTap: () => _adjustWeight(addValue),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
