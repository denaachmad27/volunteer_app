import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedAnggotaLegislatifId;
  List<Map<String, dynamic>> _anggotaLegislatifOptions = [];
  bool _isLoadingOptions = true;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
    _loadAnggotaLegislatifOptions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAnggotaLegislatifOptions() async {
    try {
      final response = await AuthService.getAnggotaLegislatifOptions();
      if (mounted) {
        setState(() {
          _anggotaLegislatifOptions = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoadingOptions = false;
        });
      }
    } catch (e) {
      print('Error loading anggota legislatif options: $e');
      if (mounted) {
        setState(() {
          _anggotaLegislatifOptions = [];
          _isLoadingOptions = false;
        });
        // Don't show snackbar immediately, let user continue with registration
      }
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await AuthService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          anggotaLegislatifId: _selectedAnggotaLegislatifId!,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.success) {
            // Registration berhasil
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registrasi berhasil! Selamat datang ${response.user?.name}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            
            // Navigate to home (karena auto login setelah register)
            context.go('/home');
          } else {
            // Registration gagal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'Registrasi gagal'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap setujui Syarat & Ketentuan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFF8F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Back Button
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.go('/login');
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Color(0xFFff5001),
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Logo
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFff5001),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFff5001).withOpacity(0.25),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Title
                            const Text(
                              'Join Us Today',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                                letterSpacing: -0.5,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Text(
                              'Start making a difference in your community',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Register Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Full Name Field
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Nama Lengkap',
                                    icon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama lengkap wajib diisi';
                                      }
                                      if (value.length < 2) {
                                        return 'Nama harus minimal 2 karakter';
                                      }
                                      if (value.length > 255) {
                                        return 'Nama maksimal 255 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Email Field
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email wajib diisi';
                                      }
                                      if (!AuthService.isValidEmail(value)) {
                                        return 'Format email tidak valid';
                                      }
                                      if (value.length > 255) {
                                        return 'Email maksimal 255 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Phone Field
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Nomor Telepon (Opsional)',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      // Phone is optional, only validate if provided
                                      if (value != null && value.isNotEmpty) {
                                        if (value.length < 10 || value.length > 15) {
                                          return 'Nomor telepon 10-15 digit';
                                        }
                                        if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
                                          return 'Format nomor telepon tidak valid';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Anggota Legislatif Dropdown
                                  _buildAnggotaLegislatifDropdown(),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Password Field
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Kata Sandi',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    isPasswordVisible: _isPasswordVisible,
                                    onTogglePassword: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Kata sandi wajib diisi';
                                      }
                                      if (value.length < 8) {
                                        return 'Kata sandi minimal 8 karakter';
                                      }
                                      // Check for uppercase letter
                                      if (!value.contains(RegExp(r'[A-Z]'))) {
                                        return 'Kata sandi harus mengandung huruf besar';
                                      }
                                      // Check for lowercase letter
                                      if (!value.contains(RegExp(r'[a-z]'))) {
                                        return 'Kata sandi harus mengandung huruf kecil';
                                      }
                                      // Check for number
                                      if (!value.contains(RegExp(r'[0-9]'))) {
                                        return 'Kata sandi harus mengandung angka';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Confirm Password Field
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Konfirmasi Kata Sandi',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    isPasswordVisible: _isConfirmPasswordVisible,
                                    onTogglePassword: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Konfirmasi kata sandi wajib diisi';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Konfirmasi kata sandi tidak sesuai';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Terms & Conditions
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFFff5001),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'I agree to the ',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Terms & Conditions',
                                                style: TextStyle(
                                                  color: const Color(0xFFff5001),
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' and ',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                  color: const Color(0xFFff5001),
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFff5001),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: const Color(0xFFff5001).withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Login Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.go('/login');
                                        },
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Color(0xFFff5001),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnggotaLegislatifDropdown() {
    if (_isLoadingOptions) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[50],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: const Row(
          children: [
            Icon(Icons.person_outline, color: Color(0xFF667eea)),
            SizedBox(width: 12),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFff5001),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Memuat daftar anggota legislatif...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If no options available, show disabled field
    if (_anggotaLegislatifOptions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[100],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: const Row(
          children: [
            Icon(Icons.person_outline, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Anggota Legislatif (Opsional) - Tidak tersedia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedAnggotaLegislatifId,
      isExpanded: true,
      isDense: true,
      menuMaxHeight: 200.0, // Limit dropdown menu height
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: 'Anggota Legislatif *',
        prefixIcon: Icon(Icons.person_outline, color: Colors.grey[500]),
        hintText: 'Pilih Anggota Legislatif',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: _anggotaLegislatifOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option['id'].toString(),
          child: Text(
            option['nama_lengkap'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih anggota legislatif yang Anda dukung';
        }
        return null;
      },
      onChanged: (String? newValue) {
        setState(() {
          _selectedAnggotaLegislatifId = newValue;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[500],
                ),
                onPressed: onTogglePassword,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}