import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';

class CustomTextField extends StatefulWidget {
  final String? title; // Judul di atas field, opsional
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // Untuk validasi form
  final Widget? prefixIcon;
  final Widget? suffixIcon; // Suffix icon kustom, jika bukan password
  final bool isPassword; // Flag khusus untuk field password
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final FocusNode? focusNode;
  final String? initialValue; // Jika tidak menggunakan controller

  const CustomTextField({
    super.key,
    this.title,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _currentObscureText;

  @override
  void initState() {
    super.initState();
    _currentObscureText = widget.obscureText || widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Agar column tidak memakan space berlebih
      children: [
        if (widget.title != null && widget.title!.isNotEmpty) ...[
          Text(
            widget.title!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500, // Sedikit lebih tebal dari body
            ),
          ),
          AppSpacing.vsTiny,
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          obscureText: _currentObscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.isPassword ? 1 : widget.maxLines, // Password selalu 1 baris
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            // Jika ini adalah field password, tampilkan ikon mata.
            // Jika ada suffixIcon kustom, tampilkan itu.
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _currentObscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentObscureText = !_currentObscureText;
                        });
                      },
                    )
                    : widget.suffixIcon,
            counterText:
                widget.maxLength != null
                    ? ""
                    : null, // Menyembunyikan counter default jika maxLength ada
          ),
        ),
      ],
    );
  }
}
