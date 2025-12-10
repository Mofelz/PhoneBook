// lib/screens/add_contact_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddContactScreen extends StatefulWidget {
  final String? id;
  final String? name;
  final String? phone;
  final String? avatarBase64;

  const AddContactScreen({
    super.key,
    this.id,
    this.name,
    this.phone,
    this.avatarBase64,
  });

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  late final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final MaskTextInputFormatter _phoneMaskFormatter;
  String? _avatarBase64;

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _phoneMaskFormatter = MaskTextInputFormatter(
      mask: '+7 (###) ###-##-##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    _nameController.text = widget.name ?? '';
    _avatarBase64 = widget.avatarBase64;
    if (widget.phone != null) {
      // Извлекаем только цифры (ожидаем 11 цифр, например: 79991234567)
      final digitsOnly = widget.phone!.replaceAll(RegExp(r'\D'), '');
      // Убеждаемся, что номер начинается с 7 (если длина 11 и первая цифра 8 → заменяем на 7)
      String normalizedDigits;
      if (digitsOnly.length == 11) {
        if (digitsOnly[0] == '8') {
          normalizedDigits = '7' + digitsOnly.substring(1);
        } else if (digitsOnly[0] == '7') {
          normalizedDigits = digitsOnly;
        } else {
          // Если не 7 и не 8 — оставляем как есть (редкий случай)
          normalizedDigits = digitsOnly;
        }
      } else {
        normalizedDigits = digitsOnly;
      }
      // Применяем маску к нормализованным цифрам
      _phoneController.text = _phoneMaskFormatter
          .formatEditUpdate(
            TextEditingValue(text: ''),
            TextEditingValue(text: normalizedDigits),
          )
          .text;
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _avatarBase64 = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Новый контакт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _avatarBase64 != null
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(_avatarBase64!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Нажмите, чтобы выбрать фото',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (v) => v!.trim().isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _phoneController,
                inputFormatters: [_phoneMaskFormatter],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Телефон'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите номер телефона';
                  }
                  // Извлекаем ТОЛЬКО цифры из видимого значения
                  final digitsOnly = RegExp(
                    r'[0-9]',
                  ).allMatches(value).map((m) => m.group(0)).join();
                  if (digitsOnly.length < 11) {
                    return 'Номер слишком короткий';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'id': widget.id,
                      'name': _nameController.text.trim(),
                      'phone': _normalizePhoneNumber(
                        _phoneMaskFormatter.getUnmaskedText(),
                      ),
                      'avatarBase64': _avatarBase64,
                    });
                  }
                },
                child: Text(_isEditing ? 'Сохранить' : 'Добавить'),
              ),
              if (_isEditing)
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, {'id': widget.id, 'delete': true}),
                  child: const Text(
                    'Удалить',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _normalizePhoneNumber(String rawDigits) {
  if (rawDigits.length == 11) {
    if (rawDigits[0] == '8') {
      return '7${rawDigits.substring(1)}';
    }
  }
  return rawDigits;
}
