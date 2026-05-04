import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:baladiyati/features/admin/violations/presentation/widgets/violation_date_picker.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateViolationScreen extends StatefulWidget {
  final Violation? violation;

  const CreateViolationScreen({
    super.key,
    this.violation,
  });

  bool get isEdit => violation != null;

  @override
  State<CreateViolationScreen> createState() => _CreateViolationScreenState();
}

class _CreateViolationScreenState extends State<CreateViolationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController citizenNameController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;
  late final TextEditingController amountController;
  late final TextEditingController departmentIdController;

  DateTime? selectedDate;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    final v = widget.violation;

    titleController = TextEditingController(text: v?.title ?? '');
    citizenNameController = TextEditingController(text: v?.citizenName ?? '');
    descriptionController = TextEditingController(text: v?.description ?? '');
    locationController = TextEditingController(text: v?.location ?? '');
    amountController = TextEditingController(
      text: v == null ? '' : v.amount.toString(),
    );
    departmentIdController = TextEditingController(
      text: v == null ? '1' : v.departmentId.toString(),
    );

    if (v?.violationDate.isNotEmpty == true) {
      selectedDate = DateTime.tryParse(v!.violationDate);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    citizenNameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    amountController.dispose();
    departmentIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    final departmentId = int.tryParse(departmentIdController.text.trim());

    if (amount == null || departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount or department ID')),
      );
      return;
    }

    setState(() => _submitted = true);

    final violation = Violation(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      citizenName: citizenNameController.text.trim(),
      amount: amount,
      departmentId: departmentId,
      location: locationController.text.trim(),
      violationDate: selectedDate!.toIso8601String().split('T').first,
    );

    if (widget.isEdit) {
      final id = widget.violation!.id;

      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing violation ID')),
        );
        return;
      }

      context.read<ViolationBloc>().add(
            UpdateViolationEvent(
              id: id,
              violation: violation,
            ),
          );
    } else {
      context.read<ViolationBloc>().add(
            CreateViolationEvent(violation),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<ViolationBloc, ViolationState>(
      listener: (context, state) {
        if (_submitted && state is ViolationLoaded) {
          Navigator.pop(context);
        }

        if (_submitted && state is ViolationError) {
          setState(() => _submitted = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Violation' : loc.createViolation),
        ),
        body: BlocBuilder<ViolationBloc, ViolationState>(
          builder: (context, state) {
            final isLoading = _submitted && state is ViolationLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _input(
                      label: loc.name,
                      hint: loc.enterName,
                      controller: titleController,
                      validator: _required3To25,
                    ),
                    _input(
                      label: loc.citizenName,
                      hint: loc.enterCitizenName,
                      controller: citizenNameController,
                      validator: _required,
                    ),
                    _input(
                      label: loc.description,
                      hint: loc.enterDescription,
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      validator: _required,
                    ),
                    _input(
                      label: loc.location,
                      hint: loc.enterLocation,
                      controller: locationController,
                      validator: _required3To25,
                    ),
                    _input(
                      label: 'Department ID',
                      hint: 'Example: 1',
                      controller: departmentIdController,
                      keyboardType: TextInputType.number,
                      validator: _positiveInt,
                    ),
                    ViolationDatePicker(
                      selectedDate: selectedDate,
                      selectText: loc.selectDate,
                      onDatePicked: (date) {
                        setState(() => selectedDate = date);
                      },
                    ),
                    const SizedBox(height: 12),
                    _input(
                      label: loc.amount,
                      hint: loc.enterAmount,
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      validator: _positiveNumber,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(widget.isEdit ? 'Save' : loc.create),
                        onPressed: isLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _required3To25(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Required';
    }

    if (text.length < 3 || text.length > 25) {
      return 'Must be 3-25 characters';
    }

    return null;
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a valid amount';
    }

    return null;
  }

  String? _positiveInt(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a valid department ID';
    }

    return null;
  }
}