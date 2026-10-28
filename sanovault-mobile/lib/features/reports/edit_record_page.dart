import 'package:flutter/cupertino.dart';
import 'package:sanovault/api/models.dart';
import 'package:sanovault/session/session_scope.dart';
import 'package:sanovault/theme/sv_colors.dart';
import 'package:sanovault/util/dates.dart';
import 'package:sanovault/util/labels.dart';
import 'package:sanovault/widgets/sv_controls.dart';
import 'package:sanovault/widgets/sv_page.dart';

class EditRecordPage extends StatefulWidget {
  const EditRecordPage({super.key, required this.record});

  final HealthRecord record;

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  late final TextEditingController _title;
  late final TextEditingController _source;
  late final TextEditingController _doctor;
  late final TextEditingController _customType;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late String _recordType;
  late String _patientId;
  late DateTime _documentDate;
  List<Category> _categories = const [];
  List<Person> _people = const [];
  String? _error;
  String? _suggestionLabel;
  String? _suggestionCode;
  String? _suggestionName;
  String? _pendingCustomLabel;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _title = TextEditingController(text: record.displayTitle);
    _source = TextEditingController(text: record.source);
    _doctor = TextEditingController(text: record.doctorName ?? '');
    _customType = TextEditingController(
      text: '${record.data['customTypeLabel'] ?? ''}',
    );
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _recordType = record.recordType;
    _patientId = record.patientId;
    _documentDate =
        parseApiDate(record.documentDate) ??
        parseApiDate(record.createdAt) ??
        DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _title.dispose();
    _source.dispose();
    _doctor.dispose();
    _customType.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final scope = SessionScope.of(context);
      final categories = await scope.api.categories();
      final people = await scope.people.ensure();
      Person? current;
      for (final person in people) {
        if (person.id == _patientId) {
          current = person;
          break;
        }
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _people = people;
        _firstName.text = current?.firstName ?? '';
        _lastName.text = current?.lastName ?? '';
        _loading = false;
      });
    } catch (caught) {
      if (!mounted) return;
      setState(() {
        _error = caught.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    var selected = _documentDate;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 280,
          color: SvColors.surface,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selected,
                  maximumDate: DateTime.now().add(const Duration(days: 1)),
                  minimumDate: DateTime(1970),
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _documentDate = selected);
  }

  Future<void> _pickType() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Record type'),
          actions: [
            for (final category in _categories)
              CupertinoActionSheetAction(
                onPressed: () {
                  setState(() {
                    _recordType = category.code;
                    if (category.code != 'OTHER') _customType.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: Text(category.displayName),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _pickPatient() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Patient'),
          actions: [
            for (final person in _people)
              CupertinoActionSheetAction(
                onPressed: () {
                  setState(() {
                    _patientId = person.id;
                    _firstName.text = person.firstName;
                    _lastName.text = person.lastName ?? '';
                  });
                  Navigator.of(context).pop();
                },
                child: Text(personName(person.firstName, person.lastName)),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  String get _typeLabel {
    for (final category in _categories) {
      if (category.code == _recordType) return category.displayName;
    }
    return _recordType;
  }

  String get _patientLabel {
    for (final person in _people) {
      if (person.id == _patientId) {
        return personName(person.firstName, person.lastName);
      }
    }
    return 'Patient';
  }

  Future<void> _persist({
    required String recordType,
    String customTypeLabel = '',
  }) async {
    final api = SessionScope.of(context).api;
    if (_patientId == widget.record.patientId) {
      Person? original;
      for (final person in _people) {
        if (person.id == _patientId) {
          original = person;
          break;
        }
      }
      final nextFirst = _firstName.text.trim();
      final nextLast = _lastName.text.trim();
      if (original != null &&
          (nextFirst != original.firstName ||
              nextLast != (original.lastName ?? ''))) {
        await api.updatePatient(_patientId, {
          'firstName': nextFirst.isEmpty ? original.firstName : nextFirst,
          'lastName': nextLast,
        });
      }
    }

    final updated = await api.updateHealthRecord(widget.record.id, {
      'title': _title.text.trim(),
      'recordType': recordType,
      'source': _source.text.trim().isEmpty
          ? 'Not specified'
          : _source.text.trim(),
      'doctorName': recordType == 'ID_DOCUMENT' ? '' : _doctor.text.trim(),
      'documentDate': formatIsoDate(_documentDate),
      'patientId': _patientId,
      'customTypeLabel': recordType == 'OTHER' ? customTypeLabel : '',
      'tags': widget.record.tags,
    });
    if (!mounted) return;
    Navigator.of(context).pop(updated);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
      _suggestionLabel = null;
    });
    try {
      var recordType = _recordType;
      var customTypeLabel = _customType.text.trim();
      if (recordType == 'OTHER' && customTypeLabel.isNotEmpty) {
        final resolved = await SessionScope.of(
          context,
        ).api.resolveRecordType(customTypeLabel);
        final action = resolved['action'] as String?;
        if (action == 'suggest') {
          final suggestion = resolved['suggestion'] as Map?;
          setState(() {
            _suggestionLabel = resolved['customLabel'] as String? ?? customTypeLabel;
            _suggestionCode = suggestion?['code'] as String?;
            _suggestionName = suggestion?['displayName'] as String?;
            _pendingCustomLabel = _suggestionLabel;
            _saving = false;
          });
          return;
        }
        if (action == 'use_existing' || action == 'created') {
          recordType = resolved['code'] as String? ?? recordType;
          customTypeLabel = '';
          if (action == 'created') {
            final code = resolved['code'] as String?;
            final name = resolved['displayName'] as String?;
            if (code != null && name != null) {
              setState(() {
                _categories = [
                  ..._categories,
                  Category(code: code, displayName: name),
                ];
              });
            }
          }
        }
      }
      await _persist(recordType: recordType, customTypeLabel: customTypeLabel);
    } catch (caught) {
      if (!mounted) return;
      setState(() {
        _error = caught.toString();
        _saving = false;
      });
    }
  }

  Future<void> _acceptSuggestion() async {
    final code = _suggestionCode;
    if (code == null) return;
    setState(() => _saving = true);
    try {
      await _persist(recordType: code);
    } catch (caught) {
      if (!mounted) return;
      setState(() {
        _error = caught.toString();
        _saving = false;
      });
    }
  }

  Future<void> _keepCustom() async {
    final label = _pendingCustomLabel ?? _customType.text.trim();
    setState(() => _saving = true);
    try {
      await _persist(recordType: 'OTHER', customTypeLabel: label);
    } catch (caught) {
      if (!mounted) return;
      setState(() {
        _error = caught.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvLargePage(
      title: 'Edit report',
      error: _error,
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CupertinoActivityIndicator()),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (_suggestionLabel != null) ...[
                  SvCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"$_suggestionLabel" was not added globally. Closest match: ${_suggestionName ?? 'Other'}.',
                        ),
                        const SizedBox(height: 12),
                        SvFilledButton(
                          label: 'Use ${_suggestionName ?? 'suggestion'}',
                          onPressed: _saving ? null : _acceptSuggestion,
                          enabled: !_saving,
                        ),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          onPressed: _saving ? null : _keepCustom,
                          child: const Text('Keep custom on this record'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Title'),
                const SizedBox(height: 6),
                CupertinoTextField(controller: _title),
                const SizedBox(height: 16),
                const Text('Patient'),
                const SizedBox(height: 6),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickPatient,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_patientLabel),
                  ),
                ),
                if (_patientId == widget.record.patientId) ...[
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _firstName,
                    placeholder: 'First name',
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _lastName,
                    placeholder: 'Last name',
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Record type'),
                const SizedBox(height: 6),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickType,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_typeLabel),
                  ),
                ),
                if (_recordType == 'OTHER') ...[
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _customType,
                    placeholder: 'Custom type (optional)',
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Hospital or clinic'),
                const SizedBox(height: 6),
                CupertinoTextField(controller: _source),
                const SizedBox(height: 16),
                const Text('Doctor'),
                const SizedBox(height: 6),
                CupertinoTextField(controller: _doctor),
                const SizedBox(height: 16),
                const Text('Document date'),
                const SizedBox(height: 6),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickDate,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(formatDisplayDate(formatIsoDate(_documentDate))),
                  ),
                ),
                const SizedBox(height: 24),
                SvFilledButton(
                  label: _saving ? 'Saving…' : 'Save',
                  onPressed: _saving ? null : _save,
                  enabled: !_saving,
                ),
              ],
            ),
    );
  }
}
