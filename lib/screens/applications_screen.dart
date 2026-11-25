import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../ui.dart';
import 'application_detail_screen.dart';

/// Candidature ricevute per un annuncio dell'azienda (R7).
class ApplicationsScreen extends StatefulWidget {
  final Job job;
  const ApplicationsScreen({super.key, required this.job});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late Future<List<Application>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getApplications(widget.job.id);
  }

  void _reload() {
    setState(() {
      _future = Api.getApplications(widget.job.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Candidature: ${widget.job.title}')),
      body: FutureBuilder<List<Application>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorView(error: snap.error!, onRetry: _reload);
          }
          final apps = snap.data!;
          if (apps.isEmpty) {
            return const Center(child: Text('Nessuna candidatura ricevuta'));
          }
          return ListView.separated(
            itemCount: apps.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = apps[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(a.fullName),
                subtitle: Text('${a.email} · ${shortDate(a.createdAt)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ApplicationDetailScreen(application: a)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
