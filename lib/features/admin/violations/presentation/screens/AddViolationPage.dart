import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:baladiyati/features/admin/violations/presentation/widgets/violation_category_dropdown.dart';
import 'package:baladiyati/features/admin/violations/presentation/widgets/violation_date_picker.dart';
import 'package:baladiyati/features/admin/violations/presentation/widgets/violation_submit_button.dart';
import 'package:baladiyati/features/admin/violations/presentation/widgets/violation_text_field.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateViolationScreen extends StatefulWidget {
  const CreateViolationScreen({super.key});

  @override
  State<CreateViolationScreen> createState() => _CreateViolationScreenState();
}

class _CreateViolationScreenState extends State<CreateViolationScreen> {
  final nameController = TextEditingController();
  final citizenNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final amountController = TextEditingController();

  DateTime? selectedDate;
  String? selectedCategory;

  void _submit() {
    if (selectedDate == null) return;

    final violation = Violation(
      title: nameController.text,
      description: descriptionController.text,
      citizenName: citizenNameController.text,
      amount: double.tryParse(amountController.text) ?? 0,
      departmentId: 1,
      location: locationController.text,
      violationDate: selectedDate!.toIso8601String().split("T")[0],
    );

    context.read<ViolationBloc>().add(CreateViolationEvent(violation));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<ViolationBloc, ViolationState>(
      listener: (context, state) {
        /// ❌ error
        if (state is ViolationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        /// ✅ نجاح الإضافة الحقيقي
        if (state is ViolationCreated) {
          Navigator.pop(context);
        }
      },

      child: Scaffold(
        appBar: AppBar(title: Text(loc.createViolation)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              ViolationTextField(
                label: loc.name,
                hint: loc.enterName,
                controller: nameController,
              ),

              ViolationTextField(
                label: loc.citizenName,
                hint: loc.enterCitizenName,
                controller: citizenNameController,
              ),

              ViolationTextField(
                label: loc.description,
                hint: loc.enterDescription,
                controller: descriptionController,
              ),

              ViolationTextField(
                label: loc.location,
                hint: loc.enterLocation,
                controller: locationController,
              ),

              const SizedBox(height: 12),

              ViolationDatePicker(
                selectedDate: selectedDate,
                selectText: loc.selectDate,
                onDatePicked: (date) {
                  setState(() => selectedDate = date);
                },
              ),

              const SizedBox(height: 12),

              ViolationCategoryDropdown(
                value: selectedCategory,
                hint: loc.selectCategory,
                onChanged: (v) => setState(() => selectedCategory = v),
              ),

              ViolationTextField(
                label: loc.amount,
                hint: loc.enterAmount,
                controller: amountController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ViolationSubmitButton(
                text: loc.create,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}