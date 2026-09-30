import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/usecases/MarkRequestPaid.dart';
import 'package:baladiyati/features/admin/Requests/domain/usecases/UpdateRequestStatus.dart';
import 'package:baladiyati/features/admin/Requests/domain/usecases/getAll_Req_Admin.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Bloc.dart';
import 'package:baladiyati/features/admin/Requests/presentation/screens/Request_Detail.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';

const _requestId = 42;

/// Records what the request screen asks the backend to do.
class _FakeRequestRepository implements RequestRepository {
  final List<int> paidIds = [];
  final List<String> statusUpdates = [];

  @override
  Future<void> markPaid(int id) async => paidIds.add(id);

  @override
  Future<void> updateStatus(int id, String status, {String? message}) async =>
      statusUpdates.add(status);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

RequestModel _approvedRequest() => const RequestModel(
      id: _requestId,
      municipalityId: 1,
      serviceId: 1,
      citizenUserId: 1,
      trackingNumber: 'REQ-1',
      title: 'Building permit',
      description: 'test',
      category: '',
      status: 'APPROVED',
      geoLat: 0,
      geoLng: 0,
      addressText: 'Beirut',
      createdAt: '',
      updatedAt: '',
      closedAt: '',
      municipalityName: '',
      serviceName: 'Building Permit',
      citizenName: 'Citizen',
      attachments: [],
    );

void main() {
  late _FakeRequestRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({'session_role': 'OWNER'});
    repo = _FakeRequestRepository();
  });

  Future<void> openRequest(WidgetTester tester) async {
    setScreenSize(tester, desktopSize);
    await tester.pumpWidget(testApp(
      BlocProvider(
        create: (_) => RequestBloc(
          getAllRequestsAdmin: GetAllRequestsAdmin(repo),
          updateRequestStatus: UpdateRequestStatus(repo),
          markRequestPaid: MarkRequestPaid(repo),
        ),
        child: RequestDetailPage(request: _approvedRequest()),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> pressComplete(WidgetTester tester) async {
    final complete = find.widgetWithText(PrimaryButton, 'Complete');
    await tester.ensureVisible(complete);
    await tester.tap(complete);
    await tester.pumpAndSettle();
  }

  testWidgets('Complete asks whether the citizen paid', (tester) async {
    await openRequest(tester);
    await pressComplete(tester);

    expect(find.textContaining('Has the citizen paid the fees'), findsOneWidget);
    expect(find.text('Yes, paid'), findsOneWidget);
    expect(find.text('Not yet'), findsOneWidget);
  });

  testWidgets('"Not yet" records nothing', (tester) async {
    await openRequest(tester);
    await pressComplete(tester);
    await tester.tap(find.text('Not yet'));
    await tester.pumpAndSettle();

    expect(repo.paidIds, isEmpty);
    expect(repo.statusUpdates, isEmpty);
  });

  testWidgets('"Yes, paid" records the payment instead of forcing COMPLETED', (tester) async {
    await openRequest(tester);
    await pressComplete(tester);
    await tester.tap(find.text('Yes, paid'));
    await tester.pumpAndSettle();

    expect(repo.paidIds, [_requestId]);
    expect(repo.statusUpdates, isNot(contains('COMPLETED')));
  });
}
