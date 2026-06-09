import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Baladiyati'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Municipality'**
  String get appSubtitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'An integrated digital platform for Lebanese municipal services'**
  String get appDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your municipality account'**
  String get loginSubtitle;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @passwordInfo.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordInfo;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCodeButton;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginNow;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join your municipality platform'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ahmad Khalil'**
  String get fullNameHint;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameHint;

  /// No description provided for @firstNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'First name is too short'**
  String get firstNameTooShort;

  /// No description provided for @lastNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Last name is too short'**
  String get lastNameTooShort;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username is too short'**
  String get usernameTooShort;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Use only letters, numbers, dot, or underscore'**
  String get usernameInvalidChars;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneHint;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @gmailOnly.
  ///
  /// In en, this message translates to:
  /// **'Gmail only allowed'**
  String get gmailOnly;

  /// No description provided for @eightDigits.
  ///
  /// In en, this message translates to:
  /// **'Must be 8 digits'**
  String get eightDigits;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Baladiyati - All rights reserved'**
  String get copyright;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get errorUserNotFound;

  /// No description provided for @errorAccountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in'**
  String get errorAccountNotVerified;

  /// No description provided for @errorEmailExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get errorEmailExists;

  /// No description provided for @successLogin.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get successLogin;

  /// No description provided for @successRegister.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get successRegister;

  /// No description provided for @emailMethod.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailMethod;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'We will send a 6-digit code to your email.'**
  String get info;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email'**
  String get verifySubtitle;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @verifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully'**
  String get verifySuccess;

  /// No description provided for @enterFullCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the full code'**
  String get enterFullCode;

  /// No description provided for @verificationUserIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Verification succeeded but user id was missing.'**
  String get verificationUserIdMissing;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your info to access services'**
  String get completeProfileSubtitle;

  /// No description provided for @completeProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfileButton;

  /// No description provided for @completeProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile completed successfully!'**
  String get completeProfileSuccess;

  /// No description provided for @missingRegistrationData.
  ///
  /// In en, this message translates to:
  /// **'No saved registration data found. Please register again.'**
  String get missingRegistrationData;

  /// No description provided for @missingUserIdVerifyAgain.
  ///
  /// In en, this message translates to:
  /// **'Missing user id. Please verify your code again.'**
  String get missingUserIdVerifyAgain;

  /// No description provided for @missingOwnerProjectLinkId.
  ///
  /// In en, this message translates to:
  /// **'Missing owner project link id. Please register again.'**
  String get missingOwnerProjectLinkId;

  /// No description provided for @municipalityProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete municipality profile'**
  String get municipalityProfileTitle;

  /// No description provided for @municipalityProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the information required by your municipality.'**
  String get municipalityProfileSubtitle;

  /// No description provided for @municipalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get municipalityLabel;

  /// No description provided for @selectMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Select municipality'**
  String get selectMunicipality;

  /// No description provided for @selectMunicipalityWarning.
  ///
  /// In en, this message translates to:
  /// **'Please select a municipality'**
  String get selectMunicipalityWarning;

  /// No description provided for @completeMunicipalityProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get completeMunicipalityProfileButton;

  /// No description provided for @municipalityProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Municipality profile saved successfully'**
  String get municipalityProfileSaved;

  /// No description provided for @municipalityProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save municipality profile'**
  String get municipalityProfileSaveFailed;

  /// No description provided for @loadingMunicipalitiesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load municipalities'**
  String get loadingMunicipalitiesFailed;

  /// No description provided for @noMunicipalitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No municipalities found'**
  String get noMunicipalitiesFound;

  /// No description provided for @missingMunicipalityId.
  ///
  /// In en, this message translates to:
  /// **'Missing municipality id'**
  String get missingMunicipalityId;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get addressHint;

  /// No description provided for @addressTooShort.
  ///
  /// In en, this message translates to:
  /// **'Address is too short'**
  String get addressTooShort;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain 8 to 15 digits'**
  String get phoneInvalid;

  /// No description provided for @missingBuild4allToken.
  ///
  /// In en, this message translates to:
  /// **'Missing login token. Please login again.'**
  String get missingBuild4allToken;

  /// No description provided for @missingBuild4allUser.
  ///
  /// In en, this message translates to:
  /// **'Missing user data. Please login again.'**
  String get missingBuild4allUser;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password and confirm it'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get savePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcomeMessage;

  /// No description provided for @activeRequests.
  ///
  /// In en, this message translates to:
  /// **'Active Requests'**
  String get activeRequests;

  /// No description provided for @awaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get awaitingPayment;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New request received'**
  String get newRequest;

  /// No description provided for @serviceCategories.
  ///
  /// In en, this message translates to:
  /// **'Service Categories'**
  String get serviceCategories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @recentRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent Requests'**
  String get recentRequests;

  /// No description provided for @municipalAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Municipal Announcements'**
  String get municipalAnnouncements;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest news and updates'**
  String get latestNews;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'New working hours: Monday to Friday, 8 AM - 2 PM'**
  String get workingHours;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @municipalServices.
  ///
  /// In en, this message translates to:
  /// **'Municipal Services'**
  String get municipalServices;

  /// No description provided for @searchService.
  ///
  /// In en, this message translates to:
  /// **'Search for a service...'**
  String get searchService;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @serviceCount.
  ///
  /// In en, this message translates to:
  /// **'services'**
  String get serviceCount;

  /// No description provided for @searchInServices.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchInServices;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServices;

  /// No description provided for @requiresInspection.
  ///
  /// In en, this message translates to:
  /// **'Requires Inspection'**
  String get requiresInspection;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @serviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Service Information'**
  String get serviceInfo;

  /// No description provided for @feeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee:'**
  String get feeLabel;

  /// No description provided for @processingTime.
  ///
  /// In en, this message translates to:
  /// **'Processing Time:'**
  String get processingTime;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get editInfo;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due:'**
  String get dueDate;

  /// No description provided for @paidDate.
  ///
  /// In en, this message translates to:
  /// **'Paid:'**
  String get paidDate;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt:'**
  String get receiptNumber;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccess;

  /// No description provided for @lbp.
  ///
  /// In en, this message translates to:
  /// **'LBP'**
  String get lbp;

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments'**
  String get noPayments;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @searchRequest.
  ///
  /// In en, this message translates to:
  /// **'Search by number or name...'**
  String get searchRequest;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;
  String get filterActive;
  String get filterDone;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusUnderReview;

  /// No description provided for @statusWaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get statusWaitingPayment;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequests;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @submissionDate.
  ///
  /// In en, this message translates to:
  /// **'Submission Date'**
  String get submissionDate;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get amountDue;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get requestDetails;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter request title'**
  String get titleHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Detailed description...'**
  String get descriptionHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Address or GPS location'**
  String get locationHint;

  /// No description provided for @requiredAttachments.
  ///
  /// In en, this message translates to:
  /// **'Required Attachments'**
  String get requiredAttachments;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload attachments'**
  String get tapToUpload;

  /// No description provided for @pdfOrImages.
  ///
  /// In en, this message translates to:
  /// **'Photos or PDF files'**
  String get pdfOrImages;

  /// No description provided for @filesSelected.
  ///
  /// In en, this message translates to:
  /// **'file(s) selected'**
  String get filesSelected;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get requestSubmitted;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get authUsernameTaken;

  /// No description provided for @authEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authEmailAlreadyExists;

  /// No description provided for @authPhoneAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered'**
  String get authPhoneAlreadyExists;

  /// No description provided for @authUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get authUserNotFound;

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authWrongPassword;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid login credentials'**
  String get authInvalidCredentials;

  /// No description provided for @authAccountInactive.
  ///
  /// In en, this message translates to:
  /// **'Account is inactive'**
  String get authAccountInactive;

  /// No description provided for @httpValidationError.
  ///
  /// In en, this message translates to:
  /// **'Some fields are invalid'**
  String get httpValidationError;

  /// No description provided for @httpConflict.
  ///
  /// In en, this message translates to:
  /// **'Request conflict occurred'**
  String get httpConflict;

  /// No description provided for @httpUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized'**
  String get httpUnauthorized;

  /// No description provided for @httpForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission'**
  String get httpForbidden;

  /// No description provided for @httpNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get httpNotFound;

  /// No description provided for @httpServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get httpServerError;

  /// No description provided for @networkNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkNoInternet;

  /// No description provided for @networkTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get networkTimeout;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get networkError;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get authErrorGeneric;

  /// No description provided for @connection_offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get connection_offline;

  /// No description provided for @connection_reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get connection_reconnecting;

  /// No description provided for @connection_issue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get connection_issue;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @newRequests.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get newRequests;

  /// No description provided for @needReview.
  ///
  /// In en, this message translates to:
  /// **'Need Review'**
  String get needReview;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get completedToday;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees Management'**
  String get employees;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @approvedRequest.
  ///
  /// In en, this message translates to:
  /// **'Approved request'**
  String get approvedRequest;

  /// No description provided for @missingDocs.
  ///
  /// In en, this message translates to:
  /// **'Missing documents'**
  String get missingDocs;

  /// No description provided for @monthPerformance.
  ///
  /// In en, this message translates to:
  /// **'Monthly Performance'**
  String get monthPerformance;

  /// No description provided for @completedRequests.
  ///
  /// In en, this message translates to:
  /// **'Completed Requests'**
  String get completedRequests;

  /// No description provided for @avgTime.
  ///
  /// In en, this message translates to:
  /// **'Average Time'**
  String get avgTime;

  /// No description provided for @satisfaction.
  ///
  /// In en, this message translates to:
  /// **'Satisfaction'**
  String get satisfaction;

  /// No description provided for @chooseHowToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose how to continue'**
  String get chooseHowToContinue;

  /// No description provided for @continueAsCitizen.
  ///
  /// In en, this message translates to:
  /// **'Continue as Citizen'**
  String get continueAsCitizen;

  /// No description provided for @continueAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Continue as Admin'**
  String get continueAsAdmin;

  /// No description provided for @violations.
  ///
  /// In en, this message translates to:
  /// **'Violations'**
  String get violations;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments Management'**
  String get departments;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @announcementsManagement.
  ///
  /// In en, this message translates to:
  /// **'Announcements Management'**
  String get announcementsManagement;

  /// No description provided for @newAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New Announcement'**
  String get newAnnouncement;

  /// No description provided for @createAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Create New Announcement'**
  String get createAnnouncement;

  /// No description provided for @publishAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Publish Announcement'**
  String get publishAnnouncement;

  /// No description provided for @titleAr.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get titleAr;

  /// No description provided for @titleEn.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get titleEn;

  /// No description provided for @contentAr.
  ///
  /// In en, this message translates to:
  /// **'Content (Arabic)'**
  String get contentAr;

  /// No description provided for @contentEn.
  ///
  /// In en, this message translates to:
  /// **'Content (English)'**
  String get contentEn;

  /// No description provided for @enterTitleAr.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitleAr;

  /// No description provided for @enterTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitleEn;

  /// No description provided for @enterContentAr.
  ///
  /// In en, this message translates to:
  /// **'Enter content'**
  String get enterContentAr;

  /// No description provided for @enterContentEn.
  ///
  /// In en, this message translates to:
  /// **'Enter content'**
  String get enterContentEn;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @sampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Working hours update'**
  String get sampleTitle;

  /// No description provided for @sampleDescription.
  ///
  /// In en, this message translates to:
  /// **'Monday to Friday 8AM - 2PM'**
  String get sampleDescription;

  /// No description provided for @addViolation.
  ///
  /// In en, this message translates to:
  /// **'Add Violation'**
  String get addViolation;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @engineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get engineering;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police Officer'**
  String get police;

  /// No description provided for @titleArabic.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get titleArabic;

  /// No description provided for @titleEnglish.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get titleEnglish;

  /// No description provided for @contentArabic.
  ///
  /// In en, this message translates to:
  /// **'Content (Arabic)'**
  String get contentArabic;

  /// No description provided for @contentEnglish.
  ///
  /// In en, this message translates to:
  /// **'Content (English)'**
  String get contentEnglish;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @createViolation.
  ///
  /// In en, this message translates to:
  /// **'Create Violation'**
  String get createViolation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @citizenName.
  ///
  /// In en, this message translates to:
  /// **'Citizen Name'**
  String get citizenName;

  /// No description provided for @enterCitizenName.
  ///
  /// In en, this message translates to:
  /// **'Enter citizen name'**
  String get enterCitizenName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocation;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @newViolation.
  ///
  /// In en, this message translates to:
  /// **'New Violation'**
  String get newViolation;

  /// No description provided for @newDepartment.
  ///
  /// In en, this message translates to:
  /// **'New Department'**
  String get newDepartment;

  /// No description provided for @addDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get addDepartment;

  /// No description provided for @departmentName.
  ///
  /// In en, this message translates to:
  /// **'Department Name'**
  String get departmentName;

  /// No description provided for @isFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed Department'**
  String get isFixed;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @notFixed.
  ///
  /// In en, this message translates to:
  /// **'Not Fixed'**
  String get notFixed;

  /// No description provided for @addDepartmentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get addDepartmentButton;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteDepartmentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteDepartmentConfirm(Object name);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get selectDepartment;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get selectRole;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @engineer.
  ///
  /// In en, this message translates to:
  /// **'Engineer'**
  String get engineer;

  /// No description provided for @accountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get accountant;

  /// No description provided for @chooseProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Choose profile image'**
  String get chooseProfileImage;

  /// No description provided for @changeProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Change profile image'**
  String get changeProfileImage;

  /// No description provided for @removeProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Remove profile image'**
  String get removeProfileImage;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @nameAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic Name'**
  String get nameAr;

  /// No description provided for @nameEn.
  ///
  /// In en, this message translates to:
  /// **'English Name'**
  String get nameEn;

  /// No description provided for @pleaseSelectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Please select department'**
  String get pleaseSelectDepartment;

  /// No description provided for @allDepartments.
  ///
  /// In en, this message translates to:
  /// **'All Departments'**
  String get allDepartments;

  /// No description provided for @editViolation.
  ///
  /// In en, this message translates to:
  /// **'Edit Violation'**
  String get editViolation;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @departmentId.
  ///
  /// In en, this message translates to:
  /// **'Department ID'**
  String get departmentId;

  /// No description provided for @enterDepartmentId.
  ///
  /// In en, this message translates to:
  /// **'Example: 1'**
  String get enterDepartmentId;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @invalidDepartmentId.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid department ID'**
  String get invalidDepartmentId;

  /// No description provided for @missingViolationId.
  ///
  /// In en, this message translates to:
  /// **'Missing violation ID'**
  String get missingViolationId;

  /// No description provided for @characters3To25.
  ///
  /// In en, this message translates to:
  /// **'Must be 3 to 25 characters'**
  String get characters3To25;

  /// No description provided for @violationSaved.
  ///
  /// In en, this message translates to:
  /// **'Violation saved successfully'**
  String get violationSaved;

  /// No description provided for @violationCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Fill the violation details below'**
  String get violationCreateHint;

  /// No description provided for @violationEditHint.
  ///
  /// In en, this message translates to:
  /// **'Update the violation details below'**
  String get violationEditHint;

  /// No description provided for @editAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get editAnnouncement;

  /// No description provided for @announcementSaved.
  ///
  /// In en, this message translates to:
  /// **'Announcement saved successfully'**
  String get announcementSaved;

  /// No description provided for @announcementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Announcement deleted successfully'**
  String get announcementDeleted;

  /// No description provided for @announcementCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Write a clear announcement for citizens'**
  String get announcementCreateHint;

  /// No description provided for @announcementEditHint.
  ///
  /// In en, this message translates to:
  /// **'Update the announcement information'**
  String get announcementEditHint;

  /// No description provided for @deleteAnnouncementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this announcement?'**
  String get deleteAnnouncementConfirm;

  /// No description provided for @missingAnnouncementId.
  ///
  /// In en, this message translates to:
  /// **'Missing announcement ID'**
  String get missingAnnouncementId;

  /// No description provided for @titleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters'**
  String get titleMinLength;

  /// No description provided for @contentMinLength.
  ///
  /// In en, this message translates to:
  /// **'Content must be at least 5 characters'**
  String get contentMinLength;

  /// No description provided for @announcementTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement title'**
  String get announcementTitle;

  /// No description provided for @announcementContent.
  ///
  /// In en, this message translates to:
  /// **'Announcement content'**
  String get announcementContent;

  /// No description provided for @enterAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter announcement title'**
  String get enterAnnouncementTitle;

  /// No description provided for @enterAnnouncementContent.
  ///
  /// In en, this message translates to:
  /// **'Enter announcement content'**
  String get enterAnnouncementContent;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @noAnnouncementsHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first announcement to notify citizens.'**
  String get noAnnouncementsHint;

  /// No description provided for @shownOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Shown {shown} of {total}'**
  String shownOfTotal(Object shown, Object total);

  /// No description provided for @moduleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This module is not available yet'**
  String get moduleUnavailable;

  /// No description provided for @openModuleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open module'**
  String get openModuleFailed;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Municipality administration panel'**
  String get adminDashboardSubtitle;

  /// No description provided for @departmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Department created successfully'**
  String get departmentCreated;

  /// No description provided for @departmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Department updated successfully'**
  String get departmentUpdated;

  /// No description provided for @departmentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Department deleted successfully'**
  String get departmentDeleted;

  /// No description provided for @editDepartment.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get editDepartment;

  /// No description provided for @manageDepartments.
  ///
  /// In en, this message translates to:
  /// **'Manage municipality departments'**
  String get manageDepartments;

  /// No description provided for @noDepartmentsHint.
  ///
  /// In en, this message translates to:
  /// **'No departments available yet.'**
  String get noDepartmentsHint;

  /// No description provided for @manageServices.
  ///
  /// In en, this message translates to:
  /// **'Manage municipality services'**
  String get manageServices;

  /// No description provided for @noServicesHint.
  ///
  /// In en, this message translates to:
  /// **'No services available yet.'**
  String get noServicesHint;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteServiceConfirm(Object name);

  /// No description provided for @serviceCreated.
  ///
  /// In en, this message translates to:
  /// **'Service created successfully'**
  String get serviceCreated;

  /// No description provided for @serviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get serviceUpdated;

  /// No description provided for @serviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get serviceDeleted;

  /// No description provided for @deleteRequested.
  ///
  /// In en, this message translates to:
  /// **'Delete request sent'**
  String get deleteRequested;

  /// No description provided for @municipalityId.
  ///
  /// In en, this message translates to:
  /// **'Municipality ID'**
  String get municipalityId;

  /// No description provided for @descriptionAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic Description'**
  String get descriptionAr;

  /// No description provided for @descriptionEn.
  ///
  /// In en, this message translates to:
  /// **'English Description'**
  String get descriptionEn;

  /// No description provided for @slaDays.
  ///
  /// In en, this message translates to:
  /// **'SLA Days'**
  String get slaDays;

  /// No description provided for @hasFees.
  ///
  /// In en, this message translates to:
  /// **'Has Fees'**
  String get hasFees;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @loadingDepartments.
  ///
  /// In en, this message translates to:
  /// **'Loading departments...'**
  String get loadingDepartments;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// No description provided for @manageEmployees.
  ///
  /// In en, this message translates to:
  /// **'Manage municipality employees'**
  String get manageEmployees;

  /// No description provided for @noEmployeesHint.
  ///
  /// In en, this message translates to:
  /// **'No employees available yet.'**
  String get noEmployeesHint;

  /// No description provided for @employeeCreated.
  ///
  /// In en, this message translates to:
  /// **'Employee created successfully'**
  String get employeeCreated;

  /// No description provided for @noRolesHint.
  ///
  /// In en, this message translates to:
  /// **'No roles available yet.'**
  String get noRolesHint;

  /// No description provided for @inboxComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Inbox is not available yet'**
  String get inboxComingSoon;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @municipalityInfo.
  ///
  /// In en, this message translates to:
  /// **'Municipality Info'**
  String get municipalityInfo;

  /// No description provided for @municipalityStatus.
  ///
  /// In en, this message translates to:
  /// **'Municipality Status'**
  String get municipalityStatus;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @adminProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner Profile'**
  String get adminProfileTitle;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get accountInformation;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @notifyItemUpdates.
  ///
  /// In en, this message translates to:
  /// **'Item update notifications'**
  String get notifyItemUpdates;

  /// No description provided for @notifyUserFeedback.
  ///
  /// In en, this message translates to:
  /// **'User feedback notifications'**
  String get notifyUserFeedback;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @leaveBlankToKeepPassword.
  ///
  /// In en, this message translates to:
  /// **'Leave password fields empty to keep the current password.'**
  String get leaveBlankToKeepPassword;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile details'**
  String get profileDetails;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get updatedAt;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccess;

  /// No description provided for @violationTitle.
  ///
  /// In en, this message translates to:
  /// **'Violation Title'**
  String get violationTitle;

  /// No description provided for @enterViolationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter violation title (e.g. Illegal Parking)'**
  String get enterViolationTitle;

  /// No description provided for @violationType.
  ///
  /// In en, this message translates to:
  /// **'Violation Type'**
  String get violationType;

  /// No description provided for @selectViolationType.
  ///
  /// In en, this message translates to:
  /// **'Please select violation type'**
  String get selectViolationType;

  /// No description provided for @identityNumber.
  ///
  /// In en, this message translates to:
  /// **'Identity Number'**
  String get identityNumber;

  /// No description provided for @enterIdentityNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter citizen identity number'**
  String get enterIdentityNumber;

  /// No description provided for @carPlate.
  ///
  /// In en, this message translates to:
  /// **'Car Plate'**
  String get carPlate;

  /// No description provided for @enterCarPlate.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle plate number'**
  String get enterCarPlate;

  /// No description provided for @identifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least Identity Number or Car Plate'**
  String get identifierRequired;

  /// No description provided for @nameRequiresIdentifier.
  ///
  /// In en, this message translates to:
  /// **'If a name is provided, you must also add Identity Number or Car Plate'**
  String get nameRequiresIdentifier;

  /// No description provided for @carPlateRequired.
  ///
  /// In en, this message translates to:
  /// **'Car plate is required for traffic violations'**
  String get carPlateRequired;

  /// No description provided for @violationDetails.
  ///
  /// In en, this message translates to:
  /// **'Violation Details'**
  String get violationDetails;

  /// No description provided for @citizenInfo.
  ///
  /// In en, this message translates to:
  /// **'Citizen Information'**
  String get citizenInfo;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// No description provided for @businessOwnerInfo.
  ///
  /// In en, this message translates to:
  /// **'Business / Owner Information'**
  String get businessOwnerInfo;

  /// No description provided for @businessOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Business / Owner Name'**
  String get businessOwnerName;

  /// No description provided for @paymentAndAssignment.
  ///
  /// In en, this message translates to:
  /// **'Payment & Assignment'**
  String get paymentAndAssignment;

  /// No description provided for @trafficIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'Car plate is required for traffic violations. Identity number is optional.'**
  String get trafficIdentifierHint;

  /// No description provided for @generalIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'At least one of: name, identity number, or car plate must be provided.'**
  String get generalIdentifierHint;

  /// No description provided for @selectTypeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a violation type first to see relevant fields.'**
  String get selectTypeFirst;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed. Please try again.'**
  String get deleteFailed;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDocumentsMissing.
  ///
  /// In en, this message translates to:
  /// **'Documents missing'**
  String get statusDocumentsMissing;

  /// No description provided for @statusTaxPaid.
  ///
  /// In en, this message translates to:
  /// **'Tax Paid'**
  String get statusTaxPaid;

  /// No description provided for @statusTaxRejected.
  ///
  /// In en, this message translates to:
  /// **'Tax Rejected'**
  String get statusTaxRejected;

  /// No description provided for @requestSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted!'**
  String get requestSubmittedTitle;

  /// No description provided for @requestSubmittedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your request is being reviewed by the municipality'**
  String get requestSubmittedMsg;

  /// No description provided for @browseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse Services'**
  String get browseServices;

  /// No description provided for @startRequest.
  ///
  /// In en, this message translates to:
  /// **'Start a Request'**
  String get startRequest;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load. Please try again.'**
  String get loadFailed;

  /// No description provided for @uploadingFiles.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingFiles;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseDocument.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF or Document'**
  String get chooseDocument;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @municipalityName.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get municipalityName;

  /// No description provided for @violationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get violationTypeLabel;

  /// No description provided for @inboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests Inbox'**
  String get inboxTitle;

  /// No description provided for @networkErrorBanner.
  ///
  /// In en, this message translates to:
  /// **'Some data failed to load. Pull down to retry.'**
  String get networkErrorBanner;

  /// No description provided for @catGeneralServices.
  ///
  /// In en, this message translates to:
  /// **'General Services'**
  String get catGeneralServices;

  /// No description provided for @catCommercialServices.
  ///
  /// In en, this message translates to:
  /// **'Commercial Services'**
  String get catCommercialServices;

  /// No description provided for @catRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get catRealEstate;

  /// No description provided for @catEngineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering Services'**
  String get catEngineering;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @requestsCount.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsCount;

  /// No description provided for @requestInformation.
  ///
  /// In en, this message translates to:
  /// **'Request information'**
  String get requestInformation;

  /// No description provided for @municipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get municipality;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get requestId;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @invalidRequestId.
  ///
  /// In en, this message translates to:
  /// **'Invalid request ID.'**
  String get invalidRequestId;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @requestClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This request is {status}. No more actions are available.'**
  String requestClosedMessage(Object status);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @manageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage staff users and role assignment'**
  String get manageStaff;

  /// No description provided for @assignStaff.
  ///
  /// In en, this message translates to:
  /// **'Assign staff'**
  String get assignStaff;

  /// No description provided for @searchUserByEmail.
  ///
  /// In en, this message translates to:
  /// **'Search user by email'**
  String get searchUserByEmail;

  /// No description provided for @enterUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter user email'**
  String get enterUserEmail;

  /// No description provided for @searchUser.
  ///
  /// In en, this message translates to:
  /// **'Search user'**
  String get searchUser;

  /// No description provided for @userFound.
  ///
  /// In en, this message translates to:
  /// **'User found'**
  String get userFound;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @userNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'No user exists with this email in this app. Invite by email will be added next.'**
  String get userNotFoundDescription;

  /// No description provided for @alreadyAssigned.
  ///
  /// In en, this message translates to:
  /// **'Already assigned'**
  String get alreadyAssigned;

  /// No description provided for @assignAsStaff.
  ///
  /// In en, this message translates to:
  /// **'Assign as staff'**
  String get assignAsStaff;

  /// No description provided for @removeStaffRole.
  ///
  /// In en, this message translates to:
  /// **'Remove staff role'**
  String get removeStaffRole;

  /// No description provided for @confirmRemoveStaffRole.
  ///
  /// In en, this message translates to:
  /// **'Remove staff role from {name}?'**
  String confirmRemoveStaffRole(Object name);

  /// No description provided for @staffAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Staff assigned successfully.'**
  String get staffAssignedSuccessfully;

  /// No description provided for @staffRoleRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Staff role removed successfully.'**
  String get staffRoleRemovedSuccessfully;

  /// No description provided for @noStaffHint.
  ///
  /// In en, this message translates to:
  /// **'No staff users found yet.'**
  String get noStaffHint;

  /// No description provided for @currentRole.
  ///
  /// In en, this message translates to:
  /// **'Current role'**
  String get currentRole;

  /// No description provided for @targetRole.
  ///
  /// In en, this message translates to:
  /// **'Target role'**
  String get targetRole;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @sendRegistrationInvite.
  ///
  /// In en, this message translates to:
  /// **'Send registration invite'**
  String get sendRegistrationInvite;

  /// No description provided for @inviteStaffToRegister.
  ///
  /// In en, this message translates to:
  /// **'Invite staff to register'**
  String get inviteStaffToRegister;

  /// No description provided for @inviteStaffDescription.
  ///
  /// In en, this message translates to:
  /// **'This user is not registered yet. Send an email asking them to register as a citizen first.'**
  String get inviteStaffDescription;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @staffInviteSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Registration invite email sent successfully.'**
  String get staffInviteSentSuccessfully;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get fullNameRequired;

  /// No description provided for @workflowTask.
  ///
  /// In en, this message translates to:
  /// **'Workflow Task'**
  String get workflowTask;

  /// No description provided for @taskId.
  ///
  /// In en, this message translates to:
  /// **'Task ID'**
  String get taskId;

  /// No description provided for @taskState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get taskState;

  /// No description provided for @taskAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get taskAssignee;

  /// No description provided for @taskCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get taskCandidates;

  /// No description provided for @taskCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get taskCreated;

  /// No description provided for @openForm.
  ///
  /// In en, this message translates to:
  /// **'Open Form'**
  String get openForm;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @unassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get unassign;

  /// No description provided for @workflowTasks.
  ///
  /// In en, this message translates to:
  /// **'Workflow Tasks'**
  String get workflowTasks;

  /// No description provided for @loadTasks.
  ///
  /// In en, this message translates to:
  /// **'Load Tasks'**
  String get loadTasks;

  /// No description provided for @noWorkflowStarted.
  ///
  /// In en, this message translates to:
  /// **'No workflow has started for this request.'**
  String get noWorkflowStarted;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found for this request.'**
  String get noTasksFound;

  /// No description provided for @tasksLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Tasks loaded successfully.'**
  String get tasksLoadedSuccessfully;

  /// No description provided for @failedToLoadTasks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks.'**
  String get failedToLoadTasks;

  /// No description provided for @taskForm.
  ///
  /// In en, this message translates to:
  /// **'Task Form'**
  String get taskForm;

  /// No description provided for @loadingForm.
  ///
  /// In en, this message translates to:
  /// **'Loading form...'**
  String get loadingForm;

  /// No description provided for @noFormFound.
  ///
  /// In en, this message translates to:
  /// **'No form found for this task.'**
  String get noFormFound;

  /// No description provided for @rawFormJson.
  ///
  /// In en, this message translates to:
  /// **'Raw Form JSON'**
  String get rawFormJson;

  /// No description provided for @submitTaskForm.
  ///
  /// In en, this message translates to:
  /// **'Submit Form'**
  String get submitTaskForm;

  /// No description provided for @formSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Form submitted successfully.'**
  String get formSubmittedSuccessfully;

  /// No description provided for @unsupportedFieldType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported field type'**
  String get unsupportedFieldType;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// **'Certificate'**
  String get certificate;

  /// **'This task has already been completed.'**
  String get taskAlreadyCompleted;

  /// **'View Certificate'**
  String get viewCertificate;

  /// **'Generating certificate...'**
  String get generatingCertificate;

  /// **'This may take a moment'**
  String get certificateTakingTime;

  /// **'Certificate is not ready yet'**
  String get certificateNotReady;

  /// **'Certificate ready'**
  String get certificateReady;

  /// **'PDF Document'**
  String get pdfDocument;

  /// **'Open PDF'**
  String get openPdf;

  /// **'Download Again'**
  String get downloadAgain;

  /// **'Download & Open'**
  String get downloadAndOpen;

  /// **'Back to Tasks'**
  String get backToTasks;

  /// **'Done'**
  String get done;

  /// **'Could not open the file'**
  String get couldNotOpenFile;

  /// **'No input required for this task'**
  String get noInputRequired;

  /// **'Fill Required Fields'**
  String get fillRequiredFields;

  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// **'Location is required'**
  String get locationRequired;

  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// **'Location services are disabled'**
  String get locationServiceDisabled;

  /// **'Could not get location'**
  String get locationError;

  /// **'GPS Coordinates'**
  String get gpsCoordinatesLabel;

  /// **'Tap to pick location'**
  String get tapToPickLocation;

  /// **'Location selected'**
  String get locationSelected;

  String get manageCertificates;
  String get noCertificates;
  String get noCertificatesHint;
  String get signCertificate;
  String get unsignCertificate;
  String get certificateSigned;
  String get certificateUnsigned;
  String get aiHelp;
  String get aiExplanation;
  String get aiHelpLoading;
  String get aiHelpError;
  String get locationNameLabel;
  String get aiChatTitle;
  String get aiChatHint;
  String get aiChatWelcome;
  String get aiChatClear;
  String get aiChatCleared;
  String get aiChatSending;
  String get aiChatError;
  String get aiChatEmptyHint;
  String get chooseOnMap;
  String get mapPickerTitle;
  String get mapPickerConfirm;
  String get mapPickerHint;
  String get certFilterSigned;
  String get certFilterUnsigned;
  String get newestFirst;
  String get oldestFirst;
  String get dateLabel;
  String get requestIdLabel;
}
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
