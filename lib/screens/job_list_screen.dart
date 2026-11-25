import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../ui.dart';
import 'company_auth_screen.dart';
import 'company_home_screen.dart';
import 'job_detail_screen.dart';
import 'server_settings_dialog.dart';
/// Schermata pubblica: bacheca con tutti gli annunci (R5).
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late Future<List<Job>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getJobs();
  }

  void _reload() {
    setState(() {
      _future = Api.getJobs();
    });
  }

  Future<void> _openCompanyArea() async {
    final Widget page =
        Api.isLoggedIn ? const CompanyHomeScreen() : const CompanyAuthScreen();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _reload(); // al ritorno la bacheca si aggiorna
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annunci di lavoro'),
        actions: [
          IconButton(
            onPressed: () async {
              final changed = await showServerSettings(context);
              if (changed && mounted) _reload();
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Indirizzo del server',
          ),
          TextButton.icon(
            onPressed: _openCompanyArea,
            icon: const Icon(Icons.business),
            label: const Text('Area aziende'),
          ),
        ],
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
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: jobs.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 120),
                    Center(child: Text('Nessun annuncio pubblicato')),
                  ])
                : ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final job = jobs[i];
                      return ListTile(
                        title: Text(job.title),
                        subtitle:
                            Text('${job.company} · ${shortDate(job.createdAt)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => JobDetailScreen(job: job)),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
