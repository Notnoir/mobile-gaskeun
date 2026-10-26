import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const AuthScreen({super.key, this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 0 = Masuk (Login), 1 = Daftar (Register)
  int _selectedTab = 0;

  // Toggle email form expansion in Login mode
  bool _showEmailForm = false;

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  // Login controllers
  final TextEditingController _emailController =
      TextEditingController(text: 'warga@gaskeun.id');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');

  // Register controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  String _regRt = 'RT 02';

  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _selectDemoAccount(DemoUserCredential cred) {
    setState(() {
      _emailController.text = cred.email;
      _passwordController.text = cred.password;
      _errorMessage = null;
    });
  }

  // Handle Login Email & Password
  void _handleEmailLogin() {
    setState(() => _errorMessage = null);

    if (!_formKeyLogin.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      final appState = context.read<AppState>();
      final isSuccess = appState.login(email, password);

      setState(() => _isLoading = false);

      if (isSuccess) {
        final profile = appState.activeProfile;
        _showSuccessNotification('Selamat datang, ${profile.name}!');
        widget.onLoginSuccess?.call();
      } else {
        setState(() {
          _errorMessage =
              'Email atau password tidak sesuai. Pastikan email terdaftar dan password minimal 6 karakter.';
        });
      }
    });
  }

  // Handle Registrasi Warga Baru Manual
  void _handleRegisterCitizen() {
    setState(() => _errorMessage = null);

    if (!_formKeyRegister.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      final appState = context.read<AppState>();
      final isSuccess = appState.registerCitizen(
        name: _regNameController.text.trim(),
        email: _regEmailController.text.trim(),
        phone: _regPhoneController.text.trim(),
        rt: _regRt,
        password: _regPasswordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (isSuccess) {
        _showSuccessNotification(
          'Pendaftaran berhasil! Selamat bergabung, ${_regNameController.text.trim()}. Bonus 100 Poin telah ditambahkan!',
        );
        widget.onLoginSuccess?.call();
      }
    });
  }

  // Handle Login / Registrasi Akun Google Asli
  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResult = await AuthService().signInWithGoogle();

      if (authResult == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;

      final appState = context.read<AppState>();
      appState.loginWithGoogleAccount(
        email: authResult.email,
        displayName: authResult.displayName,
      );

      setState(() => _isLoading = false);

      _showSuccessNotification(
        'Berhasil masuk dengan akun Google: ${authResult.displayName}',
      );
      widget.onLoginSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak dapat menghubungkan Akun Google: $e';
      });
    }
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topHeight = (constraints.maxHeight * 0.44).clamp(240.0, 380.0);
          const overlap = 32.0;

          return Stack(
            children: [
              // 1. Top Illustration (Pinned at top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/bg-login-reg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF0F3E36),
                          child: const Center(
                            child: Icon(Icons.eco_rounded, size: 64, color: Colors.white54),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay at bottom edge to smooth intersection with sheet
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Content Layer (Card extends all the way down)
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        // Space revealing top illustration
                        SizedBox(height: topHeight - overlap),

                        // Bottom Sheet Card: Fills all the way to the bottom
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - (topHeight - overlap),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1F065F46),
                                blurRadius: 35,
                                offset: Offset(0, -12),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + bottomInset),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // iOS Grabber Indicator
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),

                                  // Header Title & Subtitle
                                  Text(
                                    _selectedTab == 0 ? 'Selamat Datang' : 'Daftar Akun Warga',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _selectedTab == 0 ? 24 : 22,
                                      fontWeight: FontWeight.w900,
                                      color: _selectedTab == 0
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF134E4A),
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedTab == 0
                                        ? 'Masuk ke akun GasKeun Anda'
                                        : 'Mulai pilah sampah & kumpulkan berkah',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Error Banner
                                  if (_errorMessage != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFCA5A5)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: Color(0xFFDC2626),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Form Content based on Mode
                                  if (_selectedTab == 0)
                                    _buildLoginSection()
                                  else
                                    _buildRegisterSection(),

                                  const SizedBox(height: 20),

                                  // Divider Line with 'atau'
                                  Row(
                                    children: const [
                                      Expanded(child: Divider(color: Color(0xFFF1F5F9), thickness: 1.2)),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'atau',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Color(0xFFF1F5F9), thickness: 1.2)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Bottom Switch Link
                                  if (_selectedTab == 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Belum punya akun? ',
                                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 1;
                                              _errorMessage = null;
                                            });
                                          },
                                          child: const Text(
                                            'Daftar Sekarang',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Sudah punya akun? ',
                                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 0;
                                              _errorMessage = null;
                                            });
                                          },
                                          child: const Text(
                                            'Masuk Sekarang',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),

                              // Subfooter pinned at bottom of card
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Column(
                                  children: const [
                                    Text(
                                      'GasKeun Warga',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Komunitas • Lingkungan • Masa Depan',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== LOGIN SECTION ====================
  Widget _buildLoginSection() {
    return Column(
      children: [
        // Button 1: Google Authentication
        _buildGoogleButton(label: 'Lanjut dengan Google'),
        const SizedBox(height: 12),

        // Collapsible Email Form
        if (_showEmailForm) ...[
          Form(
            key: _formKeyLogin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Alamat Email',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF0F766E), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Kata Sandi',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0F766E), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Password wajib diisi';
                    if (value.trim().length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Quick Demo Account Pill
                Wrap(
                  spacing: 6,
                  children: [
                    InkWell(
                      onTap: () {
                        final cred = AppState.demoCredentials.firstWhere(
                          (c) => c.role == UserRole.warga,
                          orElse: () => AppState.demoCredentials.first,
                        );
                        _selectDemoAccount(cred);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          '⚡ Isi Akun Demo Warga',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],

        // Button 2: Primary Email Action Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    if (!_showEmailForm) {
                      setState(() => _showEmailForm = true);
                    } else {
                      _handleEmailLogin();
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.mail_outline_rounded, size: 20, color: Colors.white),
            label: Text(
              _showEmailForm ? 'Masuk Sekarang' : 'Masuk dengan Email',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E), // brand-700
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REGISTER SECTION ====================
  Widget _buildRegisterSection() {
    return Column(
      children: [
        // Button 1: Google OAuth
        _buildGoogleButton(label: 'Daftar dengan Google'),
        const SizedBox(height: 12),

        // Registration Form Fields
        Form(
          key: _formKeyRegister,
          child: Column(
            children: [
              // Full Name Field
              TextFormField(
                controller: _regNameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Nama Lengkap Warga',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF059669), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nama lengkap wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 9),

              // WhatsApp Field
              TextFormField(
                controller: _regPhoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Nomor WhatsApp (Contoh: 08123456..)',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF059669), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nomor WhatsApp wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 9),

              // RT Dropdown Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city_rounded, color: Color(0xFF059669), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _regRt,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: 'RT 01', child: Text('Wilayah RT 01 / RW 05', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'RT 02', child: Text('Wilayah RT 02 / RW 05', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'RT 03', child: Text('Wilayah RT 03 / RW 05', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'RT 04', child: Text('Wilayah RT 04 / RW 05', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'RT 05', child: Text('Wilayah RT 05 / RW 05', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _regRt = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),

              // Email Field
              TextFormField(
                controller: _regEmailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Alamat Email',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF059669), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                  if (!val.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 9),

              // Password Field
              TextFormField(
                controller: _regPasswordController,
                obscureText: _obscureRegPassword,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Kata Sandi (minimal 6 karakter)',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF059669), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Kata sandi wajib diisi';
                  if (val.trim().length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Primary Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegisterCitizen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // emerald-500
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Lanjut Daftar Akun',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== GOOGLE BUTTON ====================
  Widget _buildGoogleButton({required String label}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleAuth,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google 4-color 'G' Logo
                  _buildGoogleIcon(),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Image.network(
      'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
      height: 20,
      width: 20,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4285F4),
          ),
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
