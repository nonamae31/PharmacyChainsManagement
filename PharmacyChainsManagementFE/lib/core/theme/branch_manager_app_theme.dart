import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF003F63);
  static const primaryDark = Color(0xFF002F4A);
  static const teal = Color(0xFF138B87);
  static const tealSoft = Color(0xFFE4F6F4);
  static const background = Color(0xFFF7F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFDDE3EA);
  static const textPrimary = Color(0xFF162536);
  static const textSecondary = Color(0xFF667382);
  static const muted = Color(0xFF98A4B2);
  static const danger = Color(0xFFD64B4B);
  static const dangerSoft = Color(0xFFFFE8E8);
  static const warning = Color(0xFFD47D18);
  static const warningSoft = Color(0xFFFFF2DF);
  static const success = Color(0xFF198C72);
  static const successSoft = Color(0xFFE1F6EF);
  static const chartMuted = Color(0xFFC9D7E2);
  static const overlay = Color(0x14003F63);
  static const transparent = Color(0x00000000);
  static const shadow = Color(0x1F0A2540);
  static const shadowSoft = Color(0x0F0A2540);

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}

abstract final class AppSpacing {
  static const hairline = 1.0;
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const navWidth = 176.0;
  static const headerHeight = 68.0;
  static const metricHeight = 128.0;
  static const chartHeight = 238.0;
  static const tableRowHeight = 58.0;
  static const iconSmall = 16.0;
  static const iconMedium = 20.0;
  static const iconLarge = 28.0;
  static const searchWidth = 300.0;
  static const progressWidth = 130.0;
  static const statusFilterWidth = 170.0;
  static const categoryFilterWidth = 190.0;
  static const confirmationDialogWidth = 440.0;
  static const dialogWidthCompact = 420.0;
  static const dialogWidthStandard = 480.0;
  static const dialogWidthWide = 540.0;
  static const replenishmentDialogWidth = 920.0;
  static const replenishmentDialogHeight = 720.0;
  static const replenishmentMedicineFieldWidth = 360.0;
  static const replenishmentQuantityFieldWidth = 140.0;
  static const narrowMobileBreakpoint = 360.0;
  static const mobileHeaderBreakpoint = 720.0;
  static const stackedPanelBreakpoint = 820.0;
  static const compactNavigationBreakpoint = 840.0;
  static const fourColumnBreakpoint = 900.0;
}

abstract final class AppRadius {
  static const small = 4.0;
  static const medium = 8.0;
  static const large = 12.0;
  static const pill = 999.0;
}

abstract final class AppTextStyles {
  static const pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const metricLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    color: AppColors.textSecondary,
  );
  static const metricValue = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(fontSize: 13, color: AppColors.textPrimary);
  static const caption = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );
  static const tableHeader = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
  static const bannerTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );
  static const bannerBody = TextStyle(color: AppColors.tealSoft);
}

abstract final class BranchManagerAppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: roundedShape,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: AppColors.surface,
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        titleTextStyle: AppTextStyles.pageTitle.copyWith(fontSize: 19),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: const TextStyle(color: AppColors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.background),
        headingTextStyle: AppTextStyles.tableHeader,
        dataTextStyle: AppTextStyles.body,
        dataRowMinHeight: AppSpacing.tableRowHeight,
        dataRowMaxHeight: AppSpacing.tableRowHeight,
        dividerThickness: AppSpacing.hairline,
        columnSpacing: AppSpacing.lg,
        headingRowHeight: AppSpacing.xxl,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.tealSoft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
