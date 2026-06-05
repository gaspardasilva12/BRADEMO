import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  // Controllers para edição
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _campusController;

  @override
  void initState() {
    super.initState();
    final user = DatabaseService.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _campusController = TextEditingController(text: user?.campus ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 800);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      if (DatabaseService.currentUser != null) {
        DatabaseService.currentUser!.photoPath = picked.path;
      }
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Foto'),
          content: const Text('De onde você deseja adicionar a foto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(source: ImageSource.gallery);
              },
              child: const Text('Galeria'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(source: ImageSource.camera);
              },
              child: const Text('Câmera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _removePhoto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Foto'),
          content: const Text('Tem certeza que deseja remover a foto do perfil?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _imageBytes = null;
                  if (DatabaseService.currentUser != null) {
                    DatabaseService.currentUser!.photoPath = null;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto removida com sucesso!')),
                );
              },
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  bool _validateFields() {
    if (_nameController.text.trim().isEmpty) {
      _showValidationError('Nome não pode estar vazio');
      return false;
    }
    if (_emailController.text.trim().isNotEmpty &&
        !_isValidEmail(_emailController.text.trim())) {
      _showValidationError('Email inválido');
      return false;
    }
    if (_phoneController.text.trim().isNotEmpty &&
        !_isValidPhone(_phoneController.text.trim())) {
      _showValidationError('Telefone inválido (use apenas números e hífens)');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[\d\-\(\)\s]+$');
    return phoneRegex.hasMatch(phone);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _saveProfile() {
    if (!_validateFields()) return;

    final user = DatabaseService.currentUser;
    if (user != null) {
      setState(() {
        user.name = _nameController.text.trim();
        user.email = _emailController.text.trim();
        user.phone = _phoneController.text.trim();
        user.department = _departmentController.text.trim();
        user.campus = _campusController.text.trim();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _cancelEditing() {
    // Recarregar dados originais
    final user = DatabaseService.currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _departmentController.text = user?.department ?? '';
    _campusController.text = user?.campus ?? '';
    
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = DatabaseService.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
              tooltip: 'Cancelar',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
              tooltip: 'Salvar',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Nenhum usuário logado'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Foto do Perfil
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _showImageSourceDialog : null,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            backgroundImage: _imageBytes != null
                                ? MemoryImage(_imageBytes!) as ImageProvider
                                : const AssetImage('assets/images/IFSP-BRA.png'),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing && _imageBytes != null)
                      TextButton.icon(
                        onPressed: _removePhoto,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remover Foto'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Informações do Usuário
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Prontuário (não editável)
                            _buildInfoField(
                              label: 'Prontuário',
                              value: user.prontuario,
                              editable: false,
                              theme: theme,
                            ),
                            const SizedBox(height: 16),

                            // Nome
                            _buildEditableField(
                              label: 'Nome Completo',
                              controller: _nameController,
                              isEditing: _isEditing,
                              icon: Icons.person,
                              theme: theme,
                              required: true,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildEditableField(
                              label: 'Email',
                              controller: _emailController,
                              isEditing: _isEditing,
                              icon: Icons.email,
                              theme: theme,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Telefone
                            _buildEditableField(
                              label: 'Telefone',
                              controller: _phoneController,
                              isEditing: _isEditing,
                              icon: Icons.phone,
                              theme: theme,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Departamento
                            _buildEditableField(
                              label: 'Departamento',
                              controller: _departmentController,
                              isEditing: _isEditing,
                              icon: Icons.business,
                              theme: theme,
                            ),
                            const SizedBox(height: 16),

                            // Campus
                            _buildEditableField(
                              label: 'Campus',
                              controller: _campusController,
                              isEditing: _isEditing,
                              icon: Icons.location_on,
                              theme: theme,
                            ),
                            if (user.registrationDate != null) ...[
                              const SizedBox(height: 16),
                              _buildInfoField(
                                label: 'Data de Cadastro',
                                value: _formatDate(user.registrationDate!),
                                editable: false,
                                theme: theme,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão de Alterar Foto (quando não está editando)
                    if (!_isEditing && _imageBytes == null)
                      ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Adicionar Foto'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: theme.colorScheme.primary),
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              filled: true,
              fillColor: Colors.white,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isNotEmpty ? controller.text : 'Não informado',
                    style: TextStyle(
                      color: controller.text.isNotEmpty ? Colors.black87 : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required bool editable,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : 'Não informado',
                  style: TextStyle(
                    color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
