import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/profile_validators.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

/// Form profil. Dipakai saat pertama kali membuka aplikasi (initial null)
/// dan saat mengubah profil dari tab Profil (initial berisi profil lama).
class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? initial;

  const ProfileSetupScreen({super.key, this.initial});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _classController;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name);
    _nimController = TextEditingController(text: initial?.nim);
    _classController = TextEditingController(text: initial?.className);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ProfileProvider>();

    setState(() => _saving = true);
    final error = await provider.save(
      UserProfile(
        name: _nameController.text.trim(),
        nim: _nimController.text.trim(),
        className: _classController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Pertama kali: ProfileGate otomatis berpindah ke aplikasi.
    // Mengubah profil: tutup form dan beri tahu pengguna.
    if (_isEditing) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil diperbarui.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isEditing ? AppBar(title: const Text('Ubah profil')) : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isEditing) ...[
                      Icon(
                        Icons.restaurant_menu,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selamat datang di ResepKu',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Isi profilmu untuk mulai. '
                        'Data ini hanya disimpan di perangkat ini.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                    ],
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ProfileValidators.name,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nimController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ProfileValidators.nim,
                      decoration: const InputDecoration(
                        labelText: 'NIM',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _classController,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.characters,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ProfileValidators.className,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Kelas (opsional)',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Simpan' : 'Mulai'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
