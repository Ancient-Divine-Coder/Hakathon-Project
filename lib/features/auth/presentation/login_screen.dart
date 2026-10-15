import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum PortalRole { faculty, admin }

class LoginScreen extends StatefulWidget {
  final ValueChanged<PortalRole>? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  PortalRole _selectedRole = PortalRole.faculty;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  void _switchRole(PortalRole role) {
    if (_selectedRole == role) return;
    setState(() {
      _selectedRole = role;
      _idController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signIn(
        idOrEmail: _idController.text,
        password: _passwordController.text,
        expectedRole: _selectedRole,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Welcome, ${user.name} (${user.role.toUpperCase()})',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

      widget.onLoginSuccess?.call(_selectedRole);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.toString(),
                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFaculty = _selectedRole == PortalRole.faculty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border.withValues(alpha: 0.6),
            height: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Smart Campus ERP',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.3,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Institutional Portal',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.lock_outline,
                    size: 13,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SSO',
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient decorative soft gradient backdrop
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEEF2FF).withValues(alpha: 0.8),
                    const Color(0xFFEEF2FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE0F2FE).withValues(alpha: 0.7),
                    const Color(0xFFE0F2FE).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Card Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Academic Header
                          Center(
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isFaculty
                                      ? [
                                          const Color(0xFFEEF2FF),
                                          const Color(0xFFE0E7FF),
                                        ]
                                      : [
                                          const Color(0xFFFEF3C7),
                                          const Color(0xFFFDE68A),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isFaculty
                                      ? const Color(0xFFC7D2FE)
                                      : const Color(0xFFFCD34D),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isFaculty
                                            ? const Color(0xFF6366F1)
                                            : const Color(0xFFF59E0B))
                                        .withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFaculty
                                    ? Icons.account_balance_outlined
                                    : Icons.admin_panel_settings_outlined,
                                size: 26,
                                color: isFaculty
                                    ? const Color(0xFF3730A3)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isFaculty
                                ? 'Institutional Access'
                                : 'Administrator Access',
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.4,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isFaculty
                                ? 'Centralized Campus Directory & Governance'
                                : 'ERP Infrastructure & Campus Security Control',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 13,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Staff / Admin ID Input
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  isFaculty ? 'Faculty Staff ID' : 'Administrator ID',
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  isFaculty ? 'FAC-SYS' : 'ADM-ROOT',
                                  style: AppTypography.codeSm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _idController,
                            style: AppTypography.bodyMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.8,
                                ),
                              ),
                              hintText: isFaculty
                                  ? 'e.g., faculty1'
                                  : 'e.g., ADMIN',
                              hintStyle: AppTypography.bodyMd.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                              suffixIcon: _idController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 16,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      onPressed: () {
                                        _idController.clear();
                                        setState(() {});
                                      },
                                      tooltip: 'Clear ID',
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          Text(
                            'Password',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTypography.bodyMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.8,
                                ),
                              ),
                              hintText: '••••••••••••',
                              hintStyle: AppTypography.bodyMd.copyWith(
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.key_outlined,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Remember ID Checkbox
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() => _rememberMe = !_rememberMe);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: const Color(0xFF0F172A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF94A3B8),
                                        width: 1.5,
                                      ),
                                      onChanged: (val) {
                                        setState(() => _rememberMe = val ?? false);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember ID on this device',
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 13,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Sign In Button
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(
                                    alpha: _isLoading ? 0.05 : 0.2,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading ? null : _handleSignIn,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.login_rounded,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            isFaculty
                                                ? 'Sign In to Faculty Portal'
                                                : 'Sign In to Admin Portal',
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.labelMd.copyWith(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Operational Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF10B981),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'All Campus Identity Services Operational',
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF15803D),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Divider(
                            color: Color(0xFFF1F5F9),
                            height: 1,
                            thickness: 1.2,
                          ),
                          const SizedBox(height: 14),

                          // Admin Login / Faculty Login switch positioned at the bottom
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                isFaculty
                                    ? 'Need administrative access?'
                                    : 'Returning to faculty portal?',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () => _switchRole(
                                  isFaculty
                                      ? PortalRole.admin
                                      : PortalRole.faculty,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isFaculty
                                            ? Icons.admin_panel_settings_outlined
                                            : Icons.school_outlined,
                                        size: 15,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isFaculty
                                            ? 'Admin Login'
                                            : 'Faculty Login',
                                        style: AppTypography.labelSm.copyWith(
                                          color: const Color(0xFF2563EB),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        isFaculty
                                            ? Icons.arrow_forward_ios
                                            : Icons.arrow_back_ios,
                                        size: 10,
                                        color: const Color(0xFF2563EB),
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
                    const SizedBox(height: 24),

                    // Security & Metadata Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Authorized Personnel Only • v4.2.0',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Secured Campus Network • 256-bit TLS Encrypted',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
