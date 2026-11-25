import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../api_service.dart';
import '../models.dart';
import '../ui.dart';

/// Dati del candidato e apertura del curriculum (R7).
class ApplicationDetailScreen extends StatefulWidget {
  final Application application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _loading = false;

  Future<void> _openCv() async {
    setState(() => _loading = true);
    try {
      final path = await Api.downloadCv(widget.application);
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done && mounted) {
        showSnack(context, 'Impossibile aprire il PDF: ${result.message}');
      }
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.application;
    return Scaffold(
      appBar: AppBar(title: const Text('Candidatura')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Field(label: 'Nome', value: a.firstName),
          _Field(label: 'Cognome', value: a.lastName),
          _Field(label: 'Email', value: a.email),
          _Field(label: 'Inviata il', value: shortDate(a.createdAt)),
          _Field(label: 'Curriculum', value: a.cvName),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _openCv,
            icon: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf),
            label: const Text('Apri curriculum'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
