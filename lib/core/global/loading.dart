import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../const/app_colors.dart';

Widget loading({double value = 40}) {
  return Center(
    child: LoadingAnimationWidget.staggeredDotsWave(
      color: AppColors.primaryColor, // required for gradient to apply
      size: value.h,
    ),
  );
}

Widget loadingSmall() {
  return Center(
    child: LoadingAnimationWidget.staggeredDotsWave(
      color: AppColors.primaryColor, // r
      size: 40.h,
    ),
  );
}

Widget btnLoading() {
  return Center(
    child: LoadingAnimationWidget.staggeredDotsWave(
      color: AppColors.primaryColor, //
      size: 40.h,
    ),
  );
}
