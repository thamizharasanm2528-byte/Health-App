import 'package:flutter/material.dart';

import '../../../profile/data/profile_model.dart';

/// Dialog to update profile values.
class EditProfileDialog extends StatefulWidget {
  final ProfileModel profile;
  final Function({
    required String name,
    required int age,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    DateTime? dateOfBirth,
  }) onSave;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late String _activityLevel;
  DateTime? _dateOfBirth;
  late int _age;

  final List<String> _activities = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _dateOfBirth = widget.profile.dateOfBirth;
    _age = widget.profile.age;
    _activityLevel = widget.profile.activityLevel;
    if (!_activities.contains(_activityLevel)) {
      _activityLevel = _activities[2];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select birth date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _dateOfBirth ?? DateTime(now.year - _age, now.month, now.day);
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 1);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected != null) {
      int calculatedAge = now.year - selected.year;
      if (now.month < selected.month || (now.month == selected.month && now.day < selected.day)) {
        calculatedAge--;
      }
      setState(() {
        _dateOfBirth = selected;
        _age = calculatedAge;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 18),
              
              // Date of Birth Selection Button
              const Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatDate(_dateOfBirth),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '$_age Yrs',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _activityLevel,
                decoration: const InputDecoration(labelText: 'Activity Level'),
                items: _activities
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _activityLevel = val);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.onSave(
                name: _nameCtrl.text.trim(),
                age: _age,
                heightCm: widget.profile.heightCm,
                weightKg: widget.profile.weightKg,
                activityLevel: _activityLevel,
                dateOfBirth: _dateOfBirth,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Dialog to log a weight change.
class UpdateWeightDialog extends StatefulWidget {
  final double currentWeight;
  final Function(double) onSave;

  const UpdateWeightDialog({
    super.key,
    required this.currentWeight,
    required this.onSave,
  });

  @override
  State<UpdateWeightDialog> createState() => _UpdateWeightDialogState();
}

class _UpdateWeightDialogState extends State<UpdateWeightDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.currentWeight.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Weight'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          decoration: const InputDecoration(
            labelText: 'New Weight (kg)',
            suffixText: 'kg',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (val) {
            final w = double.tryParse(val ?? '');
            if (w == null || w < 20 || w > 300) {
              return 'Enter valid weight (20-300)';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.onSave(double.parse(_ctrl.text));
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
