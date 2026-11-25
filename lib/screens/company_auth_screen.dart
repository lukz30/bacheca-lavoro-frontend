import 'package:flutter/material.dart';

import '../api_service.dart';
import '../ui.dart';
import 'company_home_screen.dart';

/// Registrazione (R1) e login (R2) dell'azienda nella stessa schermata.
class CompanyAuthScreen extends StatefulWidget {
  const CompanyAuthScreen({super.key});

  @override
  State<CompanyAuthScreen> createState() => _CompanyAuthScreenState();
}

class _CompanyAuthScreenState extends State<CompanyAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registerMode = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_registerMode) {
        await Api.register(_name.text.trim(), _email.text.trim(), _password.text);
        if (!mounted) return;
        // Come da scenario S1: dopo la registrazione l'azienda fa il login.
        setState(() {
          _registerMode = false;
          _password.clear();
        });
        showSnack(context, 'Account creato. Ora accedi con le tue credenziali.');
      } else {
        await Api.login(_email.text.trim(), _password.text);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompanyHomeScreen()),
        );
      }
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_registerMode ? 'Registrazione azienda' : 'Login azienda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_registerMode) ...[
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: "Nome dell'azienda", border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Campo obbligatorio';
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Email non valida';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Password', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obbligatorio';
                if (_registerMode && v.length < 6) return 'Almeno 6 caratteri';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_registerMode ? 'Registrati' : 'Accedi'),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() => _registerMode = !_registerMode),
              child: Text(_registerMode
                  ? 'Hai già un account? Accedi'
                  : 'Non hai un account? Registrati'),
            ),
          ],
        ),
      ),
    );
  }
}
