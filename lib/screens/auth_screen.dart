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
  // Mode: 0 = Masuk (Login), 1 = Daftar (Register)
  int _selectedTab = 0;

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

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      final appState = context.read<AppState>();
      final isSuccess = appState.login(email, password);

      setState(() => _isLoading = false);

      if (isSuccess) {
        final profile = appState.activeProfile;
        _showSuccessNotification('Selamat datang, ${profile.name}! (${profile.role.displayName})');
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

    Future.delayed(const Duration(milliseconds: 400), () {
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
        _showSuccessNotification('Pendaftaran berhasil! Selamat bergabung, ${_regNameController.text.trim()}. Bonus 100 Poin telah ditambahkan!');
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
        // Pengguna membatalkan proses sign-in
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
        _errorMessage =
            'Tidak dapat menghubungkan Akun Google: $e\n(Pastikan SHA-1 telah terdaftar di Firebase Console jika menggunakan Android).';
      });
    }
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Brand Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GasKeun Warga',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Portal Warga Biodigester RW 05',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tab Selector: Masuk vs Daftar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                            _errorMessage = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Masuk (Login)',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _selectedTab == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                            _errorMessage = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Daftar Warga',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _selectedTab == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title per Tab
              Text(
                _selectedTab == 0 ? 'Selamat Datang Kembali' : 'Pendaftaran Warga Baru',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedTab == 0
                    ? 'Masuk menggunakan Akun Google atau Email terdaftar Anda.'
                    : 'Daftarkan diri Anda untuk mulai menyetor sampah dan mengumpulkan reward.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Google Auth Button (Available for both Login and Register)
              _buildGoogleButton(),
              const SizedBox(height: 18),

              // Divider "atau dengan email"
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.cardBorder)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau dengan email',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.cardBorder)),
                ],
              ),
              const SizedBox(height: 18),

              // Error banner if any
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Content based on tab
              if (_selectedTab == 0) _buildLoginForm() else _buildRegisterForm(),

              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Untuk berganti akun, silakan tekan tombol "Keluar" di pojok kanan atas aplikasi terlebih dahulu.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Google Sign In / Register Button
  Widget _buildGoogleButton() {
    final label = _selectedTab == 0
        ? 'Masuk dengan Akun Google'
        : 'Daftar Cepat dengan Akun Google';

    return OutlinedButton(
      onPressed: _isLoading ? null : _handleGoogleAuth,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google logo
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.network(
                    'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                    height: 22,
                    width: 22,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
    );
  }

  // Form Login
  Widget _buildLoginForm() {
    final demoAccounts = AppState.demoCredentials;
    final currentEmail = _emailController.text.trim().toLowerCase();

    return Form(
      key: _formKeyLogin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Account Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Pilih Akun Demo Cepat:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ketuk untuk auto-fill',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: demoAccounts.map((account) {
              final isSelected = currentEmail == account.email.toLowerCase();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _selectDemoAccount(account),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            account.role == UserRole.warga
                                ? Icons.person_outline
                                : account.role == UserRole.operator
                                    ? Icons.settings_remote_outlined
                                    : Icons.bar_chart,
                            size: 20,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            account.roleLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account.name.split(' ').first,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Email
          const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'nama@gaskeun.id',
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
              if (!value.contains('@') || !value.contains('.')) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password
          const Text('Kata Sandi (Password)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Minimal 6 karakter',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Password wajib diisi';
              if (value.trim().length < 6) return 'Password minimal 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Submit Login Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailLogin,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Masuk ke Aplikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Form Register Warga
  Widget _buildRegisterForm() {
    return Form(
      key: _formKeyRegister,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reward notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warningLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.stars, color: AppColors.warning, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bonus 100 Poin Selamat Datang langsung aktif setelah pendaftaran akun warga!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nama Lengkap
          const Text('Nama Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regNameController,
            decoration: InputDecoration(
              hintText: 'Contoh: Ahmad Fauzi',
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Nomor WhatsApp & RT Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No. WhatsApp / HP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _regPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '08123456789',
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().length < 9) ? 'Nomor HP tidak valid' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wilayah RT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _regRt,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                      items: ['RT 01', 'RT 02', 'RT 03', 'RT 04', 'RT 05', 'RT 06']
                          .map((rt) => DropdownMenuItem(value: rt, child: Text(rt)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _regRt = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Email
          const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'email@domain.com',
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password
          const Text('Kata Sandi (Password)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Minimal 6 karakter',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().length < 6) ? 'Password minimal 6 karakter' : null,
          ),
          const SizedBox(height: 20),

          // Submit Register Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegisterCitizen,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Daftar Akun Warga Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
