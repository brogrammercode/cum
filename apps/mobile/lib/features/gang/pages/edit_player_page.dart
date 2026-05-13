import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/components/ui/button.dart';
import 'package:mobile/components/ui/input.dart';
import 'package:mobile/core/color.dart';

class EditPlayerPage extends StatelessWidget {
  const EditPlayerPage({super.key});

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
          'Player Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.softGrey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryIndigo.withOpacity(0.1),
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 50.w,
                  color: AppColors.primaryIndigo,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'ROLE: OWNER',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryIndigo,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            const AppInput(
              hintText: 'Gang Nickname',
              prefixIcon: Icon(Icons.alternate_email, color: AppColors.primaryIndigo),
            ),
            SizedBox(height: 20.h),
            const AppInput(
              hintText: 'Gang Specific Bio',
              prefixIcon: Icon(Icons.info_outline, color: AppColors.primaryIndigo),
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 40.h),
            AppButton(
              text: 'Update Player',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
