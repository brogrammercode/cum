import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/components/ui/button.dart';
import 'package:mobile/components/ui/input.dart';
import 'package:mobile/core/color.dart';

class CreateGangPage extends StatelessWidget {
  const CreateGangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepOnyx),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Gang',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.softGrey,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primaryIndigo,
                size: 32.w,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Add Gang Logo',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 40.h),
            const AppInput(
              hintText: 'Gang Name',
              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primaryIndigo),
            ),
            SizedBox(height: 20.h),
            const AppInput(
              hintText: 'Gang Description',
              prefixIcon: Icon(Icons.description_outlined, color: AppColors.primaryIndigo),
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 40.h),
            AppButton(
              text: 'Build My Gang',
              onPressed: () {
                // Return to settings or home after creation
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
