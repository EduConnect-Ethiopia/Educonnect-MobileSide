import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _check();
    InternetConnectionChecker().onStatusChange.listen((status) {
      if (!mounted) return;
      setState(() {
        _isOffline = status == InternetConnectionStatus.disconnected;
      });
    });
  }

  Future<void> _check() async {
    final connected = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    setState(() => _isOffline = !connected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          MaterialBanner(
            content: const Text(
              'You are offline. Some features may be unavailable until you reconnect.',
            ),
            leading: const Icon(Icons.wifi_off, color: Colors.orange),
            backgroundColor: Colors.orange.shade50,
            actions: [
              TextButton(onPressed: _check, child: const Text('Retry')),
            ],
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
