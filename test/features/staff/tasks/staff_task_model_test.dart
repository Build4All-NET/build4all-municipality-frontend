import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaffTaskModel.fromJson request-details enrichment', () {
    test('parses backend-enriched request fields', () {
      final task = StaffTaskModel.fromJson({
        'userTaskKey': 123,
        'name': 'Review_Application',
        'state': 'CREATED',
        'assignee': '',
        'creationDate': '2026-07-01',
        'completionDate': '',
        'processInstanceKey': 456,
        'requestId': 42,
        'requestName': 'Building Permit Request',
        'requesterName': 'John Doe',
        'serviceType': 'Building Permit',
        'department': 'Urban Planning',
        'trackingNumber': 'REQ-0001',
        'requestStatus': 'IN_PROGRESS',
      });

      expect(task.requestId, 42);
      expect(task.requestName, 'Building Permit Request');
      expect(task.requesterName, 'John Doe');
      expect(task.serviceType, 'Building Permit');
      expect(task.department, 'Urban Planning');
      expect(task.trackingNumber, 'REQ-0001');
      expect(task.requestStatus, 'IN_PROGRESS');
      expect(task.hasRequestDetails, isTrue);
    });

    test('defaults request fields to empty when the backend omits them', () {
      final task = StaffTaskModel.fromJson({
        'userTaskKey': 1,
        'name': 'Some_Task',
        'state': 'CREATED',
        'assignee': '',
        'creationDate': '',
        'completionDate': '',
        'processInstanceKey': null,
      });

      expect(task.requestId, isNull);
      expect(task.requestName, isEmpty);
      expect(task.requesterName, isEmpty);
      expect(task.hasRequestDetails, isFalse);
    });
  });
}
