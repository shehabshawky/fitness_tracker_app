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
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Log Fitness Activity',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'EXERCISE TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.classicNavy,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _options.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final opt = _options[index];
                      final isSelected = opt.name == _selectedOption.name;

                      return ChoiceChip(
                        label: Text('${opt.icon} ${opt.name}'),
                        selected: isSelected,
                        onSelected: (_) => _onOptionSelected(opt),
                        selectedColor: isDark ? const Color(0xFF2563EB) : AppTheme.classicNavy,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DURATION (MINUTES)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
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
                              prefixIcon: Icon(Icons.timer_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CALORIES (KCAL)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
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
                              prefixIcon: Icon(Icons.local_fire_department_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DISTANCE (KM - OPTIONAL)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 5.0',
                        prefixIcon: Icon(Icons.straighten_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOTES',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Morning outdoor session',
                        prefixIcon: Icon(Icons.note_alt_outlined, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2563EB) : AppTheme.classicNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Workout',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
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
