import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';

class CustomTextField extends StatefulWidget {
  final String? title; // Judul di atas field, opsional
  final String hintText; // Placeholder untuk field
  final TextEditingController controller; // Controller untuk mengelola input
  final bool obscureText; // Menentukan apakah teks harus disembunyikan
  final TextInputType keyboardType; // Jenis keyboard yang digunakan
  final String? Function(String?)? validator; // Fungsi validasi untuk form
  final Widget? prefixIcon; // Ikon di awal field
  final Widget? suffixIcon; // Ikon di akhir field (kustom, jika bukan password)
  final bool isPassword; // Menentukan apakah field adalah password
  final bool readOnly; // Menentukan apakah field hanya untuk dibaca
  final VoidCallback? onTap; // Callback saat field ditekan
  final ValueChanged<String>? onChanged; // Callback saat teks berubah
  final ValueChanged<String>? onSubmitted; // Callback saat teks dikirim
  final List<TextInputFormatter>? inputFormatters; // Format input
  final int? maxLength; // Panjang maksimum teks
  final int maxLines; // Jumlah baris maksimum
  final FocusNode? focusNode; // Node fokus untuk field
  final String? initialValue; // Nilai awal jika tidak menggunakan controller

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
    this.onSubmitted,
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
          onFieldSubmitted: widget.onSubmitted, // Meneruskan onSubmitted ke TextFormField
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
                        color: theme.colorScheme.onSurface.withAlpha(153), // Transparansi 60%
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
