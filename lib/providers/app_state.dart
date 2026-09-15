import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/waste_submission_model.dart';
import '../models/reward_model.dart';
import '../models/iot_sensor_model.dart';
import '../models/report_model.dart';

class AppState extends ChangeNotifier {
  // Current active role & authentication
  UserRole _currentRole = UserRole.warga;
  bool _isAuthenticated = true;

  UserRole get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;

  // Profiles
  late UserProfile _wargaProfile;
  late UserProfile _operatorProfile;
  late UserProfile _pengawasProfile;

  UserProfile get activeProfile {
    switch (_currentRole) {
      case UserRole.warga:
        return _wargaProfile;
      case UserRole.operator:
        return _operatorProfile;
      case UserRole.pengawas:
        return _pengawasProfile;
    }
  }

  UserProfile get wargaProfile => _wargaProfile;

  // Data collections
  final List<WasteSubmission> _submissions = [];
  final List<RewardItem> _rewards = [];
  final List<RewardClaim> _claims = [];
  final List<PredictiveAlert> _alerts = [];
  final List<GeneratedReport> _reports = [];

  // Machine & Sensors
  String machineName = 'Biodigester Komunal BD-RW05';
  String machineLocation = 'Jl. Kenanga RT 02 / RW 05 (Samping Balai Pertemuan)';
  bool isMachineOnline = true;

  SensorMetric _temperatureMetric = SensorMetric(
    name: 'Suhu Reaktor',
    currentValue: 37.4,
    unit: '°C',
    maxValue: 55.0,
    severity: SensorSeverity.normal,
    history7Points: [35.1, 35.6, 36.2, 36.8, 37.0, 37.2, 37.4],
  );

  SensorMetric _pressureMetric = SensorMetric(
    name: 'Tekanan Biogas',
    currentValue: 1045.0,
    unit: 'hPa',
    maxValue: 1200.0,
    severity: SensorSeverity.warning,
    history7Points: [980.0, 995.0, 1010.0, 1025.0, 1032.0, 1038.0, 1045.0],
  );

  Timer? _sensorSimulationTimer;

  // Getters
  List<WasteSubmission> get submissions => List.unmodifiable(_submissions);
  List<RewardItem> get rewards => List.unmodifiable(_rewards);
  List<RewardClaim> get claims => List.unmodifiable(_claims);
  List<PredictiveAlert> get activeAlerts =>
      _alerts.where((a) => !a.isDismissed).toList();
  List<GeneratedReport> get reports => List.unmodifiable(_reports);

  SensorMetric get temperatureMetric => _temperatureMetric;
  SensorMetric get pressureMetric => _pressureMetric;

  // Pending counts
  int get pendingSubmissionsCount =>
      _submissions.where((s) => s.status == SubmissionStatus.menunggu).length;

  int get pendingClaimsCount =>
      _claims.where((c) => c.status == ClaimStatus.menunggu).length;

  int get unreadNotificationsCount {
    if (_currentRole == UserRole.operator) {
      return pendingSubmissionsCount + activeAlerts.length;
    } else if (_currentRole == UserRole.warga) {
      return _submissions
          .where((s) => s.citizenId == _wargaProfile.id && s.status == SubmissionStatus.diterima)
          .length;
    } else {
      return 1; // monthly report ready notice
    }
  }

  AppState() {
    _initInitialData();
    _startSensorSimulation();
  }

  void _initInitialData() {
    _wargaProfile = UserProfile(
      id: 'usr-warga-01',
      name: 'Budi Pratama',
      phone: '0812-3456-7890',
      role: UserRole.warga,
      rw: 'RW 05',
      rt: 'RT 02',
      points: 1250,
      monthlyTargetKg: 25.0,
      currentMonthKg: 18.5,
      monthlySubmissionsCount: 6,
      monthlyClaimsCount: 1,
    );

    _operatorProfile = UserProfile(
      id: 'usr-opr-01',
      name: 'Pak Anton',
      phone: '0813-9876-5432',
      role: UserRole.operator,
      rw: 'RW 05',
      rt: 'RT 03',
    );

    _pengawasProfile = UserProfile(
      id: 'usr-pgw-01',
      name: 'Bu Sari Handayani',
      phone: '0811-2233-4455',
      role: UserRole.pengawas,
      rw: 'RW 05',
      rt: 'RT 01',
    );

    // Initial Submissions
    final now = DateTime.now();
    _submissions.addAll([
      WasteSubmission(
        id: 'sub-001',
        ticketCode: 'GSK-9102',
        citizenId: 'usr-warga-02',
        citizenName: 'Siti Rahma',
        citizenPhone: '0812-8877-1122',
        citizenRt: 'RT 03',
        weightKg: 2.8,
        points: 280,
        wasteCategory: 'Sisa Sayur & Nasi',
        createdAt: now.subtract(const Duration(minutes: 15)),
        status: SubmissionStatus.menunggu,
      ),
      WasteSubmission(
        id: 'sub-002',
        ticketCode: 'GSK-9101',
        citizenId: 'usr-warga-03',
        citizenName: 'Agus Wijaya',
        citizenPhone: '0857-4433-2211',
        citizenRt: 'RT 01',
        weightKg: 4.0,
        points: 400,
        wasteCategory: 'Kulit Buah & Ampas Kelapa',
        createdAt: now.subtract(const Duration(minutes: 42)),
        status: SubmissionStatus.menunggu,
      ),
      WasteSubmission(
        id: 'sub-003',
        ticketCode: 'GSK-9098',
        citizenId: 'usr-warga-01',
        citizenName: 'Budi Pratama',
        citizenPhone: '0812-3456-7890',
        citizenRt: 'RT 02',
        weightKg: 3.5,
        points: 350,
        wasteCategory: 'Organik Basah Rumah Tangga',
        createdAt: now.subtract(const Duration(hours: 3)),
        status: SubmissionStatus.diterima,
        verifiedAt: now.subtract(const Duration(hours: 2, minutes: 40)),
        operatorName: 'Pak Anton',
      ),
      WasteSubmission(
        id: 'sub-004',
        ticketCode: 'GSK-9080',
        citizenId: 'usr-warga-01',
        citizenName: 'Budi Pratama',
        citizenPhone: '0812-3456-7890',
        citizenRt: 'RT 02',
        weightKg: 2.0,
        points: 200,
        wasteCategory: 'Sisa Makanan',
        createdAt: now.subtract(const Duration(days: 2)),
        status: SubmissionStatus.diterima,
        verifiedAt: now.subtract(const Duration(days: 2, hours: -1)),
        operatorName: 'Pak Anton',
      ),
    ]);

    // Initial Reward Catalog
    _rewards.addAll([
      RewardItem(
        id: 'rew-01',
        name: 'Pupuk Cair Digestate 1 Liter',
        description:
            'Pupuk organik cair hasil olahan biodigester siap pakai. Kaya unsur nitrogen, fosfor, dan kalium organik untuk menyuburkan tanaman hias dan sayuran.',
        pointsCost: 1000,
        stock: 36,
        unit: 'Botol 1L',
        iconType: 'liquid',
      ),
      RewardItem(
        id: 'rew-02',
        name: 'Kompos Padat Organik 2 Kg',
        description:
            'Kompos gembur murni hasil fermentasi sisa digestate. Bagus untuk media tanam pot dan kebun rumah warga.',
        pointsCost: 1500,
        stock: 20,
        unit: 'Kantong 2kg',
        iconType: 'compost',
      ),
      RewardItem(
        id: 'rew-03',
        name: 'Bibit Sayur Bayam & Kangkung',
        description:
            'Paket 2 sachet bibit sayuran hijau unggul untuk mendukung program ketahanan pangan pekarangan rumah.',
        pointsCost: 500,
        stock: 50,
        unit: 'Paket Bibit',
        iconType: 'seed',
      ),
    ]);

    // Initial Claims
    _claims.addAll([
      RewardClaim(
        id: 'clm-01',
        voucherCode: 'VCR-7821',
        citizenId: 'usr-warga-02',
        citizenName: 'Siti Rahma',
        citizenPhone: '0812-8877-1122',
        rewardId: 'rew-01',
        rewardName: 'Pupuk Cair Digestate 1 Liter',
        pointsCost: 1000,
        requestedAt: now.subtract(const Duration(minutes: 30)),
        status: ClaimStatus.menunggu,
      ),
      RewardClaim(
        id: 'clm-02',
        voucherCode: 'VCR-7790',
        citizenId: 'usr-warga-01',
        citizenName: 'Budi Pratama',
        citizenPhone: '0812-3456-7890',
        rewardId: 'rew-01',
        rewardName: 'Pupuk Cair Digestate 1 Liter',
        pointsCost: 1000,
        requestedAt: now.subtract(const Duration(days: 4)),
        status: ClaimStatus.selesai,
        completedAt: now.subtract(const Duration(days: 4, hours: -1)),
      ),
    ]);

    // Initial Predictive Alert
    _alerts.add(
      PredictiveAlert(
        id: 'alt-01',
        title: 'Prediksi Tekanan Gas Penuh',
        message:
            'Laju akumulasi gas meningkat +18%. Tekanan diprediksi mencapai batas kapasitas 1.150 hPa dalam 8 jam ke depan. Disarankan alirkan ke jaringan kompor warga.',
        severity: SensorSeverity.warning,
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
    );

    // Initial Reports
    _reports.addAll([
      GeneratedReport(
        id: 'rep-08-2026',
        title: 'Laporan Ekosistem Biodigester RW 05',
        period: 'Agustus 2026',
        fileName: 'Laporan_GasKeun_RW05_Agu_2026.pdf',
        fileSize: '412 KB',
        generatedAt: DateTime(2026, 8, 31, 16, 0),
      ),
      GeneratedReport(
        id: 'rep-07-2026',
        title: 'Laporan Ekosistem Biodigester RW 05',
        period: 'Juli 2026',
        fileName: 'Laporan_GasKeun_RW05_Jul_2026.pdf',
        fileSize: '398 KB',
        generatedAt: DateTime(2026, 7, 31, 15, 30),
      ),
    ]);
  }

  // Sensor Real-time Simulation
  void _startSensorSimulation() {
    _sensorSimulationTimer?.cancel();
    _sensorSimulationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      triggerSensorFluctuation();
    });
  }

  void triggerSensorFluctuation() {
    final random = Random();
    // Suhu fluctuates between 36.5 and 38.5
    final tempDelta = (random.nextDouble() - 0.5) * 0.4;
    final newTemp = double.parse((_temperatureMetric.currentValue + tempDelta).toStringAsFixed(1));
    final updatedTempHistory = List<double>.from(_temperatureMetric.history7Points.sublist(1))
      ..add(newTemp);

    SensorSeverity tempSeverity = SensorSeverity.normal;
    if (newTemp > 45) {
      tempSeverity = SensorSeverity.critical;
    } else if (newTemp > 40) {
      tempSeverity = SensorSeverity.warning;
    }

    _temperatureMetric = SensorMetric(
      name: 'Suhu Reaktor',
      currentValue: newTemp,
      unit: '°C',
      maxValue: 55.0,
      severity: tempSeverity,
      history7Points: updatedTempHistory,
    );

    // Tekanan fluctuates between 1010 and 1070
    final pressureDelta = (random.nextDouble() - 0.45) * 8.0;
    final newPressure =
        double.parse((_pressureMetric.currentValue + pressureDelta).toStringAsFixed(0));
    final updatedPressureHistory = List<double>.from(_pressureMetric.history7Points.sublist(1))
      ..add(newPressure);

    SensorSeverity pressureSeverity = SensorSeverity.normal;
    if (newPressure > 1100) {
      pressureSeverity = SensorSeverity.critical;
    } else if (newPressure > 1030) {
      pressureSeverity = SensorSeverity.warning;
    }

    _pressureMetric = SensorMetric(
      name: 'Tekanan Biogas',
      currentValue: newPressure,
      unit: 'hPa',
      maxValue: 1200.0,
      severity: pressureSeverity,
      history7Points: updatedPressureHistory,
    );

    notifyListeners();
  }

  // Role switching
  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void updateMachineLocation(String name, String location) {
    machineName = name;
    machineLocation = location;
    notifyListeners();
  }

  // Warga Actions: Submit Waste
  WasteSubmission submitWaste({
    required double weightKg,
    required String category,
  }) {
    final randomCode = 'GSK-${1000 + Random().nextInt(8999)}';
    final points = (weightKg * 100).round();

    final submission = WasteSubmission(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      ticketCode: randomCode,
      citizenId: _wargaProfile.id,
      citizenName: _wargaProfile.name,
      citizenPhone: _wargaProfile.phone,
      citizenRt: _wargaProfile.rt,
      weightKg: weightKg,
      points: points,
      wasteCategory: category,
      createdAt: DateTime.now(),
      status: SubmissionStatus.menunggu,
    );

    _submissions.insert(0, submission);
    notifyListeners();
    return submission;
  }

  // Operator Actions: Verify Waste Submission
  void verifySubmission(String submissionId, bool accepted) {
    final index = _submissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      final sub = _submissions[index];
      sub.status = accepted ? SubmissionStatus.diterima : SubmissionStatus.ditolak;
      sub.verifiedAt = DateTime.now();
      sub.operatorName = _operatorProfile.name;

      if (accepted && sub.citizenId == _wargaProfile.id) {
        _wargaProfile.points += sub.points;
        _wargaProfile.currentMonthKg += sub.weightKg;
        _wargaProfile.monthlySubmissionsCount += 1;
      }

      notifyListeners();
    }
  }

  // Warga Actions: Redeem Points
  bool claimReward(RewardItem item, int quantity) {
    final totalCost = item.pointsCost * quantity;
    if (_wargaProfile.points < totalCost || item.stock < quantity) {
      return false;
    }

    _wargaProfile.points -= totalCost;
    item.stock -= quantity;
    _wargaProfile.monthlyClaimsCount += quantity;

    final voucherCode = 'VCR-${1000 + Random().nextInt(8999)}';
    final claim = RewardClaim(
      id: 'clm-${DateTime.now().millisecondsSinceEpoch}',
      voucherCode: voucherCode,
      citizenId: _wargaProfile.id,
      citizenName: _wargaProfile.name,
      citizenPhone: _wargaProfile.phone,
      rewardId: item.id,
      rewardName: item.name,
      pointsCost: totalCost,
      quantity: quantity,
      requestedAt: DateTime.now(),
      status: ClaimStatus.menunggu,
    );

    _claims.insert(0, claim);
    notifyListeners();
    return true;
  }

  // Operator Actions: Complete Claim
  void completeClaim(String claimId) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].status = ClaimStatus.selesai;
      _claims[index].completedAt = DateTime.now();
      notifyListeners();
    }
  }

  // Operator Actions: Dismiss AI Alert
  void dismissAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index].isDismissed = true;
      notifyListeners();
    }
  }

  // Pengawas RW Metrics
  double get totalWasteKgRW {
    double base = 512.5;
    for (final s in _submissions) {
      if (s.status == SubmissionStatus.diterima) {
        base += s.weightKg;
      }
    }
    return base;
  }

  double get totalBiogasM3RW => (totalWasteKgRW * 0.42);
  double get totalDigestateLRW => (totalWasteKgRW * 0.78);
  int get activeKkCount => 84;
  int get totalKkRW => 120;

  List<RtParticipationData> get rtParticipationList {
    return [
      RtParticipationData(
        rtName: 'RT 01',
        activeKk: 18,
        totalKk: 22,
        totalWasteKg: 112.4,
        isTargetReached: true,
      ),
      RtParticipationData(
        rtName: 'RT 02',
        activeKk: 16,
        totalKk: 20,
        totalWasteKg: 104.8,
        isTargetReached: true,
      ),
      RtParticipationData(
        rtName: 'RT 03',
        activeKk: 15,
        totalKk: 20,
        totalWasteKg: 88.6,
        isTargetReached: false,
      ),
      RtParticipationData(
        rtName: 'RT 04',
        activeKk: 14,
        totalKk: 18,
        totalWasteKg: 79.2,
        isTargetReached: false,
      ),
      RtParticipationData(
        rtName: 'RT 05',
        activeKk: 11,
        totalKk: 20,
        totalWasteKg: 68.5,
        isTargetReached: false,
      ),
      RtParticipationData(
        rtName: 'RT 06',
        activeKk: 10,
        totalKk: 20,
        totalWasteKg: 59.0,
        isTargetReached: false,
      ),
    ];
  }

  List<MonthlyParticipationTrend> get monthlyParticipationTrends {
    return [
      MonthlyParticipationTrend(monthLabel: 'Apr', activeKk: 45, wasteKg: 280),
      MonthlyParticipationTrend(monthLabel: 'Mei', activeKk: 56, wasteKg: 340),
      MonthlyParticipationTrend(monthLabel: 'Jun', activeKk: 64, wasteKg: 395),
      MonthlyParticipationTrend(monthLabel: 'Jul', activeKk: 72, wasteKg: 440),
      MonthlyParticipationTrend(monthLabel: 'Agu', activeKk: 78, wasteKg: 490),
      MonthlyParticipationTrend(monthLabel: 'Sep', activeKk: 84, wasteKg: 520),
    ];
  }

  void addGeneratedReport(GeneratedReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorSimulationTimer?.cancel();
    super.dispose();
  }
}
