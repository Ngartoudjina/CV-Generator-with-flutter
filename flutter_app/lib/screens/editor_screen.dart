import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/anim.dart';
import '../widgets/score_ring.dart';

/// Port de `ui/screens/EditorScreen.kt`.
const Color _eBg = Color(0xFFF1ECFB);
const Color _eInk = Color(0xFF1C1626);
const Color _eCard = Color(0xFFFFFFFF);
const Color _eAccent = AppColors.accent;
const Color _eDark = Color(0xFF0D0920);
const Color _eDarkMid = Color(0xFF180C30);
const Color _eWhite = Color(0xFFEFEBFF);

enum AiState { idle, thinking, done }

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    this.cvId = 1,
    required this.onBack,
    required this.onExport,
  });

  final int cvId;
  final VoidCallback onBack;
  final VoidCallback onExport;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  static const _sections = ['Profil', 'Expérience', 'Compétences', 'Formation'];
  static const _suggestions = [
    'React Native',
    'Flutter',
    'iOS',
    'CI/CD',
    'Figma',
  ];

  bool _isPreview = false;
  String _expandedSection = 'Profil';
  AiState _aiState = AiState.idle;
  bool _showSuggestions = false;
  bool _exportVisible = false;

  List<String> _skills = ['Kotlin', 'Android', 'Jetpack Compose', 'Firebase'];

  final _nameCtrl = TextEditingController(text: 'Amina Diallo');
  final _titleCtrl = TextEditingController(text: 'Développeuse Full-Stack');
  final _summaryCtrl = TextEditingController(
    text: "Développeuse passionnée avec 5 ans d'expérience dans la création "
        "d'applications mobiles et web à fort impact.",
  );

  Timer? _exportTimer;
  Timer? _aiTimer;

  @override
  void initState() {
    super.initState();
    _exportTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _exportVisible = true);
    });
    for (final c in [_nameCtrl, _titleCtrl, _summaryCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _exportTimer?.cancel();
    _aiTimer?.cancel();
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  /// Le Compose d'origine passait de IDLE à THINKING sans jamais retomber ;
  /// on garde la même intention en enchaînant THINKING → DONE → IDLE.
  void _runAi() {
    if (_aiState != AiState.idle) return;
    setState(() => _aiState = AiState.thinking);
    _aiTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _aiState = AiState.done);
      _aiTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _aiState = AiState.idle);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _eBg,
      body: StaggerBuilder(
        count: 3,
        startDelay: const Duration(milliseconds: 60),
        stepDelay: const Duration(milliseconds: 80),
        builder: (context, vis) {
          return Stack(
            children: [
              Column(
                children: [
                  // ── En-tête sombre ─────────────────────────
                  EntranceItem(
                    visible: vis[0],
                    fromY: -20,
                    child: _DarkHeader(
                      headerVisible: vis[1],
                      isPreview: _isPreview,
                      onBack: widget.onBack,
                      onModeChange: (p) => setState(() => _isPreview = p),
                    ),
                  ),

                  // ── Contenu ────────────────────────────────
                  Expanded(
                    child: EntranceItem(
                      visible: vis[2],
                      fromY: 20,
                      child: _isPreview
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: _PreviewPanel(
                                name: _nameCtrl.text,
                                title: _titleCtrl.text,
                                summary: _summaryCtrl.text,
                                skills: _skills,
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                children: [
                                  for (final section in _sections) ...[
                                    _AccordionSection(
                                      title: section,
                                      expanded: section == _expandedSection,
                                      onToggle: () => setState(() {
                                        _expandedSection =
                                            _expandedSection == section
                                                ? ''
                                                : section;
                                      }),
                                      child: _sectionBody(section),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  const SizedBox(height: 90),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              // ── Barre d'export ───────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 480),
                curve: kBouncy,
                left: 0,
                right: 0,
                bottom: _exportVisible ? 0 : -100,
                child: _ExportBar(onExport: widget.onExport),
              ),

              // ── Toast « IA terminée » ────────────────────
              if (_aiState == AiState.done)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 140,
                      left: 24,
                      right: 24,
                    ),
                    child: const _AiDoneToast(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionBody(String section) {
    return switch (section) {
      'Profil' => _ProfilContent(
          nameCtrl: _nameCtrl,
          titleCtrl: _titleCtrl,
          summaryCtrl: _summaryCtrl,
          aiState: _aiState,
          onAiReform: _runAi,
        ),
      'Compétences' => _SkillsContent(
          skills: _skills,
          suggestions: _suggestions,
          showSuggestions: _showSuggestions,
          onToggle: () =>
              setState(() => _showSuggestions = !_showSuggestions),
          onRemove: (s) => setState(() {
            _skills = _skills.where((x) => x != s).toList();
          }),
          onAdd: (s) => setState(() {
            if (!_skills.contains(s)) _skills = [..._skills, s];
          }),
        ),
      'Expérience' => const _ExperienceEditorContent(),
      'Formation' => const _FormationEditorContent(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── En-tête sombre + bascule Éditer / Aperçu ─────────────────────────────────

class _DarkHeader extends StatelessWidget {
  const _DarkHeader({
    required this.headerVisible,
    required this.isPreview,
    required this.onBack,
    required this.onModeChange,
  });

  final bool headerVisible;
  final bool isPreview;
  final VoidCallback onBack;
  final ValueChanged<bool> onModeChange;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_eDark, _eDarkMid, Color(0x000D0920)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPad + 12, bottom: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  PressScale(
                    pressedScale: 0.86,
                    onTap: onBack,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _eWhite.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _eWhite.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Text(
                        '←',
                        style: TextStyle(fontSize: 18, color: _eWhite),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo_icon.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'CV Senior Dev',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _eWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ScoreRingSmall(score: 92, size: 40),
                ],
              ),
            ),
            EntranceItem(
              visible: headerVisible,
              fromY: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _eWhite.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _eWhite.withValues(alpha: 0.15),
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (label, isP) in [
                          ('Éditer', false),
                          ('Aperçu', true),
                        ])
                          GestureDetector(
                            onTap: () => onModeChange(isP),
                            child: AnimatedScale(
                              scale: isP == isPreview ? 1 : 0.96,
                              duration: const Duration(milliseconds: 260),
                              curve: kBouncy,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isP == isPreview
                                      ? AppColors.accentGradient
                                      : null,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isP == isPreview
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isP == isPreview
                                        ? Colors.white
                                        : _eWhite.withValues(alpha: 0.45),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section accordéon ────────────────────────────────────────────────────────

class _AccordionSection extends StatelessWidget {
  const _AccordionSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _eCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _eInk.withValues(alpha: expanded ? 0.10 : 0.05),
            blurRadius: expanded ? 12 : 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _eInk,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 280),
                    curve: kBouncy,
                    child: Text(
                      '▼',
                      style: TextStyle(
                        fontSize: 11,
                        color: _eInk.withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: kBouncy,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        color: _eInk.withValues(alpha: 0.07),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: child,
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ── Contenu « Profil » avec bouton IA ────────────────────────────────────────

class _ProfilContent extends StatelessWidget {
  const _ProfilContent({
    required this.nameCtrl,
    required this.titleCtrl,
    required this.summaryCtrl,
    required this.aiState,
    required this.onAiReform,
  });

  final TextEditingController nameCtrl;
  final TextEditingController titleCtrl;
  final TextEditingController summaryCtrl;
  final AiState aiState;
  final VoidCallback onAiReform;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditorField(label: 'Nom complet', controller: nameCtrl),
        const SizedBox(height: 13),
        EditorField(label: 'Titre professionnel', controller: titleCtrl),
        const SizedBox(height: 13),
        EditorField(label: 'Résumé', controller: summaryCtrl, maxLines: 5),
        const SizedBox(height: 13),
        _AiButton(state: aiState, onTap: onAiReform),
      ],
    );
  }
}

class _AiButton extends StatelessWidget {
  const _AiButton({required this.state, required this.onTap});

  final AiState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.97,
      enabled: state == AiState.idle,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 46,
        decoration: BoxDecoration(
          color: state == AiState.done ? AppColors.successGreen : _eAccent,
          borderRadius: BorderRadius.circular(13),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (state == AiState.thinking)
              const Positioned.fill(child: ShimmerOverlay()),
            switch (state) {
              AiState.idle => const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✦', style: TextStyle(fontSize: 14, color: Colors.white)),
                    SizedBox(width: 8),
                    Text(
                      "Reformuler avec l'IA",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              AiState.thinking => const _ThinkingDots(),
              AiState.done => const Text(
                  '✓  Reformulé !',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
            },
          ],
        ),
      ),
    );
  }
}

/// Trois points pulsés en décalage — port des `dot1/dot2/dot3` de Compose.
class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        double dot(int i) {
          final shifted = (_c.value + i * 0.17) % 1.0;
          final v = shifted < 0.5 ? shifted * 2 : (1 - shifted) * 2;
          return 0.3 + v * 0.7;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '✦  Analyse',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(width: 8),
            for (var i = 0; i < 3; i++)
              Opacity(
                opacity: dot(i),
                child: const Text(
                  '•',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Contenu « Compétences » ──────────────────────────────────────────────────

class _SkillsContent extends StatelessWidget {
  const _SkillsContent({
    required this.skills,
    required this.suggestions,
    required this.showSuggestions,
    required this.onToggle,
    required this.onRemove,
    required this.onAdd,
  });

  final List<String> skills;
  final List<String> suggestions;
  final bool showSuggestions;
  final VoidCallback onToggle;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final remaining = suggestions.where((s) => !skills.contains(s)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // `FlowRow` de Compose → `Wrap` en Flutter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in skills)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _eAccent.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _eAccent.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _eAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => onRemove(skill),
                      child: Text(
                        '×',
                        style: TextStyle(
                          fontSize: 13,
                          color: _eAccent.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onToggle,
          child: Text(
            '✦  ${showSuggestions ? "Masquer" : "Suggestions IA"}',
            style: const TextStyle(
              fontSize: 13,
              color: _eAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: showSuggestions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Suggestions IA',
                      style: TextStyle(
                        fontSize: 11,
                        color: _eInk.withValues(alpha: 0.48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in remaining)
                          PressScale(
                            pressedScale: 0.92,
                            onTap: () => onAdd(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _eBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _eInk.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _eAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _eInk.withValues(alpha: 0.68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ── Éditeurs Expérience & Formation (contenus de démonstration) ──────────────

class _ExperienceEditorContent extends StatelessWidget {
  const _ExperienceEditorContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        EditorField(label: 'Poste', initialText: 'Développeuse Full-Stack'),
        SizedBox(height: 12),
        EditorField(label: 'Entreprise', initialText: 'TechCorp SAS'),
        SizedBox(height: 12),
        EditorField(label: 'Période', initialText: '2021 – Présent'),
        SizedBox(height: 12),
        EditorField(
          label: 'Description',
          maxLines: 4,
          initialText:
              "Développement d'applications mobiles Android avec Kotlin et "
              'Jetpack Compose. Amélioration des performances de 40 %.',
        ),
      ],
    );
  }
}

class _FormationEditorContent extends StatelessWidget {
  const _FormationEditorContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        EditorField(label: 'Diplôme', initialText: 'Master Informatique'),
        SizedBox(height: 12),
        EditorField(
          label: 'Établissement',
          initialText: 'Université Paris-Saclay',
        ),
        SizedBox(height: 12),
        EditorField(label: 'Année', initialText: '2019'),
      ],
    );
  }
}

/// Champ de saisie de l'éditeur — accepte soit un [controller] piloté par le
/// parent, soit un simple [initialText] pour les blocs de démonstration.
class EditorField extends StatefulWidget {
  const EditorField({
    super.key,
    required this.label,
    this.controller,
    this.initialText,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialText;
  final int maxLines;

  @override
  State<EditorField> createState() => _EditorFieldState();
}

class _EditorFieldState extends State<EditorField> {
  TextEditingController? _own;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _own = TextEditingController(text: widget.initialText ?? '');
    }
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller ?? _own,
      maxLines: widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : 1,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontSize: 12),
        fillColor: _eBg.withValues(alpha: 0.50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _eInk.withValues(alpha: 0.11)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _eInk.withValues(alpha: 0.11)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _eAccent, width: 1.6),
        ),
      ),
    );
  }
}

// ── Barre d'export ───────────────────────────────────────────────────────────

class _ExportBar extends StatelessWidget {
  const _ExportBar({required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_eDarkMid, _eDark],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: 14 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Score ATS',
                      style: TextStyle(
                        fontSize: 11,
                        color: _eWhite.withValues(alpha: 0.50),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const GradientText(
                          '92',
                          gradient: AppColors.accentCoGradient,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 12,
                              color: _eWhite.withValues(alpha: 0.38),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PressScale(
                pressedScale: 0.96,
                onTap: onExport,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Exporter PDF ↑',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Toast « IA terminée » ────────────────────────────────────────────────────

class _AiDoneToast extends StatelessWidget {
  const _AiDoneToast();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: kBouncy,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, -40 * (1 - t)), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_eDark, _eAccent.withValues(alpha: 0.75)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _eAccent.withValues(alpha: 0.40)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentCoGradient,
              ),
              child: const Text(
                '✦',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reformulation prête !',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _eWhite,
                    ),
                  ),
                  Text(
                    "L'IA a optimisé votre expérience pour les ATS.",
                    style: TextStyle(
                      fontSize: 12,
                      color: _eWhite.withValues(alpha: 0.72),
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

// ── Panneau d'aperçu ─────────────────────────────────────────────────────────

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.name,
    required this.title,
    required this.summary,
    required this.skills,
  });

  final String name;
  final String title;
  final String summary;
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _eCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _eInk.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _eInk,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: _eAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'amina@example.com  •  Paris, France',
            style: TextStyle(
              fontSize: 11,
              color: _eInk.withValues(alpha: 0.42),
            ),
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1.5,
            thickness: 1.5,
            color: _eAccent.withValues(alpha: 0.28),
          ),
          const SizedBox(height: 14),

          const _SectionHeader('Profil'),
          const SizedBox(height: 6),
          Text(
            summary,
            style: TextStyle(
              fontSize: 11.5,
              color: _eInk.withValues(alpha: 0.78),
              height: 1.48,
            ),
          ),
          const SizedBox(height: 16),

          const _SectionHeader('Expérience'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Développeuse Full-Stack',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _eInk,
                    ),
                  ),
                  Text(
                    'TechCorp SAS',
                    style: TextStyle(
                      fontSize: 11,
                      color: _eInk.withValues(alpha: 0.52),
                    ),
                  ),
                ],
              ),
              Text(
                '2021 – Présent',
                style: TextStyle(
                  fontSize: 10,
                  color: _eInk.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Développement mobile Android avec Kotlin et Jetpack Compose. '
            'Amélioration des performances de 40 %.',
            style: TextStyle(
              fontSize: 11,
              color: _eInk.withValues(alpha: 0.68),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          const _SectionHeader('Compétences'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in skills)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _eAccent.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _eAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          const _SectionHeader('Formation'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Master Informatique',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _eInk,
                    ),
                  ),
                  Text(
                    'Université Paris-Saclay',
                    style: TextStyle(
                      fontSize: 11,
                      color: _eInk.withValues(alpha: 0.52),
                    ),
                  ),
                ],
              ),
              Text(
                '2019',
                style: TextStyle(
                  fontSize: 10,
                  color: _eInk.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _eAccent,
        letterSpacing: 0.5,
      ),
    );
  }
}
