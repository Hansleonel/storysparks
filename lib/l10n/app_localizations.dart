import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSettings;

  /// No description provided for @allGenresAvailable.
  ///
  /// In en, this message translates to:
  /// **'All genres available'**
  String get allGenresAvailable;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @alreadyPremiumMessage.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all the premium features of Memory Sparks'**
  String get alreadyPremiumMessage;

  /// No description provided for @alreadyPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re already Premium!'**
  String get alreadyPremiumTitle;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @authorStyleAdvancedConfig.
  ///
  /// In en, this message translates to:
  /// **'✨ Advanced Configuration'**
  String get authorStyleAdvancedConfig;

  /// No description provided for @authorStyleApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Style'**
  String get authorStyleApply;

  /// No description provided for @authorStyleAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author Style'**
  String get authorStyleAuthor;

  /// No description provided for @authorStyleAuthorDescription.
  ///
  /// In en, this message translates to:
  /// **'E.g: Gabriel García Márquez, J.K. Rowling'**
  String get authorStyleAuthorDescription;

  /// No description provided for @authorStyleAuthorHint.
  ///
  /// In en, this message translates to:
  /// **'Write the author\'s name...'**
  String get authorStyleAuthorHint;

  /// No description provided for @authorStyleBook.
  ///
  /// In en, this message translates to:
  /// **'Book Style'**
  String get authorStyleBook;

  /// No description provided for @authorStyleBookDescription.
  ///
  /// In en, this message translates to:
  /// **'E.g: One Hundred Years of Solitude, Harry Potter'**
  String get authorStyleBookDescription;

  /// No description provided for @authorStyleBookHint.
  ///
  /// In en, this message translates to:
  /// **'Write the book\'s name...'**
  String get authorStyleBookHint;

  /// No description provided for @authorStyleCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Style'**
  String get authorStyleCustom;

  /// No description provided for @authorStyleCustomDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the narrative style you want'**
  String get authorStyleCustomDescription;

  /// No description provided for @authorStyleCustomHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: Poetic narrative with lots of description...'**
  String get authorStyleCustomHint;

  /// No description provided for @authorStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Add the style of an author or book to inspire your story'**
  String get authorStyleDescription;

  /// No description provided for @authorStyleRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Style'**
  String get authorStyleRemove;

  /// No description provided for @authorStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Narrative Style'**
  String get authorStyleTitle;

  /// No description provided for @automaticContinuation.
  ///
  /// In en, this message translates to:
  /// **'Automatic Continuation'**
  String get automaticContinuation;

  /// No description provided for @automaticContinuationDescription.
  ///
  /// In en, this message translates to:
  /// **'Let AI continue the story naturally'**
  String get automaticContinuationDescription;

  /// No description provided for @bestValueTag.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValueTag;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @checkingUsername.
  ///
  /// In en, this message translates to:
  /// **'Checking username availability...'**
  String get checkingUsername;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @continueAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Auto Continue'**
  String get continueAutomatically;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @continueStory.
  ///
  /// In en, this message translates to:
  /// **'Continue story'**
  String get continueStory;

  /// No description provided for @continueStoryMode.
  ///
  /// In en, this message translates to:
  /// **'Continue Story Mode'**
  String get continueStoryMode;

  /// No description provided for @continueWithDirection.
  ///
  /// In en, this message translates to:
  /// **'Add Direction'**
  String get continueWithDirection;

  /// No description provided for @continuing.
  ///
  /// In en, this message translates to:
  /// **'Continuing...'**
  String get continuing;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @customContinuation.
  ///
  /// In en, this message translates to:
  /// **'Custom Continuation'**
  String get customContinuation;

  /// No description provided for @customContinuationDescription.
  ///
  /// In en, this message translates to:
  /// **'Write your own direction for the story'**
  String get customContinuationDescription;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this story from your saved stories?'**
  String get deleteConfirmation;

  /// No description provided for @deleteFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Delete from saved'**
  String get deleteFromSaved;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @earlyAccessToNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'Early access to new features'**
  String get earlyAccessToNewFeatures;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHelperText.
  ///
  /// In en, this message translates to:
  /// **'Example: user@domain.com'**
  String get emailHelperText;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Exit without saving?'**
  String get exitWithoutSaving;

  /// No description provided for @exitWithoutSavingMessage.
  ///
  /// In en, this message translates to:
  /// **'This story is unique and will be lost if you exit without saving it. Are you sure you want to exit?'**
  String get exitWithoutSavingMessage;

  /// No description provided for @fillInformation.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your information to create an account'**
  String get fillInformation;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @generateStory.
  ///
  /// In en, this message translates to:
  /// **'Generate story'**
  String get generateStory;

  /// No description provided for @generatedStory.
  ///
  /// In en, this message translates to:
  /// **'Generated Story'**
  String get generatedStory;

  /// No description provided for @generatingStory.
  ///
  /// In en, this message translates to:
  /// **'Generating story, please wait...'**
  String get generatingStory;

  /// No description provided for @generatingStoryMessage1.
  ///
  /// In en, this message translates to:
  /// **'Weaving the threads of your memory'**
  String get generatingStoryMessage1;

  /// No description provided for @generatingStoryMessage2.
  ///
  /// In en, this message translates to:
  /// **'Bringing your words to life'**
  String get generatingStoryMessage2;

  /// No description provided for @generatingStoryMessage3.
  ///
  /// In en, this message translates to:
  /// **'Creating narrative magic'**
  String get generatingStoryMessage3;

  /// No description provided for @generatingStoryMessage4.
  ///
  /// In en, this message translates to:
  /// **'Polishing every detail'**
  String get generatingStoryMessage4;

  /// No description provided for @generatingStoryMessage5.
  ///
  /// In en, this message translates to:
  /// **'Adding the final touch'**
  String get generatingStoryMessage5;

  /// No description provided for @genreAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genreAdventure;

  /// No description provided for @genreFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get genreFamily;

  /// No description provided for @genreHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get genreHappy;

  /// No description provided for @genreNostalgic.
  ///
  /// In en, this message translates to:
  /// **'Nostalgic'**
  String get genreNostalgic;

  /// No description provided for @genreRomantic.
  ///
  /// In en, this message translates to:
  /// **'Romantic'**
  String get genreRomantic;

  /// No description provided for @genreSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get genreSad;

  /// No description provided for @genreTitle.
  ///
  /// In en, this message translates to:
  /// **'The memory is...'**
  String get genreTitle;

  /// No description provided for @getPro.
  ///
  /// In en, this message translates to:
  /// **'Get Pro'**
  String get getPro;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @loadingSubscriptionPlans.
  ///
  /// In en, this message translates to:
  /// **'Loading subscription plans...'**
  String get loadingSubscriptionPlans;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email & password to sign in.'**
  String get loginDescription;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'memory'**
  String get memory;

  /// No description provided for @memoryImage.
  ///
  /// In en, this message translates to:
  /// **'Memory image'**
  String get memoryImage;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @newStories.
  ///
  /// In en, this message translates to:
  /// **'New Stories 🎁'**
  String get newStories;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newTag;

  /// No description provided for @noAdsOrInterruptions.
  ///
  /// In en, this message translates to:
  /// **'No ads or interruptions'**
  String get noAdsOrInterruptions;

  /// No description provided for @noProfileFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get noProfileFound;

  /// No description provided for @noStories.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStories;

  /// No description provided for @noStoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStoriesYet;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @optionalPhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'You can add a photo to your memory, but it\'s not mandatory.'**
  String get optionalPhotoMessage;

  /// No description provided for @originalMemory.
  ///
  /// In en, this message translates to:
  /// **'Original Memory'**
  String get originalMemory;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHelperText.
  ///
  /// In en, this message translates to:
  /// **'• At least 8 characters\n• At least one uppercase letter\n• At least one lowercase letter\n• At least one number\n• At least one special character'**
  String get passwordHelperText;

  /// No description provided for @passwordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordLowercase;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNumber;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordSpecial;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercase;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @paywallAnnualDescription.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paywallAnnualDescription;

  /// No description provided for @paywallAnnualPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paywallAnnualPlan;

  /// No description provided for @paywallBenefitAiNarration.
  ///
  /// In en, this message translates to:
  /// **'AI Story Narration & Voice Cloning to narrate your stories.'**
  String get paywallBenefitAiNarration;

  /// No description provided for @paywallBenefitEarlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Early access to new features'**
  String get paywallBenefitEarlyAccess;

  /// No description provided for @paywallBenefitNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads or interruptions'**
  String get paywallBenefitNoAds;

  /// No description provided for @paywallBenefitUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited and personalized stories'**
  String get paywallBenefitUnlimited;

  /// No description provided for @paywallBestValueTag.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paywallBestValueTag;

  /// No description provided for @paywallGetProButton.
  ///
  /// In en, this message translates to:
  /// **'Get PRO access'**
  String get paywallGetProButton;

  /// No description provided for @paywallMonthlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Most popular plan'**
  String get paywallMonthlyDescription;

  /// No description provided for @paywallMonthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthlyPlan;

  /// No description provided for @paywallNewFeatureTag.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get paywallNewFeatureTag;

  /// No description provided for @paywallPopularTag.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get paywallPopularTag;

  /// No description provided for @paywallSavingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String paywallSavingsLabel(int percent);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock your memories without limits with MemorySparks PRO'**
  String get paywallTitle;

  /// No description provided for @paywallTrialText.
  ///
  /// In en, this message translates to:
  /// **'Try free for 3 days, cancel anytime'**
  String get paywallTrialText;

  /// No description provided for @paywallWeeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'For those who want to try intensively in the short term'**
  String get paywallWeeklyDescription;

  /// No description provided for @paywallWeeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get paywallWeeklyPlan;

  /// No description provided for @pdfGeneratedWith.
  ///
  /// In en, this message translates to:
  /// **'Generated with love by Memory Sparks'**
  String get pdfGeneratedWith;

  /// No description provided for @pdfPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {pageNumber}'**
  String pdfPageNumber(int pageNumber);

  /// No description provided for @pdfPersonalStory.
  ///
  /// In en, this message translates to:
  /// **'A personal story'**
  String get pdfPersonalStory;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @popularStories.
  ///
  /// In en, this message translates to:
  /// **'Popular Stories 🔥'**
  String get popularStories;

  /// No description provided for @popularTag.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popularTag;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You now have access to all premium features of Memory Sparks.'**
  String get premiumAccessMessage;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get profileUpdateError;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get searchSettings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGallery;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareContinues.
  ///
  /// In en, this message translates to:
  /// **'[...continues]'**
  String get shareContinues;

  /// No description provided for @shareDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get shareDetails;

  /// No description provided for @shareDownloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download MemorySparks to create your own stories'**
  String get shareDownloadApp;

  /// No description provided for @shareGeneratedWith.
  ///
  /// In en, this message translates to:
  /// **'Story generated with MemorySparks'**
  String get shareGeneratedWith;

  /// No description provided for @shareGeneratedWithAI.
  ///
  /// In en, this message translates to:
  /// **'Story generated with artificial intelligence'**
  String get shareGeneratedWithAI;

  /// No description provided for @shareGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get shareGenre;

  /// No description provided for @shareMemoryHint.
  ///
  /// In en, this message translates to:
  /// **'Share a special memory or thought that left a mark on your life. Describe it in detail, without fearing the sadness, and you\'ll see the magic of bringing it back to life.'**
  String get shareMemoryHint;

  /// No description provided for @shareRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get shareRating;

  /// No description provided for @shareStory.
  ///
  /// In en, this message translates to:
  /// **'Share Story'**
  String get shareStory;

  /// No description provided for @shareStoryError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing story'**
  String get shareStoryError;

  /// No description provided for @shareStoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to share \"{title}\"'**
  String shareStoryMessage(String title);

  /// No description provided for @shareStorySimple.
  ///
  /// In en, this message translates to:
  /// **'Share Simple'**
  String get shareStorySimple;

  /// No description provided for @shareStorySimpleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clean and direct text'**
  String get shareStorySimpleSubtitle;

  /// No description provided for @shareStoryStyled.
  ///
  /// In en, this message translates to:
  /// **'Share as Letter'**
  String get shareStoryStyled;

  /// No description provided for @shareStoryStyledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a beautiful PDF with elegant design'**
  String get shareStoryStyledSubtitle;

  /// No description provided for @shareStorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Story shared successfully'**
  String get shareStorySuccess;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get startReading;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @story.
  ///
  /// In en, this message translates to:
  /// **'story'**
  String get story;

  /// No description provided for @storyContinueError.
  ///
  /// In en, this message translates to:
  /// **'Could not continue the story. Please try again later.'**
  String get storyContinueError;

  /// No description provided for @storyContinuedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Story continued successfully'**
  String get storyContinuedSuccess;

  /// No description provided for @storyDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting story'**
  String get storyDeleteError;

  /// No description provided for @storyDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Story successfully deleted'**
  String get storyDeletedSuccess;

  /// No description provided for @storySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Story saved successfully'**
  String get storySavedSuccess;

  /// No description provided for @subscriptionTermsText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our terms and conditions. Subscription renews automatically.'**
  String get subscriptionTermsText;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @theProtagonistWillBe.
  ///
  /// In en, this message translates to:
  /// **'The protagonist will be...'**
  String get theProtagonistWillBe;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @unlimitedPersonalizedStories.
  ///
  /// In en, this message translates to:
  /// **'Unlimited personalized stories'**
  String get unlimitedPersonalizedStories;

  /// No description provided for @unlockMemorySparks.
  ///
  /// In en, this message translates to:
  /// **'Unlock Memory Sparks'**
  String get unlockMemorySparks;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username is available'**
  String get usernameAvailable;

  /// No description provided for @usernameExists.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get usernameExists;

  /// No description provided for @usernameHelperText.
  ///
  /// In en, this message translates to:
  /// **'Between 3 and 30 characters, only letters, numbers and underscores'**
  String get usernameHelperText;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers and underscores'**
  String get usernameInvalidChars;

  /// No description provided for @usernameLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be between 3 and 30 characters'**
  String get usernameLength;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @usernameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Username is not available'**
  String get usernameUnavailable;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week ago} other{{weeks} weeks ago}}'**
  String weeksAgo(int weeks);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcomeBack;

  /// No description provided for @welcomeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get welcomeToPremium;

  /// No description provided for @writeYourDirection.
  ///
  /// In en, this message translates to:
  /// **'Write how you want the story to continue...'**
  String get writeYourDirection;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @yourStory.
  ///
  /// In en, this message translates to:
  /// **'Your Story'**
  String get yourStory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
