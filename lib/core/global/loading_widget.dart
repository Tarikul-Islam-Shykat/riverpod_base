import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../const/app_colors.dart';

Widget loading({double value = 30}) {
  return Center(
    child: ShaderMask(
      shaderCallback: (bounds) => AppColors.gradientColor.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: LoadingAnimationWidget.hexagonDots(
        color: AppColors.primaryColor, // required for gradient to apply
        size: value.h,
      ),
    ),
  );
}

Widget loadingSmall() {
  return Center(
    child: ShaderMask(
      shaderCallback: (bounds) => AppColors.gradientColor.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: LoadingAnimationWidget.hexagonDots(
        color: AppColors.primaryColor, // required for gradient to apply
        size: 20.h,
      ),
    ),
  );
}

Widget btnLoading() {
  return Center(
    child: ShaderMask(
      shaderCallback: (bounds) => AppColors.gradientColor.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: LoadingAnimationWidget.hexagonDots(
        color: AppColors.primaryColor, // required for gradient to apply
        size: 40.h,
      ),
    ),
  );
}
