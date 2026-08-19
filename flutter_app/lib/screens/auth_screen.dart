import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Connexion — `maquettes/03_connexion.jpg`.
///
/// Le portage empilait un dégradé sombre, un logo, une bascule segmentée
/// Connexion/Inscription, une carte en verre, une jauge de robustesse de mot
/// de passe et deux boutons sociaux. La maquette retire tout cela : deux
/// champs soulignés, un bouton, deux fournisseurs, un lien.
///
/// L'écran ne vérifie toujours rien — il n'y a pas de backend. C'est dit dans
/// l'onglet Profil plutôt que masqué derrière une interface qui promettrait un
/// compte.
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paper.bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Pen.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.xl,
                  Space.xxl,
                  Space.xl,
                  Space.xl,
                ),
                children: [
                  const Text('CV GENERATOR', style: Mono.overline),
                  const SizedBox(height: Space.md),
                  Text(
                    'Reprendre où vous\nen étiez.',
                    style: Serif.title.copyWith(fontSize: 27),
                  ),
                  const SizedBox(height: Space.md),
                  const Text(
                    'Vos CV, vos modèles et vos réécritures vous attendent.',
                    style: Sans.body,
                  ),
                  const SizedBox(height: Space.xxxl),
                  _Field(
                    label: 'ADRESSE E-MAIL',
                    controller: _email,
                    placeholder: 'amina.diallo@mail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: Space.xl),
                  _Field(
                    label: 'MOT DE PASSE',
                    controller: _password,
                    placeholder: '••••••••',
                    obscure: !_visible,
                    // Le libellé bascule : la maquette montre « AFFICHER »
                    // sur un mot de passe masqué.
                    action: _visible ? 'MASQUER' : 'AFFICHER',
                    onAction: () => setState(() => _visible = !_visible),
                  ),
                  const SizedBox(height: Space.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Mot de passe oublié ?',
                      style: Sans.body.copyWith(
                        fontSize: 14,
                        color: Accent.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.md),
                      boxShadow: Shadow.floating,
                    ),
                    child: FilledButton(
                      onPressed: widget.onAuthSuccess,
                      child: const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  const _OrDivider(),
                  const SizedBox(height: Space.lg),
                  _ProviderButton(
                    label: 'Continuer avec Apple',
                    icon: const Icon(Icons.apple, size: 22, color: Pen.primary),
                    onTap: widget.onAuthSuccess,
                  ),
                  const SizedBox(height: Space.md),
                  _ProviderButton(
                    label: 'Continuer avec Google',
                    // Le logo Google est une marque déposée : sans le fichier
                    // officiel, on pose son initiale dans son bleu plutôt que
                    // d'en dessiner une approximation.
                    icon: Text(
                      'G',
                      style: Sans.button.copyWith(
                        fontSize: 20,
                        color: const Color(0xFF4285F4),
                      ),
                    ),
                    onTap: widget.onAuthSuccess,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore de compte ? ',
                    style: Sans.body.copyWith(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: widget.onAuthSuccess,
                    child: Text(
                      'Créer un compte',
                      style: Sans.button.copyWith(
                        fontSize: 14,
                        color: Accent.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Champ souligné, sans cadre ni fond. Le filet passe au rouge dès que le
/// champ prend le focus — c'est la seule signalétique d'état de l'écran.
class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.obscure = false,
    this.keyboardType,
    this.action,
    this.onAction,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? action;
  final VoidCallback? onAction;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _focus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.label, style: Mono.overline)),
            if (widget.action != null)
              GestureDetector(
                onTap: widget.onAction,
                behavior: HitTestBehavior.opaque,
                child: Text(widget.action!, style: Mono.overlineAccent),
              ),
          ],
        ),
        const SizedBox(height: Space.xs),
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          style: Sans.body.copyWith(
            fontSize: 18,
            color: Pen.primary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: Space.sm),
            hintText: widget.placeholder,
            hintStyle: Sans.body.copyWith(fontSize: 18, color: Pen.faint),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: active ? Accent.red : Paper.ruleStrong,
                width: active ? 1.5 : 1,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Paper.ruleStrong),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Accent.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Paper.rule, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Space.lg),
          child: Text('OU', style: Mono.overline),
        ),
        Expanded(child: Divider(color: Paper.rule, height: 1)),
      ],
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Paper.sheet,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: Paper.ruleStrong),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: Space.md),
            Text(
              label,
              style: Sans.button.copyWith(fontSize: 16, color: Pen.primary),
            ),
          ],
        ),
      ),
    );
  }
}
