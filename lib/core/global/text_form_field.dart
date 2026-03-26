import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import 'custom_text.dart';

class GlobalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  // Label/Heading
  final String? labelText;
  final bool isMandatory;

  // Input type & restrictions
  final TextInputType keyboardType;
  final bool isDigitOnly;
  final bool noSpecialCharacters;

  // Visibility / password
  final bool isHidden;
  final Widget? customVisibilityOnIcon;
  final Widget? customVisibilityOffIcon;

  // Suffix / Prefix
  final Widget? prefixIcon;
  final Widget? suffixIcon; // overrides visibility toggle if provided

  // Validation
  final String? Function(String?)? validator;

  // Read only
  final bool readOnly;

  // Colors
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? fillColor;

  // Shape
  final double borderRadius;
  final int maxLines;

  const GlobalTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.isMandatory = false,
    this.keyboardType = TextInputType.text,
    this.isDigitOnly = false,
    this.noSpecialCharacters = false,
    this.isHidden = false,
    this.customVisibilityOnIcon,
    this.customVisibilityOffIcon,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
    this.activeColor,
    this.inactiveColor,
    this.fillColor,
    this.borderRadius = 12,
    this.maxLines = 1,
  });

  @override
  State<GlobalTextField> createState() => _GlobalTextFieldState();
}

class _GlobalTextFieldState extends State<GlobalTextField> {
  late bool _obscureText;

  // resolved colors
  Color get _resolvedActiveColor =>
      widget.activeColor ?? AppColors.primaryColor;

  Color get _resolvedInactiveColor =>
      widget.inactiveColor ?? AppColors.primaryColor.withValues(alpha: 0.4);

  Color get _resolvedFillColor => widget.readOnly
      ? Colors.grey.withValues(alpha: 0.08)
      : (widget.fillColor ?? Color(0xFFF2F2F2));

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isHidden;
  }

  List<TextInputFormatter> get _inputFormatters {
    final formatters = <TextInputFormatter>[];

    if (widget.isDigitOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (widget.noSpecialCharacters) {
      // allows letters, digits, and spaces only
      formatters.add(
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
      );
    }

    return formatters;
  }

  Widget? get _buildSuffixIcon {
    // If a custom suffix is explicitly passed, use it (overrides toggle)
    if (widget.suffixIcon != null) return widget.suffixIcon;

    // If it's a hidden/password field, show toggle
    if (widget.isHidden) {
      return GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: _obscureText
            ? (widget.customVisibilityOffIcon ??
                  Icon(
                    Icons.visibility_off_outlined,
                    color: _resolvedInactiveColor,
                    size: 20.sp,
                  ))
            : (widget.customVisibilityOnIcon ??
                  Icon(
                    Icons.visibility_outlined,
                    color: _resolvedActiveColor,
                    size: 20.sp,
                  )),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label row ──────────────────────────────────────────────
        if (widget.labelText != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              normalText(
                text: widget.labelText!,
                fontWeight: FontWeight.w500,
                color: widget.readOnly ? Colors.grey : AppColors.primaryColor,
              ),
              if (widget.isMandatory) ...[
                SizedBox(width: 2.w),
                smallText(
                  text: '*',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ],
          ),
          SizedBox(height: 6.h),
        ],

        // ── Field ───────────────────────────────────────────────────
        TextFormField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: widget.isHidden ? 1 : widget.maxLines,
          inputFormatters: _inputFormatters,
          style: GoogleFonts.spaceGrotesk(
            color: widget.readOnly ? Colors.grey : AppColors.primaryColor,
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon,
            hintStyle: GoogleFonts.spaceGrotesk(
              color: _resolvedInactiveColor,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
            ),
            fillColor: _resolvedFillColor,
            filled: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 14.w,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _resolvedInactiveColor, width: 1),
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _resolvedActiveColor, width: 1.5),
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}

/*

// 1. Basic text field
GlobalTextField(
  controller: nameController,
  hintText: 'Enter your name',
  labelText: 'Full Name',
  isMandatory: true,
),

// 2. Email field
GlobalTextField(
  controller: emailController,
  hintText: 'example@mail.com',
  labelText: 'Email',
  isMandatory: true,
  keyboardType: TextInputType.emailAddress,
  validator: (val) => val!.isEmpty ? 'Email is required' : null,
),

// 3. Password field with default toggle icons
GlobalTextField(
  controller: passwordController,
  hintText: 'Enter password',
  labelText: 'Password',
  isMandatory: true,
  isHidden: true,
),

// 4. Password field with custom icons
GlobalTextField(
  controller: passwordController,
  hintText: 'Enter password',
  labelText: 'Password',
  isHidden: true,
  customVisibilityOnIcon: Icon(Icons.eye, color: Colors.blue),
  customVisibilityOffIcon: Icon(Icons.eye_slash, color: Colors.grey),
),

// 5. Digit only (e.g. OTP / phone)
GlobalTextField(
  controller: phoneController,
  hintText: '01XXXXXXXXX',
  labelText: 'Phone Number',
  isMandatory: true,
  keyboardType: TextInputType.phone,
  isDigitOnly: true,
),

// 6. No special characters (e.g. username)
GlobalTextField(
  controller: usernameController,
  hintText: 'Enter username',
  labelText: 'Username',
  noSpecialCharacters: true,
),

// 7. Read-only display field
GlobalTextField(
  controller: emailController,
  hintText: '',
  labelText: 'Registered Email',
  readOnly: true,
),

// 8. Custom active color
GlobalTextField(
  controller: searchController,
  hintText: 'Search...',
  activeColor: Colors.deepPurple,
  prefixIcon: Icon(Icons.search),
),

// 9. Multi-line notes field
GlobalTextField(
  controller: notesController,
  hintText: 'Write your notes here...',
  labelText: 'Notes',
  maxLines: 4,
  borderRadius: 16,
),
*/
