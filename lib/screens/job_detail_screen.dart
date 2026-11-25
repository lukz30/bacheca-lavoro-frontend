import 'package:flutter/material.dart';

import '../models.dart';
import '../ui.dart';
import 'apply_screen.dart';

/// Dettaglio di un annuncio (R5) con pulsante per candidarsi.
class JobDetailScreen extends StatelessWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${job.company} · pubblicato il ${shortDate(job.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium),
          const Divider(height: 32),
          Text(job.description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ApplyScreen(job: job)),
            ),
            icon: const Icon(Icons.send),
            label: const Text('Candidati'),
          ),
        ),
      ),
    );
  }
}
