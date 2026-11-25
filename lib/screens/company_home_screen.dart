import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../ui.dart';
import 'applications_screen.dart';
import 'new_job_screen.dart';

/// Area riservata dell'azienda: elenco dei propri annunci, logout (R3).
class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  late Future<List<Job>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.myJobs();
  }

  void _reload() {
    setState(() {
      _future = Api.myJobs();
    });
  }

  Future<void> _newJob() async {
    final published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NewJobScreen()),
    );
    if (published == true && mounted) {
      _reload();
      showSnack(context, 'Annuncio pubblicato: ora è visibile in bacheca');
    }
  }

  Future<void> _logout() async {
    await Api.logout();
    if (!mounted) return;
    // torna alla schermata pubblica: l'area riservata non è più raggiungibile
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Api.companyName ?? 'Area azienda'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newJob,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo annuncio'),
      ),
      body: FutureBuilder<List<Job>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorView(error: snap.error!, onRetry: _reload);
          }
          final jobs = snap.data!;
          if (jobs.isEmpty) {
            return const Center(
                child: Text('Non hai ancora pubblicato annunci'));
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final job = jobs[i];
              return ListTile(
                title: Text(job.title),
                subtitle: Text(
                    'Pubblicato il ${shortDate(job.createdAt)} · '
                    'Candidature: ${job.applicationsCount}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ApplicationsScreen(job: job)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
