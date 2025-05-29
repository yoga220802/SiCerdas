import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Dibuat nullable agar bisa di-disable
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double height;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color? customBackgroundColor; // Untuk override warna background default per type
  final Color? customOutlineColor; // Untuk override warna outline default per type
  final Color? customTextColor; // Untuk override warna teks default per type

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width, // Defaultnya akan mengikuti style dari ElevatedButtonTheme
    this.height = 48.0,
    this.leadingIcon,
    this.trailingIcon,
    this.customBackgroundColor,
    this.customOutlineColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDisabled = onPressed == null || isLoading;

    // Menentukan style berdasarkan tipe tombol
    ButtonStyle? specificStyle;
    Color? foregroundColor = customTextColor;
    Color? backgroundColor = customBackgroundColor;
    Color? outlineColor = customOutlineColor;

    switch (type) {
      case ButtonType.primary:
        // Menggunakan style dari ElevatedButtonTheme jika tidak ada override
        foregroundColor ??=
            theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}) ?? AppColors.white;
        backgroundColor ??=
            theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}) ?? AppColors.primary;
        specificStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: (backgroundColor).withValues(alpha: .5),
          disabledForegroundColor: (foregroundColor).withValues(alpha: .7),
          minimumSize: Size(width ?? 64, height),
          padding: EdgeInsets.symmetric(
            horizontal: (leadingIcon != null || trailingIcon != null) ? 16 : 24,
            vertical: 0,
          ),
        );
        break;
      case ButtonType.secondary:
        foregroundColor ??= AppColors.primary;
        backgroundColor ??= AppColors.secondary.withValues(alpha: .2); // Biru muda transparan
        specificStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0, // Biasanya secondary button tidak ada shadow
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: .1),
          disabledForegroundColor: AppColors.primary.withValues(alpha: .5),
          minimumSize: Size(width ?? 64, height),
          padding: EdgeInsets.symmetric(
            horizontal: (leadingIcon != null || trailingIcon != null) ? 16 : 24,
            vertical: 0,
          ),
        );
        break;
      case ButtonType.outline:
        foregroundColor ??= customTextColor ?? AppColors.primary; // Warna teks sama dengan border
        outlineColor ??= customOutlineColor ?? AppColors.primary;
        backgroundColor ??= Colors.transparent;
        specificStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          side: BorderSide(color: outlineColor, width: 1.5),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: (foregroundColor).withValues(alpha: .5),
          minimumSize: Size(width ?? 64, height),
          padding: EdgeInsets.symmetric(
            horizontal: (leadingIcon != null || trailingIcon != null) ? 16 : 24,
            vertical: 0,
          ),
        );
        break;
      case ButtonType.text:
        // Menggunakan style dari TextButtonTheme jika tidak ada override
        foregroundColor ??=
            customTextColor ??
            theme.textButtonTheme.style?.foregroundColor?.resolve({}) ??
            AppColors.primary;
        specificStyle = TextButton.styleFrom(
          foregroundColor: foregroundColor,
          minimumSize: Size(width ?? 64, height),
          padding: EdgeInsets.symmetric(
            horizontal: (leadingIcon != null || trailingIcon != null) ? 8 : 16,
            vertical: 0,
          ),
        );
        // Untuk TextButton, kita gunakan widget TextButton secara langsung
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: specificStyle,
            child: _buildButtonChild(context, foregroundColor),
          ),
        );
    }

    return SizedBox(
      width: width, // Jika null, akan mengikuti parent atau minimumSize
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: specificStyle,
        child: _buildButtonChild(context, foregroundColor),
      ),
    );
  }

  Widget _buildButtonChild(BuildContext context, Color fgColor) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    List<Widget> children = [];
    if (leadingIcon != null) {
      children.add(
        IconTheme(
          data: IconTheme.of(context).copyWith(color: fgColor, size: 20),
          child: leadingIcon!,
        ),
      );
      children.add(AppSpacing.hsTiny);
    }
    children.add(
      Text(
        text,
        // Style teks diambil dari theme, tapi warna di-override jika perlu
        style:
            (type == ButtonType.text
                ? Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fgColor,
                  fontWeight: AppTypography.semiBold,
                )
                : Theme.of(context).textTheme.labelLarge?.copyWith(color: fgColor)),
      ),
    );
    if (trailingIcon != null) {
      children.add(AppSpacing.hsTiny);
      children.add(
        IconTheme(
          data: IconTheme.of(context).copyWith(color: fgColor, size: 20),
          child: trailingIcon!,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
