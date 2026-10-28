import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sanovault/api/models.dart';
import 'package:sanovault/session/session_scope.dart';
import 'package:sanovault/util/labels.dart';
import 'package:sanovault/widgets/sv_controls.dart';
import 'package:sanovault/widgets/sv_page.dart';
import 'package:share_plus/share_plus.dart';

class CareSharesPage extends StatefulWidget {
  const CareSharesPage({super.key});

  @override
  State<CareSharesPage> createState() => _CareSharesPageState();
}

class _CareSharesPageState extends State<CareSharesPage> {
  List<Person> _people = const [];
  List<Map<String, dynamic>> _shares = const [];
  final Set<String> _selected = {};
  final _label = TextEditingController();
  final _email = TextEditingController();
  String? _error;
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _label.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = SessionScope.of(context).api;
      final people = await SessionScope.of(context).people.ensure();
      final shares = await api.careShares();
      if (!mounted) return;
      setState(() {
        _people = people;
        _shares = shares;
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

  Future<void> _create() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one person');
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final share = await SessionScope.of(context).api.createCareShare(
        patientIds: _selected.toList(),
        label: _label.text.trim().isEmpty ? null : _label.text.trim(),
        invitedEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
      );
      final url = share['shareUrl'] as String? ?? '';
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      setState(() {
        _selected.clear();
        _label.clear();
        _email.clear();
        _creating = false;
      });
      await _load();
      if (!mounted || url.isEmpty) return;
      await SharePlus.instance.share(
        ShareParams(text: 'Please view these health records on SanoVault: $url'),
      );
    } catch (caught) {
      if (!mounted) return;
      setState(() {
        _error = caught.toString();
        _creating = false;
      });
    }
  }

  Future<void> _revoke(String id) async {
    await SessionScope.of(context).api.revokeCareShare(id);
    await _load();
  }

  String _personName(String id) {
    for (final person in _people) {
      if (person.id == id) return personName(person.firstName, person.lastName);
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return SvLargePage(
      title: 'Share with a doctor',
      error: _error,
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CupertinoActivityIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a view-only link for one or more people. Share it on WhatsApp or email. Access stays live until you revoke it.',
                  ),
                  const SizedBox(height: 16),
                  const Text('People', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  for (final person in _people)
                    CupertinoListTile(
                      title: Text(personName(person.firstName, person.lastName)),
                      trailing: CupertinoCheckbox(
                        value: _selected.contains(person.id),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selected.add(person.id);
                            } else {
                              _selected.remove(person.id);
                            }
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _label,
                    placeholder: 'Label (optional)',
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _email,
                    placeholder: 'Doctor email (optional)',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  SvFilledButton(
                    label: _creating ? 'Creating…' : 'Create share link',
                    onPressed: _creating ? null : _create,
                    enabled: !_creating,
                  ),
                  const SizedBox(height: 28),
                  const Text('Shares', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_shares.isEmpty)
                    const Text('No shares yet.')
                  else
                    for (final share in _shares) ...[
                      SvCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (share['label'] as String?)?.trim().isNotEmpty == true
                                  ? share['label'] as String
                                  : 'Untitled share',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ((share['patientIds'] as List?) ?? const [])
                                  .map((id) => _personName(id.toString()))
                                  .join(', '),
                            ),
                            if (share['revokedAt'] == null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Views: ${share['viewCount'] ?? 0}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      final url = share['shareUrl'] as String? ?? '';
                                      await Clipboard.setData(ClipboardData(text: url));
                                    },
                                    child: const Text('Copy link'),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _revoke(share['id'] as String),
                                    child: const Text('Revoke'),
                                  ),
                                ],
                              ),
                            ] else
                              const Text('Revoked', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
    );
  }
}
