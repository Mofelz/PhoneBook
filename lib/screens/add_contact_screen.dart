// lib/screens/add_contact_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddContactScreen extends StatefulWidget {
  final String? id;
  final String? name;
  final String? surname;
  final String? phone;
  final String? avatarBase64;

  const AddContactScreen({
    super.key,
    this.id,
    this.name,
    this.surname,
    this.phone,
    this.avatarBase64,
  });

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  late final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _surnameController = TextEditingController();
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
    _surnameController.text = widget.surname ?? '';
    _avatarBase64 = widget.avatarBase64;
    if (widget.phone != null) {
      final digitsOnly = widget.phone!.replaceAll(RegExp(r'\D'), '');
      String normalizedDigits;
      if (digitsOnly.length == 11) {
        if (digitsOnly[0] == '8') {
          normalizedDigits = '7${digitsOnly.substring(1)}';
        } else if (digitsOnly[0] == '7') {
          normalizedDigits = digitsOnly;
        } else {
          normalizedDigits = digitsOnly;
        }
      } else {
        normalizedDigits = digitsOnly;
      }
      _phoneController.text = _phoneMaskFormatter
          .formatEditUpdate(
            const TextEditingValue(text: ''),
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
        actions: [
          TextButton(
            onPressed: () {
              // Валидация и отправка результата
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'id': widget.id,
                  'name': _nameController.text.trim(),
                  'surname': _surnameController.text.trim(),
                  'phone': _normalizePhoneNumber(
                    _phoneMaskFormatter.getUnmaskedText(),
                  ),
                  'avatarBase64': _avatarBase64,
                });
              }
            },
            child: Text(
              _isEditing ? 'Сохранить' : 'Добавить',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар + надпись
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _avatarBase64 != null
                              ? null
                              : const Color.fromARGB(255, 117, 115, 115),
                        ),
                        child: _avatarBase64 != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(_avatarBase64!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 75,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    if (_avatarBase64 == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: 120, // ширина кнопки
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                63,
                                59,
                                59,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _pickImage,
                            child: const Text(
                              'Добавить фото',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Поле "Имя" с фоном
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    80,
                    74,
                    74,
                  ), // очень светлый серый фон
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Имя',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Введите имя' : null,
                ),
              ),
              const SizedBox(height: 1),
              // Поле "Фамилия" с фоном
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 80, 74, 74),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    hintText: 'Фамилия',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Введите фамилию' : null,
                ),
              ),
              const SizedBox(height: 1),
              // Поле "Телефон" — без фона (как раньше, или тоже можно добавить)
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 80, 74, 74),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TextFormField(
                  controller: _phoneController,
                  inputFormatters: [_phoneMaskFormatter],
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Телефон',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите номер телефона';
                    }
                    final digitsOnly = RegExp(
                      r'[0-9]',
                    ).allMatches(value).map((m) => m.group(0)).join();
                    if (digitsOnly.length < 11) {
                      return 'Номер слишком короткий';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Кнопка удалить
              if (_isEditing)
                Center(
                  child: SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, {
                        'id': widget.id,
                        'delete': true,
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Удалить'),
                    ),
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

Widget? _buildClearIcon(TextEditingController controller) {
  if (kIsWeb) return null; // на вебе не показываем
  return controller.text.isEmpty
      ? null
      : IconButton(
          icon: const Icon(Icons.clear, size: 18),
          onPressed: () {
            controller.clear();
          },
        );
}
