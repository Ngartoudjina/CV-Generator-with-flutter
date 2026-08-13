import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/anim.dart';

/// Port de `ui/screens/AuthScreen.kt`.
const Color _aDark = Color(0xFF0D0920);
const Color _aDarkMid = Color(0xFF180C30);
const Color _aBg = Color(0xFFF1ECFB);
const Color _aInk = Color(0xFF1C1626);
const Color _aWhite = Color(0xFFEFEBFF);
const Color _aAccent = AppColors.accent;

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthSuccess,
    required this.onBack,
  });

  final VoidCallback onAuthSuccess;
  final VoidCallback onBack;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _pwVisible = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  static const _pwColors = [
    Colors.transparent,
    AppColors.errorRed,
    AppColors.warnOrange,
    AppColors.warnLime,
    AppColors.successGreen,
  ];
  static const _pwLabels = ['', 'Faible', 'Moyen', 'Bon', 'Fort'];

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Port fidèle du `remember(password) { when { … } }` de Compose.
  int get _pwStrength {
    final pw = _passwordCtrl.text;
    final hasDigit = pw.contains(RegExp(r'\d'));
    final hasUpper = pw.contains(RegExp('[A-ZÀ-Þ]'));
    if (pw.length >= 10 && hasDigit && hasUpper) return 4;
    if (pw.length >= 8 && (hasDigit || hasUpper)) return 3;
    if (pw.length >= 6) return 2;
    if (pw.isNotEmpty) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _pwStrength;

    return Scaffold(
      backgroundColor: _aBg,
      body: Stack(
        children: [
          // ── Couches de fond ────────────────────────────────
          const SizedBox(
            height: 320,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_aDark, _aDarkMid, Color(0x000D0920)],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 270),
            child: ColoredBox(color: _aBg, child: SizedBox.expand()),
          ),

          // ── Contenu défilable ──────────────────────────────
          SafeArea(
            bottom: false,
            child: StaggerBuilder(
              count: 8,
              startDelay: const Duration(milliseconds: 80),
              stepDelay: const Duration(milliseconds: 60),
              builder: (context, vis) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Bouton retour
                      EntranceItem(
                        visible: vis[0],
                        fromY: -18,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: PressScale(
                            pressedScale: 0.88,
                            onTap: widget.onBack,
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _aWhite.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _aWhite.withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Text(
                                '←',
                                style: TextStyle(fontSize: 18, color: _aWhite),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      EntranceItem(
                        visible: vis[1],
                        fromY: 24,
                        fromScale: 0.78,
                        child: Image.asset(
                          'assets/images/logo_icon.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 16),

                      EntranceItem(
                        visible: vis[2],
                        fromY: 18,
                        child: Column(
                          children: [
                            Text(
                              _isLogin ? 'Bon retour 👋' : 'Créer un compte',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _aWhite,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLogin
                                  ? 'Connectez-vous pour accéder à vos CVs.'
                                  : 'Rejoignez 12 000+ candidats.',
                              style: TextStyle(
                                fontSize: 14,
                                color: _aWhite.withValues(alpha: 0.58),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Bascule segmentée ──────────────────
                      EntranceItem(
                        visible: vis[3],
                        fromY: 18,
                        fromScale: 0.94,
                        child: _SegmentedToggle(
                          isLogin: _isLogin,
                          onChanged: (v) => setState(() => _isLogin = v),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Carte formulaire ───────────────────
                      EntranceItem(
                        visible: vis[4],
                        fromY: 44,
                        fromScale: 0.94,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _aInk.withValues(alpha: 0.07),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _aInk.withValues(alpha: 0.10),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                curve: kBouncy,
                                child: _isLogin
                                    ? const SizedBox(width: double.infinity)
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: _AuthField(
                                          label: 'Prénom & Nom',
                                          controller: _nameCtrl,
                                          icon: '👤',
                                          placeholder: 'Amina Diallo',
                                        ),
                                      ),
                              ),
                              _AuthField(
                                label: 'Adresse e-mail',
                                controller: _emailCtrl,
                                icon: '✉',
                                placeholder: 'vous@exemple.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),
                              _AuthField(
                                label: 'Mot de passe',
                                controller: _passwordCtrl,
                                icon: '🔑',
                                placeholder: '••••••••',
                                obscure: !_pwVisible,
                                onTogglePw: () =>
                                    setState(() => _pwVisible = !_pwVisible),
                                pwVisible: _pwVisible,
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: (!_isLogin && strength > 0)
                                    ? _PasswordStrength(
                                        strength: strength,
                                        colors: _pwColors,
                                        labels: _pwLabels,
                                      )
                                    : const SizedBox(width: double.infinity),
                              ),
                              if (_isLogin) ...[
                                const SizedBox(height: 14),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _aAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Bouton de validation ───────────────
                      EntranceItem(
                        visible: vis[5],
                        fromY: 20,
                        fromScale: 0.94,
                        child: PressScale(
                          pressedScale: 0.965,
                          onTap: widget.onAuthSuccess,
                          child: Container(
                            height: 54,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _isLogin
                                  ? 'Se connecter →'
                                  : 'Créer mon compte →',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      EntranceItem(
                        visible: vis[6],
                        fromY: 12,
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: _aInk.withValues(alpha: 0.11),
                              ),
                            ),
                            Text(
                              '  ou continuer avec  ',
                              style: TextStyle(
                                fontSize: 12,
                                color: _aInk.withValues(alpha: 0.38),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: _aInk.withValues(alpha: 0.11),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      EntranceItem(
                        visible: vis[6],
                        fromY: 16,
                        fromScale: 0.94,
                        child: Row(
                          children: [
                            Expanded(
                              child: _SocialBtn(
                                label: 'Google',
                                icon: 'G',
                                onTap: widget.onAuthSuccess,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: _SocialBtn(
                                label: 'LinkedIn',
                                icon: 'in',
                                onTap: widget.onAuthSuccess,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      EntranceItem(
                        visible: vis[7],
                        fromY: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? 'Pas encore de compte ? '
                                  : 'Déjà un compte ? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: _aInk.withValues(alpha: 0.52),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isLogin = !_isLogin),
                              child: Text(
                                _isLogin ? 'Inscription' : 'Connexion',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _aAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bascule Connexion / Inscription ──────────────────────────────────────────

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({required this.isLogin, required this.onChanged});

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final half = constraints.maxWidth / 2;
        return SizedBox(
          height: 46,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _aInk.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: kBouncy,
                left: isLogin ? 4 : half,
                top: 4,
                bottom: 4,
                width: half - 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (i, label) in ['Connexion', 'Inscription'].indexed)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i == 0),
                        child: Center(
                          child: AnimatedScale(
                            scale: (i == 0) == isLogin ? 1 : 0.95,
                            duration: const Duration(milliseconds: 260),
                            curve: kBouncy,
                            child: AnimatedOpacity(
                              opacity: (i == 0) == isLogin ? 1 : 0.45,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _aInk,
                                  fontWeight: (i == 0) == isLogin
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Champ de saisie ──────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.placeholder,
    this.keyboardType,
    this.obscure = false,
    this.onTogglePw,
    this.pwVisible = false,
  });

  final String label;
  final TextEditingController controller;
  final String icon;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onTogglePw;
  final bool pwVisible;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _aInk.withValues(alpha: 0.52),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: _aInk.withValues(alpha: 0.28)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: onTogglePw == null
                ? null
                : TextButton(
                    onPressed: onTogglePw,
                    child: Text(
                      pwVisible ? 'Cacher' : 'Voir',
                      style: const TextStyle(fontSize: 11, color: _aAccent),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Jauge de robustesse du mot de passe ──────────────────────────────────────

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({
    required this.strength,
    required this.colors,
    required this.labels,
  });

  final int strength;
  final List<Color> colors;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            for (var lvl = 1; lvl <= 4; lvl++) ...[
              Expanded(
                child: AnimatedScale(
                  scale: strength >= lvl ? 1 : 0.85,
                  duration: const Duration(milliseconds: 220),
                  curve: kBouncy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 4,
                    decoration: BoxDecoration(
                      color: strength >= lvl
                          ? colors[strength]
                          : _aInk.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              if (lvl < 4) const SizedBox(width: 4),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          labels[strength],
          style: TextStyle(fontSize: 11, color: colors[strength]),
        ),
      ],
    );
  }
}

// ── Boutons sociaux ──────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.95,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _aInk.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _aAccent,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _aInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
