// lib/features/health_profile/presentation/health_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

class HealthInputScreen extends ConsumerStatefulWidget {
  const HealthInputScreen({super.key});

  @override
  ConsumerState<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends ConsumerState<HealthInputScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // ── Page 1 필드 ───────────────────────────────────
  final _ageCtrl            = TextEditingController();
  final _heightCtrl         = TextEditingController();
  final _weightCtrl         = TextEditingController();
  final _fastingGlucoseCtrl = TextEditingController();
  final _postprandialCtrl   = TextEditingController();
  final _hba1cCtrl          = TextEditingController();
  final _systolicCtrl       = TextEditingController();
  final _diastolicCtrl      = TextEditingController();
  String _gender = '남';

  // ── Page 2 필드 ───────────────────────────────────
  int _smoking = 0;          // 0: 비흡연, 1: 과거, 2: 현재
  int _exercisePerWeek = 0;  // 0~7회 (스피너)
  bool _familyHistory = false;

  double get _bmi {
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    if (h <= 0) return 0;
    return w / ((h / 100) * (h / 100));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _fastingGlucoseCtrl.dispose();
    _postprandialCtrl.dispose();
    _hba1cCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        )
            : null,
        title: Text('건강 정보 입력 ${_currentPage + 1} / 2'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${_currentPage + 1} / 2',
              style: const TextStyle(
                fontSize: 12, color: AppColors.accent,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 2,
            backgroundColor: AppColors.bgSecondary,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 3,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [_buildPage1(), _buildPage2()],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // Page 1: 신체 정보 + 혈당/혈압
  // ══════════════════════════════════════════════════
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('기본 신체 정보'),
          const SizedBox(height: 12),

          // 나이 / 성별
          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _ageCtrl,
                  label: '나이',
                  suffix: '세',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('성별'),
                  const SizedBox(height: 6),
                  _GenderToggle(
                    selected: _gender,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 키 / 몸무게
          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _heightCtrl,
                  label: '키',
                  suffix: 'cm',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _inputField(
                  controller: _weightCtrl,
                  label: '몸무게',
                  suffix: 'kg',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // BMI 자동계산
          _BmiCard(bmi: _bmi),
          const SizedBox(height: 20),

          _sectionTitle('혈당 수치'),
          const SizedBox(height: 12),

          // 공복혈당
          _inputField(
            controller: _fastingGlucoseCtrl,
            label: '공복혈당',
            suffix: 'mg/dL',
            hint: '정상 < 100',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),

          // 식후 2시간 혈당
          _inputField(
            controller: _postprandialCtrl,
            label: '식후 2시간 혈당',
            suffix: 'mg/dL',
            hint: '정상 < 140',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),

          // HbA1c
          _inputField(
            controller: _hba1cCtrl,
            label: '당화혈색소 (HbA1c)',
            suffix: '%',
            hint: '정상 < 5.7',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          _sectionTitle('혈압'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _systolicCtrl,
                  label: '수축기',
                  suffix: 'mmHg',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _inputField(
                  controller: _diastolicCtrl,
                  label: '이완기',
                  suffix: 'mmHg',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 다음 버튼
          _PrimaryButton(
            label: '다음 →',
            onTap: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // Page 2: 생활습관
  // ══════════════════════════════════════════════════
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('생활습관'),
          const SizedBox(height: 16),

          // 흡연 여부
          _fieldLabel('흡연 여부'),
          const SizedBox(height: 8),
          _SmokingToggle(
            selected: _smoking,
            onChanged: (v) => setState(() => _smoking = v),
          ),
          const SizedBox(height: 20),

          // ── 주간 운동 횟수 스피너 ─────────────────
          _fieldLabel('주간 운동 횟수'),
          const SizedBox(height: 8),
          _ExerciseSpinner(
            value: _exercisePerWeek,
            onChanged: (v) => setState(() => _exercisePerWeek = v),
          ),
          const SizedBox(height: 20),

          // 당뇨 가족력
          _fieldLabel('당뇨 가족력'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgTertiary, width: 0.5),
            ),
            child: Row(
              children: [
                const Text('가족 중 당뇨 환자가 있나요?',
                    style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary,
                    )),
                const Spacer(),
                Switch.adaptive(
                  value: _familyHistory,
                  onChanged: (v) => setState(() => _familyHistory = v),
                  activeColor: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 분석 완료 버튼
          _PrimaryButton(
            label: '위험군 분석하기 →',
            onTap: _submitProfile,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _submitProfile() {
    // TODO: ref.read(healthProfileProvider.notifier).submit(...)
    // API 호출 후 위험군 결과 화면으로 이동
  }

  // ── 공통 위젯 헬퍼 ──────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          letterSpacing: 0.5,
        ));
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: const TextStyle(
          fontSize: 11, color: AppColors.textSecondary,
        ));
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    String? hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 성별 토글 ──────────────────────────────────────────────
class _GenderToggle extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _GenderToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: ['남', '여'].map((g) {
          final sel = selected == g;
          return GestureDetector(
            onTap: () => onChanged(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40, height: 36,
              decoration: BoxDecoration(
                color: sel ? AppColors.bgSecondary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: sel
                    ? Border.all(color: AppColors.bgTertiary, width: 0.5)
                    : null,
              ),
              child: Center(
                child: Text(g,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel ? AppColors.accent : AppColors.textSecondary,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── 흡연 토글 ──────────────────────────────────────────────
class _SmokingToggle extends StatelessWidget {
  final int selected;
  final void Function(int) onChanged;
  const _SmokingToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['비흡연', '과거흡연', '현재흡연'];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(labels.length, (i) {
          final sel = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                decoration: BoxDecoration(
                  color: sel ? AppColors.bgSecondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: sel
                      ? Border.all(color: AppColors.bgTertiary, width: 0.5)
                      : null,
                ),
                child: Center(
                  child: Text(labels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? AppColors.accent : AppColors.textSecondary,
                      )),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── 운동 횟수 스피너 (확정) ────────────────────────────────
class _ExerciseSpinner extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  const _ExerciseSpinner({required this.value, required this.onChanged});

  String get _hint {
    if (value == 0) return '운동 부족 — 혈당 관리에 악영향';
    if (value <= 2) return '권장량 미달 — 조금 더 늘려보세요';
    return '권장 운동량 충족 (주 3회 이상)';
  }

  Color get _hintColor {
    if (value == 0) return AppColors.riskHigh;
    if (value <= 2) return AppColors.riskMedium;
    return AppColors.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 스피너
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bgTertiary, width: 0.5),
          ),
          child: Row(
            children: [
              // − 버튼
              _SpinBtn(
                icon: Icons.remove,
                enabled: value > 0,
                onTap: () => onChanged(value - 1),
              ),
              Container(
                  width: 0.5, height: 48, color: AppColors.bgTertiary),
              // 숫자 표시
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$value',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const Text('회 / 주',
                        style: TextStyle(
                          fontSize: 10, color: AppColors.textTertiary,
                        )),
                  ],
                ),
              ),
              Container(
                  width: 0.5, height: 48, color: AppColors.bgTertiary),
              // + 버튼
              _SpinBtn(
                icon: Icons.add,
                enabled: value < 7,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 7칸 진행 바
        Row(
          children: List.generate(7, (i) {
            final filled = i < value;
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: filled
                      ? (value >= 3 ? AppColors.riskLow : AppColors.riskMedium)
                      : AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),

        // 상태 안내
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.bgTertiary, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                  color: _hintColor, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(_hint,
                  style: TextStyle(fontSize: 10, color: _hintColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpinBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _SpinBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52, height: 52,
        color: Colors.transparent,
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.textSecondary : AppColors.bgTertiary,
        ),
      ),
    );
  }
}

// ── BMI 카드 ───────────────────────────────────────────────
class _BmiCard extends StatelessWidget {
  final double bmi;
  const _BmiCard({required this.bmi});

  String get _label {
    if (bmi <= 0) return '-';
    if (bmi < 18.5) return '저체중';
    if (bmi < 23.0) return '정상';
    if (bmi < 25.0) return '과체중';
    return '비만';
  }

  Color get _color {
    if (bmi <= 0) return AppColors.textTertiary;
    if (bmi < 18.5) return AppColors.accent;
    if (bmi < 23.0) return AppColors.riskLow;
    if (bmi < 25.0) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Row(
        children: [
          const Text('BMI (자동계산)',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            bmi > 0 ? bmi.toStringAsFixed(1) : '-',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
          const SizedBox(width: 8),
          Text(_label,
              style: TextStyle(fontSize: 11, color: _color)),
        ],
      ),
    );
  }
}

// ── 주요 버튼 ──────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}