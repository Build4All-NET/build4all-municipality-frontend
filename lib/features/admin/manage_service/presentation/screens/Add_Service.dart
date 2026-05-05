import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/update_service.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_bloc.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddServicePage extends StatefulWidget {
  final ServiceModel? service;

  const AddServicePage({super.key, this.service});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  late TextEditingController nameAr;
  late TextEditingController nameEn;
  late TextEditingController price;

  @override
  void initState() {
    super.initState();

    nameAr = TextEditingController(text: widget.service?.nameAr ?? '');
    nameEn = TextEditingController(text: widget.service?.nameEn ?? '');
    price = TextEditingController(
      text: widget.service?.feeAmount.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameAr.dispose();
    nameEn.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service == null
              ? loc.addService
              : loc.editService,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameAr,
              decoration: InputDecoration(
                labelText: loc.nameAr,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nameEn,
              decoration: InputDecoration(
                labelText: loc.nameEn,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.price,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.cancel),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final service = ServiceModel(
                        id: widget.service?.id ?? 0,
                        municipalityId: 1,
                        departmentId: 2,
                        nameAr: nameAr.text,
                        nameEn: nameEn.text,
                        descriptionAr: "",
                        descriptionEn: "",
                        slaDays: 10,
                        requiresInspection: false,
                        hasFees: true,
                        feeAmount: double.tryParse(price.text) ?? 0,
                        isActive: true,
                      );

                      final bloc = context.read<ServiceBloc>();

                      if (widget.service == null) {
                        bloc.add(AddService(service));
                      } else {
                        bloc.add(UpdateServiceEvent(widget.service!.id, service));
                      }

                      Navigator.pop(context);
                    },
                    child: Text(loc.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}