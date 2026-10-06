import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/features/staff/tasks/presentation/widgets/staff_task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

StaffTaskModel _task({String serviceType = 'External Works'}) {
  return StaffTaskModel.fromJson({
    'userTaskKey': 1,
    'name': 'إرسال المعلومات اللازمة',
    'state': 'CREATED',
    'assignee': '',
    'creationDate': '2026-09-29T06:21:55.348Z',
    'completionDate': '',
    'processInstanceKey': 2,
    'requestId': 42,
    'requestName': 'Fence repair',
    'requesterName': 'Rana',
    'serviceType': serviceType,
    'trackingNumber': 'REQ-0042',
  });
}

void main() {
  testWidgets('card shows the service and request without expanding details', (tester) async {
    await tester.pumpWidget(testApp(Scaffold(body: StaffTaskCard(task: _task()))));
    await tester.pumpAndSettle();

    expect(find.text('External Works'), findsOneWidget);
    expect(find.text('Fence repair · Rana · ‎#REQ-0042'), findsOneWidget);
    expect(find.text('2026-09-29 06:21'), findsOneWidget);
  });

  testWidgets('service name follows the app language', (tester) async {
    await tester.pumpWidget(testApp(Scaffold(body: StaffTaskCard(task: _task())), locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('External Works'), findsNothing);
    expect(find.text('أشغال خارجية'), findsOneWidget);
  });

  testWidgets('tasks without a linked request keep the plain layout', (tester) async {
    await tester.pumpWidget(testApp(Scaffold(body: StaffTaskCard(task: _task(serviceType: '')))));
    await tester.pumpAndSettle();

    expect(find.text('External Works'), findsNothing);
  });
}
