import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:baladiyati/common/widgets/primary_button.dart';
import '../../data/model/RequestModel.dart';

class RequestDetailPage extends StatelessWidget {
  final RequestModel request;

  const RequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestDetails),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              request.title,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            Text(request.description),
            const SizedBox(height: 10),

            Text("${l10n.address}: ${request.addressText}"),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: l10n.reject,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.approve,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,
                    onPressed: () {},
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