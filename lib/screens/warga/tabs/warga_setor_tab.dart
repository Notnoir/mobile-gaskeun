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
  String _selectedCategory = 'Sisa Sayur & Dapur';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Sisa Sayur & Dapur',
    'Nasi & Olahan Biji',
    'Kulit Buah-buahan',
    'Ampas Kelapa & Kopi',
    'Sisa Makanan Matang',
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
            const SnackBar(content: Text('Membuka rute ke TPS RW 05...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menavigasi ke TPS RW 05')),
        );
      }
    }
  }

  void _submitWaste() {
    if (_currentWeight <= 0) return;

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final state = context.read<AppState>();
      final submission = state.submitWaste(
        weightKg: _currentWeight,
        category: _selectedCategory,
      );

      setState(() {
        _isSubmitting = false;
        _currentWeight = 2.5;
        _weightController.text = '2.5';
      });

      _showTicketDialog(submission);
    });
  }

  void _showTicketDialog(WasteSubmission submission) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              'Tiket Setoran Dibuat',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tunjukkan kode tiket ini ke petugas saat menyerahkan sampah di TPS.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryContainer),
              ),
              child: Column(
                children: [
                  const Text(
                    'KODE TIKET',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${submission.ticketCode}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${submission.weightKg} kg  •  +${submission.points} Poin',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 40),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Form
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.compost_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Setor Sampah Organik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Pilah dan setor sampah dapur Anda untuk poin',
                    style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Waste Calculator Card - Clean & Intuitive
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
                    const Text(
                      'Estimasi Berat Sampah',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    Text(
                      '1 kg = 100 Poin',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stepper & Weight Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _adjustWeight(-0.5),
                        icon: const Icon(Icons.remove_rounded),
                        color: AppColors.onSurface,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                    fontSize: 30,
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
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _adjustWeight(0.5),
                        icon: const Icon(Icons.add_rounded),
                        color: AppColors.onSurface,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Add Pills
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
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kategori Sampah Dropdown
                const Text(
                  'Kategori Sampah',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
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
                            style: const TextStyle(fontSize: 12.5, color: AppColors.onSurface),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Estimated Points Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taksiran Poin:',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        '+$_estimatedPoints Poin',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Submit Action Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitWaste,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.confirmation_number_rounded, size: 18),
              label: Text(
                _isSubmitting ? 'Menerbitkan Tiket...' : 'Buat Tiket Setoran',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Lokasi TPS
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
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'TPS Biodigester RW 05',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      Text(
                        'Buka setiap hari s/d 17.00 WIB',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _openGoogleMapsRoute,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Rute Maps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Panduan Pilah Singkat
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panduan Pilah Cepat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('✅ Diterima', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          SizedBox(height: 2),
                          Text('Sayur, buah, sisa nasi, ampas kelapa/kopi.', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('❌ Ditolak', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.danger)),
                          SizedBox(height: 2),
                          Text('Plastik, tulang keras, minyak, puntung rokok.', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tiket Aktif
          if (activeSubmission != null)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiket Terakhir',
                        style: TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        '#${activeSubmission.ticketCode}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '${activeSubmission.weightKg} kg (${activeSubmission.wasteCategory})',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activeSubmission.status.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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

  Widget _buildQuickAddPill(String label, double addValue) {
    return InkWell(
      onTap: () => _adjustWeight(addValue),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
