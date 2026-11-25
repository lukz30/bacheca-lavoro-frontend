import 'package:flutter/material.dart';

import '../config.dart';

/// Finestra per cambiare l'indirizzo del server. Restituisce true se è cambiato.
Future<bool> showServerSettings(BuildContext context) async {
  final controller = TextEditingController(text: AppConfig.baseUrl);
  final changed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Indirizzo del server'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'http://192.168.1.20:8000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Emulatore: http://10.0.2.2:8000\n'
                'Smartphone: http://IP_DEL_PC:8000\n'
                'Chrome: http://localhost:8000',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await AppConfig.reset();
            if (ctx.mounted) Navigator.pop(ctx, true);
          },
          child: const Text('Predefinito'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () async {
            await AppConfig.save(controller.text);
            if (ctx.mounted) Navigator.pop(ctx, true);
          },
          child: const Text('Salva'),
        ),
      ],
    ),
  );
  return changed ?? false;
}
