import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanovault/api/api_client.dart';
import 'package:sanovault/api/api_exception.dart';
import 'package:sanovault/api/patient_overview.dart';
import 'package:sanovault/api/sanovault_api.dart';
import 'package:sanovault/features/family/patient_summary_page.dart';
import 'package:sanovault/session/offline_store.dart';
import 'package:sanovault/session/session_controller.dart';
import 'package:sanovault/session/session_scope.dart';
import 'package:sanovault/session/session_store.dart';
import 'package:sanovault/theme/sv_theme.dart';

PatientOverviewData overview({bool stale = false, bool empty = false}) =>
    PatientOverviewData.fromJson({
      'patient': {'id': 'p1', 'name': 'Example patient'},
      'hasEvidence': !empty,
      'caseSummary': empty
          ? null
          : {
              'text':
                  'Documented hypertension, with ongoing prescribed treatment.',
              'generatedAt': '2026-10-26T12:00:00Z',
              'stale': stale,
            },
      'tags': empty
          ? []
          : [
              {'tag': 'hypertension', 'count': 5, 'weight': 1.0},
              {'tag': 'kidney', 'count': 1, 'weight': 0.45},
            ],
      'timeline': empty
          ? []
          : List.generate(
              5,
              (index) => {
                'id': 'r$index',
                'date': '2026-10-${25 - index}',
                'title': 'Event ${index + 1}',
                'detail': 'Documented clinical report',
                'kind': 'report',
                'recordId': 'r$index',
              },
            ),
      'pathology': empty
          ? []
          : List.generate(
              5,
              (index) => {
                'metric': 'm$index',
                'label': 'Parameter ${index + 1}',
                'latest': '9.2 g/dL',
                'previous': '11 g/dL',
                'date': '2026-10-25',
                'previousDate': '2026-09-01',
                'trend': 'Decreased',
                'status': 'low',
                'reference': '12–15 g/dL',
                'recordId': 'r$index',
              },
            ),
    });

class OverviewApi extends SanoVaultApi {
  OverviewApi(this.data) : super(ApiClient(readToken: () async => null));
  PatientOverviewData data;
  int generations = 0;
  bool failGeneration = false;
  @override
  Future<PatientOverviewData?> cachedPatientOverview(String id) async => null;
  @override
  Future<PatientOverviewData> patientOverview(String id) async => data;
  @override
  Future<Map<String, dynamic>> generatePatientCaseSummary(String id) async {
    generations++;
    if (failGeneration) throw const ApiException('AI processing is off.');
    data = overview();
    return {'state': 'ready'};
  }
}

Future<void> showOverview(
  WidgetTester tester,
  OverviewApi api, {
  double textScale = 1,
}) async {
  final controller = SessionController(
    api: api,
    store: SessionStore(),
    offline: OfflineStore(),
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    SessionScope(
      controller: controller,
      child: CupertinoApp(
        theme: buildSvTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const PatientSummaryPage(patientId: 'p1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'saved summary is reused; both three-row lists scroll to later entries independently',
    (tester) async {
      final api = OverviewApi(overview());
      await showOverview(tester, api);
      expect(
        find.text(
          'Documented hypertension, with ongoing prescribed treatment.',
        ),
        findsOneWidget,
      );
      expect(api.generations, 0);
      final lists = tester.widgetList<ListView>(find.byType(ListView)).toList();
      expect(lists.length, 2);
      for (var index = 0; index < lists.length; index++) {
        expect(tester.getSize(find.byType(ListView).at(index)).height, 312);
        lists[index].controller!.jumpTo(
          lists[index].controller!.position.maxScrollExtent,
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('Event 5'), findsOneWidget);
      expect(find.text('Parameter 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'stale summary refreshes once and does not regenerate on rebuild',
    (tester) async {
      final api = OverviewApi(overview(stale: true));
      await showOverview(tester, api);
      expect(api.generations, 1);
      await tester.pump();
      expect(api.generations, 1);
      expect(
        find.text('Records have changed · Previous summary'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'generation failure keeps the previous summary and source sections available',
    (tester) async {
      final api = OverviewApi(overview(stale: true))..failGeneration = true;
      await showOverview(tester, api);
      expect(
        find.text('Records have changed · Previous summary'),
        findsOneWidget,
      );
      expect(find.text('AI processing is off.'), findsOneWidget);
      expect(find.byType(ListView), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty patient does not request AI generation', (tester) async {
    final api = OverviewApi(overview(empty: true));
    await showOverview(tester, api);
    expect(api.generations, 0);
    expect(
      find.text('Add reports, medicines or notes to build a case summary.'),
      findsOneWidget,
    );
    expect(find.text('No dated events yet.'), findsOneWidget);
  });

  testWidgets(
    'larger accessibility text does not overflow the summary or data rows',
    (tester) async {
      await showOverview(tester, OverviewApi(overview()), textScale: 1.8);
      expect(tester.takeException(), isNull);
      for (final list in tester.widgetList<ListView>(find.byType(ListView))) {
        list.controller!.jumpTo(list.controller!.position.maxScrollExtent);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
