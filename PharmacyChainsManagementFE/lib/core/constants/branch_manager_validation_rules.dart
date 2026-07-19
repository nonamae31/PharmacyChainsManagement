abstract final class BranchManagerValidationRules {
  static const minimumFullNameLength = 2;
  static const maximumFullNameLength = 150;
  static const maximumEmailLength = 150;
  static const maximumPhoneLength = 16;
  static const maximumPasswordLength = 100;
  static const maximumShiftHours = 12;
  static const maximumShiftNotesLength = 500;
  static const maximumAssessmentNotesLength = 1000;
  static const maximumCurrencyAmount = 999999999999.0;
  static const earliestSupportedDateYear = 2000;
  static const maximumSchedulingYears = 1;

  static final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final phonePattern = RegExp(r'^\+?[0-9]{9,15}$');
  static final strongPasswordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d])\S{8,100}$',
  );
  static final decimalPattern = RegExp(r'^\d+(?:\.\d{1,2})?$');
}
