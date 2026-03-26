import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../const/app_colors.dart';
import 'custom_text.dart';

class GlobalAppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color textColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool isLoading;

  const GlobalAppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isEnabled = true,
    this.backgroundColor,
    this.disabledColor,
    this.textColor = Colors.white,
    this.borderRadius = 100,
    this.width = double.infinity,
    this.height,
    this.isLoading = false,
  });

  Color get _resolvedBackground => backgroundColor ?? AppColors.bgColor;

  Color get _resolvedDisabledColor =>
      disabledColor ?? AppColors.primaryColor.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled && !isLoading;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: active ? _resolvedBackground : _resolvedDisabledColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius.r),
          splashColor: Colors.white.withValues(alpha: 0.3), // ripple color
          highlightColor: Colors.white.withValues(alpha: 0.1),
          onTap: active ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height ?? 52.h,
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : normalText(
                    text: text,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ),
      ),
    );
  }
}

/*
// 1. Basic — matches your screenshot exactly
GlobalAppButton(
  text: 'Log In',
  onTap: () => // your login logic,
),

// 2. Disabled state (e.g. form not yet filled)
GlobalAppButton(
  text: 'Log In',
  onTap: () => // your login logic,
  isEnabled: false,
),

// 3. Loading state (e.g. awaiting API response)
GlobalAppButton(
  text: 'Log In',
  onTap: () => // your login logic,
  isLoading: _isLoading,
),

// 4. Custom color + text color
GlobalAppButton(
  text: 'Continue',
  onTap: () {},
  backgroundColor: Colors.black,
  textColor: Colors.white,
),

// 5. Compact / fixed width button
GlobalAppButton(
  text: 'Verify',
  onTap: () {},
  width: 160.w,
  height: 44.h,
),

// 6. Toggling enabled based on form state
GlobalAppButton(
  text: 'Sign Up',
  onTap: _handleSignUp,
  isEnabled: _formKey.currentState?.validate() ?? false,
),

*/
