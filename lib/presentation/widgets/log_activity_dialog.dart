import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/activity_entity.dart';

class ExerciseOption {
  final String name;
  final String icon;
  final int calPerMinute;

  const ExerciseOption(this.name, this.icon, this.calPerMinute);
}

class LogActivityDialog extends StatefulWidget {
  const LogActivityDialog({super.key});

  static Future<ActivityEntity?> show(BuildContext context) {
    return showModalBottomSheet<ActivityEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogActivityDialog(),
    );
  }

  @override
  State<LogActivityDialog> createState() => _LogActivityDialogState();
}

class _LogActivityDialogState extends State<LogActivityDialog> {
  final _formKey = GlobalKey<FormState>();

  final List<ExerciseOption> _options = const [
    ExerciseOption('Running', '🏃', 10),
    ExerciseOption('Cycling', '🚴', 8),
    ExerciseOption('Gym / Strength', '🏋️', 7),
    ExerciseOption('Swimming', '🏊', 9),
    ExerciseOption('Walking', '🚶', 5),
    ExerciseOption('Yoga', '🧘', 4),
    ExerciseOption('HIIT', '⚡', 12),
  ];

  late ExerciseOption _selectedOption;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _distanceController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedOption = _options.first;
    _durationController = TextEditingController(text: '30');
    _caloriesController = TextEditingController(
      text: '${30 * _selectedOption.calPerMinute}',
    );
    _distanceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onOptionSelected(ExerciseOption option) {
    setState(() {
      _selectedOption = option;
      _recalculateCalories();
    });
  }

  void _recalculateCalories() {
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    _caloriesController.text = (duration * _selectedOption.calPerMinute).toString();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final duration = int.parse(_durationController.text.trim());
    final calories = int.parse(_caloriesController.text.trim());
    final distance = double.tryParse(_distanceController.text.trim());
    final notes = _notesController.text.trim();

    final activity = ActivityEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedOption.name,
      icon: _selectedOption.icon,
      durationMinutes: duration,
      caloriesBurned: calories,
      distanceKm: distance,
      notes: notes.isEmpty ? '${_selectedOption.name} workout' : notes,
      timestamp: DateTime.now(),
    );

    Navigator.of(context).pop(activity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111622) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: isDark ? const Color(0xFF222B40) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.fitnessGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Log Fitness Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Exercise Type Selector
                const Text(
                  'EXERCISE TYPE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.emerald,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _options.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final opt = _options[index];
                      final isSelected = opt.name == _selectedOption.name;

                      return GestureDetector(
                        onTap: () => _onOptionSelected(opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.fitnessGradient : null,
                            color: isSelected
                                ? null
                                : (isDark ? const Color(0xFF192132) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? const Color(0xFF26324D) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(opt.icon, style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 3),
                              Text(
                                opt.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Duration & Calories in 2 columns
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DURATION (MINUTES)',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppTheme.electricCyan,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _recalculateCalories(),
                            validator: (v) {
                              if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) {
                                return 'Enter minutes';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: '30',
                              prefixIcon: Icon(Icons.timer_outlined, size: 19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CALORIES (KCAL)',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppTheme.calorieOrange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _caloriesController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) {
                                return 'Enter kcal';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: '300',
                              prefixIcon: Icon(Icons.local_fire_department_outlined, size: 19),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Distance (Optional)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISTANCE (KM - OPTIONAL)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 5.4',
                        prefixIcon: Icon(Icons.route_outlined, size: 19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOTES / DESCRIPTION',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Morning interval sprint',
                        prefixIcon: Icon(Icons.edit_note_rounded, size: 21),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.fitnessGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emerald.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Log Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
