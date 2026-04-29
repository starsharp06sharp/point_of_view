import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/permission_service.dart';

/// Renders [child] only when the app has been granted "all files access".
/// Otherwise shows a prompt that lets the user jump to the system settings
/// page; re-checks automatically when the app comes back to the foreground.
class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_granted) {
      _check();
    }
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final granted = await PermissionService.hasFullAccess();
    if (!mounted) return;
    setState(() {
      _granted = granted;
      _checking = false;
    });
  }

  Future<void> _request() async {
    await PermissionService.requestAllFilesAccess();
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_granted) return widget.child;
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.permissionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_open, size: 64),
              const SizedBox(height: 16),
              Text(
                l.permissionExplanation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _request,
                icon: const Icon(Icons.shield_outlined),
                label: Text(l.permissionGrant),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await PermissionService.openSystemSettings();
                  await _check();
                },
                icon: const Icon(Icons.settings),
                label: Text(l.permissionOpenSettings),
              ),
              const SizedBox(height: 16),
              Text(
                l.permissionHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
