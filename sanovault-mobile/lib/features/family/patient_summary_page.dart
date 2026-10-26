import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:sanovault/api/patient_overview.dart';
import 'package:sanovault/api/api_exception.dart';
import 'package:sanovault/features/family/person_detail_page.dart';
import 'package:sanovault/features/medicines/medicines_page.dart';
import 'package:sanovault/features/reports/record_detail_page.dart';
import 'package:sanovault/features/reports/reports_page.dart';
import 'package:sanovault/features/tracking/visit_notes_page.dart';
import 'package:sanovault/session/session_scope.dart';
import 'package:sanovault/theme/sv_colors.dart';
import 'package:sanovault/util/dates.dart';
import 'package:sanovault/util/labels.dart';
import 'package:sanovault/widgets/sv_page.dart';

class PatientSummaryPage extends StatefulWidget {
  const PatientSummaryPage({super.key, required this.patientId});
  final String patientId;

  @override
  State<PatientSummaryPage> createState() => _PatientSummaryPageState();
}

class _PatientSummaryPageState extends State<PatientSummaryPage> {
  PatientOverviewData? _data;
  String? _error;
  String? _summaryError;
  bool _summaryLoading = false;
  bool _checking = true;
  bool _cached = false;
  int _generation = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    _timer?.cancel();
    final api = SessionScope.of(context).api;
    setState(() {
      _error = null;
      _summaryError = null;
      _checking = true;
      _summaryLoading = false;
    });
    try {
      if (_data == null) {
        final cached = await api.cachedPatientOverview(widget.patientId);
        if (!mounted || generation != _generation) return;
        if (cached != null) {
          setState(() {
            _data = cached;
            _cached = true;
          });
        }
      }
      final data = await api.patientOverview(widget.patientId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _data = data;
        _checking = false;
        _cached = false;
      });
      if (data.hasEvidence &&
          (data.caseSummary == null || data.caseSummary!.stale)) {
        unawaited(_generate(generation));
      }
    } catch (caught) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = caught.toString();
        _checking = false;
        if (caught is ApiException &&
            [401, 403, 404].contains(caught.statusCode)) {
          _data = null;
        }
      });
    }
  }

  Future<void> _generate(int generation, [int remaining = 45]) async {
    if (!mounted || generation != _generation) return;
    final api = SessionScope.of(context).api;
    setState(() => _summaryLoading = true);
    try {
      final result = await api.generatePatientCaseSummary(widget.patientId);
      if (!mounted || generation != _generation) return;
      if (result['state'] == 'processing' || result['state'] == 'changed') {
        if (remaining <= 0) {
          throw Exception(
            'The summary is still being prepared. Please try again shortly.',
          );
        }
        _timer = Timer(
          const Duration(seconds: 2),
          () => _generate(generation, remaining - 1),
        );
        return;
      }
      // Refresh also saves the generated summary in the encrypted offline cache.
      final data = await api.patientOverview(widget.patientId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _data = data;
        _summaryLoading = false;
      });
    } catch (caught) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _summaryError = caught.toString();
        _summaryLoading = false;
      });
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context)
        .push(CupertinoPageRoute<void>(builder: (_) => page));
    if (mounted) unawaited(_load());
  }

  void _openEvent(PatientTimelineEntry entry) {
    if (entry.kind == 'report' && entry.recordId != null) {
      _open(RecordDetailPage(recordId: entry.recordId!));
    } else if (entry.kind == 'medication') {
      _open(MedicinesPage(patientId: widget.patientId));
    } else {
      _open(VisitNotesPage(patientId: widget.patientId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final summary = data?.caseSummary;
    return SvLargePage(
      title: data?.name ?? 'Patient summary',
      error: _error,
      onRefresh: _load,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _open(PersonDetailPage(personId: widget.patientId)),
        child: const Text('Details'),
      ),
      child: data == null
          ? Padding(
              padding: const EdgeInsets.all(32),
              child: _checking
                  ? const CupertinoActivityIndicator()
                  : CupertinoButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_cached || _checking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _checking
                            ? 'Checking for updates…'
                            : 'Saved offline overview · Pull to refresh',
                        style: const TextStyle(
                          fontSize: 13,
                          color: SvColors.slate,
                        ),
                      ),
                    ),
                  _heading('Case summary', CupertinoIcons.doc_text),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: SvColors.brandTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SvColors.silver),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (summary != null) ...[
                          if (summary.stale)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Records have changed · Previous summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: SvColors.danger,
                                ),
                              ),
                            ),
                          Text(
                            summary.text,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'AI generated · Saved ${formatDisplayDate(summary.generatedAt)} · Verify against source records.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SvColors.slate,
                            ),
                          ),
                        ] else if (!data.hasEvidence)
                          const Text(
                            'Add reports, medicines or notes to build a case summary.',
                            style: TextStyle(color: SvColors.slate),
                          ),
                        if (_summaryLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Preparing case summary…',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_summaryError != null) ...[
                          const SizedBox(height: 10),
                          Text(_summaryError!),
                          CupertinoButton(
                            onPressed: _load,
                            child: const Text('Retry summary'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _heading('Explore health topics', CupertinoIcons.tag),
                  const Text(
                    'Larger tags have more linked reports. Tap a tag to explore.',
                    style: TextStyle(fontSize: 12, color: SvColors.slate),
                  ),
                  const SizedBox(height: 12),
                  if (data.tags.isEmpty)
                    const Text(
                      'Topics will appear as reports are tagged.',
                      style: TextStyle(fontSize: 14, color: SvColors.slate),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.tags
                        .map(
                          (topic) => ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width - 40,
                            ),
                            child: CupertinoButton(
                              color: SvColors.brandTint,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              onPressed: () => _open(
                                ReportsPage(
                                  patientId: widget.patientId,
                                  tag: topic.tag,
                                ),
                              ),
                              child: Text(
                                '${humanizeLabel(topic.tag)} · ${topic.count}',
                                style: TextStyle(
                                  color: SvColors.brandStrong,
                                  fontSize: 14 + 10 * topic.weight,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _heading('Treatment timeline', CupertinoIcons.calendar),
                  _table('Date', 'Documented events', data.timeline.length, (
                    index,
                    height,
                  ) {
                    final entry = data.timeline[index];
                    return _row(height, () => _openEvent(entry), [
                      SizedBox(
                        width: 76,
                        child: Text(
                          '${formatDisplayDate(entry.date)}${entry.dateIsUpload ? '\nUploaded' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: SvColors.slate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (entry.detail.isNotEmpty)
                              Text(
                                entry.detail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: SvColors.slate,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.arrow_up_right,
                        size: 16,
                        color: SvColors.brandStrong,
                      ),
                    ]);
                  }, 'No dated events yet.'),
                  const SizedBox(height: 8),
                  const Text(
                    'Reports, recorded medicine courses and observations. Open an event for its source.',
                    style: TextStyle(fontSize: 12, color: SvColors.slate),
                  ),
                  const SizedBox(height: 24),
                  _heading('Pathology trend', CupertinoIcons.lab_flask),
                  _table(
                    'Parameter',
                    'Latest / previous',
                    data.pathology.length,
                    (index, height) {
                      final entry = data.pathology[index];
                      final flagged = [
                        'high',
                        'low',
                        'abnormal',
                      ].contains(entry.status);
                      return _row(
                        height,
                        () => _open(RecordDetailPage(recordId: entry.recordId)),
                        [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${formatDisplayDate(entry.date)} · ${entry.trend}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SvColors.slate,
                                  ),
                                ),
                                Text(
                                  entry.reference == null
                                      ? 'No reference range'
                                      : 'Ref: ${entry.reference}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SvColors.slate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 116,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  entry.latest,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: flagged
                                        ? SvColors.danger
                                        : SvColors.ink,
                                  ),
                                ),
                                Text(
                                  entry.status == 'unknown'
                                      ? 'No range'
                                      : humanizeLabel(entry.status),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SvColors.slate,
                                  ),
                                ),
                                if (entry.previous != null)
                                  Text(
                                    '${entry.previous}\n${formatDisplayDate(entry.previousDate)}',
                                    textAlign: TextAlign.end,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: SvColors.slate,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    'No readable pathology results yet. Add a lab report from Reports.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Latest and previous documented results. Direction alone does not indicate improvement or deterioration.',
                    style: TextStyle(fontSize: 12, color: SvColors.slate),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _heading(String text, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: SvColors.brandStrong, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _table(
    String left,
    String right,
    int count,
    Widget Function(int, double) builder,
    String empty,
  ) {
    final height = math.max(
      104.0,
      MediaQuery.textScalerOf(context).scale(14) * 6.5,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: SvColors.surface,
          border: Border.all(color: SvColors.silver),
        ),
        child: Column(
          children: [
            Container(
              color: SvColors.groupedBackground,
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    left,
                    style: const TextStyle(fontSize: 12, color: SvColors.slate),
                  ),
                  Text(
                    right,
                    style: const TextStyle(fontSize: 12, color: SvColors.slate),
                  ),
                ],
              ),
            ),
            if (count == 0)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  empty,
                  style: const TextStyle(fontSize: 14, color: SvColors.slate),
                ),
              )
            else
              _ThreeRowList(
                count: count,
                rowHeight: height,
                builder: (index) => builder(index, height),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(double height, VoidCallback onTap, List<Widget> children) =>
      CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SvColors.silver, width: 0.5),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: SvColors.ink),
            child: Row(children: children),
          ),
        ),
      );
}

class _ThreeRowList extends StatefulWidget {
  const _ThreeRowList({
    required this.count,
    required this.rowHeight,
    required this.builder,
  });
  final int count;
  final double rowHeight;
  final Widget Function(int) builder;
  @override
  State<_ThreeRowList> createState() => _ThreeRowListState();
}

class _ThreeRowListState extends State<_ThreeRowList> {
  final _controller = ScrollController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: math.min(3, widget.count) * widget.rowHeight,
    child: CupertinoScrollbar(
      controller: _controller,
      thumbVisibility: widget.count > 3,
      child: ListView.builder(
        controller: _controller,
        primary: false,
        padding: EdgeInsets.zero,
        itemExtent: widget.rowHeight,
        itemCount: widget.count,
        itemBuilder: (_, index) => widget.builder(index),
      ),
    ),
  );
}
