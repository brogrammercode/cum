import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/ui/input.dart';
import 'package:mobile/core/color.dart';
import 'package:mobile/core/routes.dart';

class EditGangPage extends StatelessWidget {
  const EditGangPage({super.key});

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
          'Edit Gang',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.softGrey,
                      borderRadius: BorderRadius.circular(32.r),
                    ),
                    child: Icon(
                      Icons.groups_outlined,
                      color: AppColors.primaryIndigo,
                      size: 40.w,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryIndigo,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
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
            _buildSectionHeader(context, 'MANAGEMENT'),
            _buildActionTile(
              context,
              icon: Icons.people_outline,
              iconColor: Colors.blueAccent,
              title: 'Edit Players',
              onTap: () => Navigator.pushNamed(context, AppRoutes.playerList),
            ),
            _buildActionTile(
              context,
              icon: Icons.assignment_ind_outlined,
              iconColor: Colors.greenAccent,
              title: 'Edit My Player Profile',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editPlayer),
            ),
            _buildActionTile(
              context,
              icon: Icons.admin_panel_settings_outlined,
              iconColor: Colors.purpleAccent,
              title: 'Edit Roles',
              onTap: () {},
            ),
            SizedBox(height: 32.h),
            _buildActionTile(
              context,
              icon: Icons.delete_outline,
              iconColor: Colors.redAccent,
              title: 'Disband Gang',
              textColor: Colors.redAccent,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary.withOpacity(0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.softGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: iconColor, size: 24.w),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.deepOnyx,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary.withOpacity(0.3),
          size: 20.w,
        ),
      ),
    );
  }
}
