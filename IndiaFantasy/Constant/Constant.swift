//
//  SplashVC.swift
//  Lifferent
//
//  Created by sumit sharma on 22/01/21.
//

import UIKit

var currentAppLanguage : appLanguage?

public enum appLanguage: String {
    case en        = "en"
}

public struct Constants {

    static let kMobileNumberLength   = 10
    static let kPasswordLength   = 16

    static let kAmountLength   = 8
    static let kCoupenLength   = 15

    static let kSecurityPinLength   = 4
    static let kCommonFieldLength   = 80
    static let kDescriptionFieldLength   = 200
    
    //Necessary Font
    static let kRegularFont          = "Montserrat-Regular"
    static let kBoldFont             = "Montserrat-Bold"
    static let kMediumFont           = "Montserrat-SemiBold"
    static let kSemiBoldFont         = "Montserrat-SemiBold"

    static let kUIDisplayRegularFont = "SFUIDisplay-Regular"
    static let kLightFont            = "SFUIDisplay-Light"
    static let kPaymentEnviornment   = "TEST"
    
    //Necessary Macros
    static let kAppDelegate          = UIApplication.shared.delegate as! AppDelegate
    static let kUserDefaults         = UserDefaults.standard
    
    static let kAppDisplayName       = "India’s fantasy"
    
    static let kCricketFantasy       = "cricket"
    static let kCricketFantasyURL    = "fantasy"

    static let KDeviceSystemVersion  = UIDevice.current.systemVersion
    
    static let kAppVersion           = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    static let KLocationMessage      = "Please give permission for location access in app setting."
    static let kScreenWidth          = UIScreen.main.bounds.width
    static let kScreenHeight         = UIScreen.main.bounds.height
    static let kGoogleAPIKey         = "" // [Project-IOS]
    static let kFirebaseKey          = "" // [Project-IOS]
    static let kShareSecretCode      = "6240b35068f640cfbd7e1b9341826618"

    static let kAPIVersion           = "1.0"
    static let kAuthAPIKey           = ""
    static let kDeviceType           = "ios"
    static let KCurrency             = "₹"//"₦"
    static let KQuantity             = " gm"
    static let KDistance             = " Km"

    static let kWelcomStoryboard     = UIStoryboard(name: "Welcome", bundle: nil)
    static let KLoginSignupStoryboard = UIStoryboard(name: "LoginSignup", bundle: nil)
    static let KDashboardStoryboard  = UIStoryboard(name: "Dashboard", bundle: nil)
    static let KContestStoryboard    = UIStoryboard(name: "Contest", bundle: nil)
    static let KScanCodeStoryboard   = UIStoryboard(name: "ScanCode", bundle: nil)
    static let KSupportStoryboard    = UIStoryboard(name: "Support", bundle: nil)
    static let KAccountStoryboard    = UIStoryboard(name: "Account", bundle: nil)
    static let KSideMenuStoryboard   = UIStoryboard(name: "SideMenu", bundle: nil)
    static let KTabbarStoryboard     = UIStoryboard(name: "Tabbar", bundle: nil)
    static let KHelpStoryboard       = UIStoryboard(name: "Help", bundle: nil)
    static let KMoreStoryboard       = UIStoryboard(name: "More", bundle: nil)
    static let KSeasonsStoryboard    = UIStoryboard(name: "Seasons", bundle: nil)
    static let KMoneyPoolStoryboard       = UIStoryboard(name: "MoneyPool", bundle: nil)
    
    static let kCompleted            = "completed"
    static let kUpcoming             = "upcoming"

    //static let kDeviceId           = Constants.kUserDefaults.object(forKey: "device_token") as? String ?? "cjKL_gqBQ9aN9S36EfB2IP"
    static let kDeviceId             = Constants.kAppDelegate.deviceTokenString
    
    static let kTextFieldColor       = UIColor(red: 235, green: 235, blue: 235)
    static let kAppInfo = ["device_type": kDeviceType,
                           "device_model": UIDevice.init().name,
                           "os_version": KDeviceSystemVersion]
    
    public typealias CompletionHandler = (_ result : Any?, _ error: Error?) -> Void
    public typealias CompletionHandlerProgress = (_ bytes : Int?) -> Void
    
    static let kNoImage              = UIImage(named: "no_image_ic")
    static let kProfileplaceholder   = UIImage(named: "user_placeholder")
    static let kNoImageUser          = UIImage(named: "player_ic")
    static let kNoImagePromo         = UIImage(named: "ic_logo")
    static let kNoImagePanCard       = UIImage(named: "pan-card-placeholder")
    static let kNoImageCVC           = UIImage(named: "cvc-placeholder")
    static let kSoccerPlayground     = UIImage(named: "groundbg-soccer")
    static let kNoPlayer             = UIImage(named: "player_ic")

    
    static let kCaptainSelected      = UIImage(named: "captain")
    static let kViceCaptainSelected  = UIImage(named: "vice-captain")

    static let kAnnouncedImage       = UIImage(named: "Announced")
    static let kNotAnnouncedImage    = UIImage(named: "NotAnnounced")
    
    static let kSortUp               = UIImage(named: "arrow-up-white")
    static let kSortDown             = UIImage(named: "arrow-down-white")

    
    static let kSortUpHighLight      = UIImage(named: "IconSortUp")
    static let kSortDownHighLight    = UIImage(named: "IconSortDown")
    
    
    static let kArrowDown            = UIImage(named: "arrow-light-down")
    static let kArrowUp              = UIImage(named: "arrow-light-up")

    static let kWinningImage         = UIImage(named: "icon-winning-trophy")
    static let kBattingImage         = UIImage(named: "bat-icon")
    static let kBowlingImage         = UIImage(named: "bowl-icon")

    static let kMaleAvatar           = UIImage(named: "male-avatar")
    static let kFemaleAvatar         = UIImage(named: "female-avatar")

    static let kPhoneVerify                         = "phone_verify"
    static let kEmailVerify                         = "email_verify"
    static let kRegister                            = "register"
    static let kForgotPassword                      = "forgot_password"
    
    static let kQatarIDFront                        = "QatarIDFront"
    static let kQatarIDBack                         = "QatarIDBack"
    static let kPassportFront                       = "PassportFront"
    static let kPassportBack                        = "PassportBack"
    
    static let kContactUsSlug                        = "contact-us"
    static let kFAQSlug                              = "faq"
    static let kAboutUsSlug                          = "about-us"
    static let kTermsAndConditionsSlug               = "terms-and-conditions"
    static let kPrivacyPolicySlug                    = "privacy-policy"
    
    
    static let kRouteLogin                            = "Login"
    static let kRouteSignUp                           = "Signup"
    static let kProfileImage                          = "profile_pic"

    static let kClearNotification                     = "clearNotification"
    static let kReadNotification                      = "readNotification"

    static let kRefreshLineUp                         = "refreshLineup"
    static let kNavigateToMatchList                   = "matchList"
    static let kRefreshAccountDetails                 = "refreshAccountDetails"

    static let kAppliedDebuffPopup                    = "appliedDebuff"

    
    static let kTeamCreation                          = "TeamCreatedNotification"
    static let kUpdateTopNavigation                   = "UpdateTopNavigation"
    static let kRefreshTopNavigation                  = "refreshTopNavigation"
    static let kMoveToAddCash                         = "AddCashNavigation"
    static let kMoveToContest                         = "AddContestNavigation"
    static let kLeagueTeamCreation                    = "LagueTeamCreatedNotification"
    static let kMoveToMyTeam                          = "MyTeamNavigation"
    static let kMoveToAllContest                      = "AllContestNavigation"
    static let kMoveToLeagueStats                     = "LeagueStatsNavigation"
    static let kRefreshBoosterList                    = "RefreshBoosterList"
    static let kSocketConnected                       = "SocketConnected"
    static let kSocketDisconnected                    = "SocketDisConnected"


    static let kBundleID                              = Bundle.main.bundleIdentifier
    static let kAndroiPackageName                     = "com.app.indiasfantasy"
    static let kAppStoreID                            = "6502522163"

}


public struct ConstantMessages {
    
    static let FirstName_Empty                    = "First Name can not be empty!"
    static let LastName_Empty                     = "Last Name can not be empty!"
    static let UserNamr_Empty                     = "User Name can not be empty!"
    static let Email_Empty                        = "Email address can not be empty!"
    static let Amount_Empty                       = "Please enter some amount to add"
    static let Amount_Minimum                     = "Minimum amount must be \(GDP.globalCurrency)1."
    static let Problem_Empty                      = "Please write your problem/issue/concern"
    static let ALERT_CLEAR_Team                   = "Are you sure you want to clear team selection?"

    static let FullName_Empty                     = "Full Name can not be empty!"
    
    static let FirstName_Validation               = "Please enter your valid name!"

    static let UserNameLength_Validation          = "Please enter a valid username with atleast 4 characters!"

    static let ENT_CONFIRM_ACCOUNT_NUMBER         = "Please confirm your account number"
    static let ACCOUNT_NUMBER_MISMATCH            = "Account numbers mismatch! Please verify once again."

    static let Email_Validate                     = "Please input correct email address"
    static let Phone_Empty                        = "Mobile number can not be empty!"
    static let Phone_ValidateLength               = "Please enter 10 digit mobile number!"
    static let Phone_Validate                     = "Please enter valid mobile number"
    static let termCondition                      = "Please accept our terms & conditions."
    static let AgeValidation                      = "You must be 18+ to get access to this app."

    static let CurrentPassword_Empty              = "Please enter current password"
    static let Password_Empty                     = "Password field can not be empty!"
    static let ConfirmPassword_Empty              = "Please enter confirm password"
    static let Captcha_Empty                      = "Captcha code can not be empty!"

    static let Password_lengthValidate            = "Password must be between 8 to 16 characters!"
    static let Password_Validate                  = "Password must have a combination of upper case, lower case, at least 1 special character and numbers!"
    
    static let Verification_Option                 = "Please select verification option"

    
    static let Password_Matched                   = "New and confirm password does not match."

    static let ReadTermsConditions                = "Please accept our terms & conditions"
    static let NewPassword_Empty                  = "Please enter new password"
    static let Gender_Empty                       = "Please select gender"
    static let CountryCode_Empty                  = "Please select country code!"
    static let somethingWrong                     = "Something went wrong"
    static let PromoCode_Empty                    = "Please enter coupon code"
    
    static let COPY_SUCCESS                       = "Successfully Copied"

    static let NOTIFICATION_NOT_FOUND             = "Notifications not found."
    static let ALERT_CLEAR_ALL_NOTIFICATION       = "Are you sure you want to clear all notifications?"
    static let Amount_Empty_Withdraw              = "Please enter some Amount"
    static let VALID_AMOUNT                       = "Please enter a valid amount"
    static let ENOUGH_AMOUNT                      = "You don't have enough balance to withdraw"

    static let ENT_BANK_NAME                      = "Please enter bank name"
    static let ENT_ACCOUNT_NUMBER                 = "Please enter your account number"
    static let ENT_ACCOUNT_HOLDERNAME             = "Please enter account holder name"
    static let ENT_BANK_IFSC_CODE                 = "Please enter your bank IFSC Code"
    static let ENT_BANK_PROOF_CARD                = "Please upload a valid bank proof"

    static let VALID_BANK_IFSC_CODE               = "Please enter a valid IFSC Code.The IFSC is an 11-character code with the first four alphabetic characters representing the bank name, and the last six characters (Eg. ABCD0123456) representing the branch"
    static let ENT_BANK_BRANCH_NAME               = "Please enter your bank Branch Name"
    static let SELECT_PAN_IMAGE                   = "Please select PAN Card Image"
    static let SELECT_STATE                       = "Please select your state"
    static let SELECT_COUNTRY                     = "Please select your country of residence"
    static let SELECT_COUNTRY_FIRST               = "Please select your country of residence first"
    static let SELECT_DOB_AS_PEN                  = "Please select your date of birth as per PAN CARD"
    static let SELECT_DOB_                        = "Please select your date of birth"
    static let ENT_VALID_PAN_NUMBER               = "Please enter valid PAN Card number"
    static let ENT_PAN_NUMBER                     = "Please enter PAN Card number"
    static let ENT_Aadhar_NUMBER                  = "Please enter 12 digit Aadhar Card number"
    static let ENT_Aadhar_OTP                     = "Please enter OTP"
    static let ENT_Valid_Aadhar_OTP               = "Please enter 6 digit OTP"
    static let ENT_NAME                           = "Please enter name"
    static let ALREADY_JOINED_THIS_CONTEST        = "You have already joined this contest"
    static let CAN_NOT_JOIN_MORE_TEAMS            = "Maximum Limit Reached! You cannot join with more Teams."
    
    static let CANNOT_JOINED_MORETHANSINGLETEAM   = "You have already joined this contest. This is single team contest and can be joined with one team only."

    
    static let VIEW_OTHER_TEAMS_AFTER_MATCH_STARTED = "You can only view other users' teams after the match has started."
    static let ENT_CONTEST_SIZE                     = "Please enter contest size."
    static let ENT_PRIZE_AMOUNT                     = "Please enter prize amount."
    static let ENT_CONTEST_NAME                     = "Please enter contest name."
    static let ENT_MAX_TEAM                         = "Please enter max team entry per user."
    static let ENT_VALID_MAX_TEAM                   = "Max team entry per user should not be greater than contest size."
    static let ENT_LOSER_PUNISHMENT                 = "Please enter loser punishment message."

    static let ContestFull                          = "Contest Full!"

    static let INCORRECT_WINNING_AMOUNT             = "Incorrect winning amount entered. Please choose a winning amount between 1 to 10,000"
    static let INCORRECT_CONTEST_SIZE_ENT           = "Incorrect contest size entered. Please choose a different contest size."
    static let ENT_FEE_LESS_THAN_5                  = "Entry Fee should not be less than \(GDP.globalCurrency)5"
    static let SELECT_CAPTAIN                       = "Please select captain"
    static let SELECT_VICE_CAPTAIN                  = "Please select vice captain"
    static let SELECT_BOOSTER_PLAYER                = "Please select booster player"
    static let SELECT_OR_CREATE_TEAM_JOIN           = "Please select or create a Team to Join this contest"
    static let ENT_INVITE_CODE                      = "Please enter invite code"
    static let PLAYER_STATS_NOT_AVL                 = "Player stats not available."
    
    static let ENT_EMAIL_FIRST                      = "Please update your email first to Add Money to your wallet"

    static let VERIFY_EMAIL                         = "Are you sure you want to send verification email to verify your email id?"

    static let ENT_OTP                              = "Please enter valid 4 digit OTP sent to your mobile number"
    static let ENT_EMAIL_OTP                        = "Please enter valid 4 digit OTP sent to your email address"

    static let UPDATE_PROFILE_Message               = "Please update your profile first to start your KYC verification."
    static let UPDATE_PROFILE                       = "Update Profile"
    static let VERIFY_KYC                           = "It is mandatory to verify your KYC first to withdraw your winnings. Please verify them first to get withdraw of your winnings."

    static let UPDATE_PROFILE_KYC                       = "It is mandatory to update your profile before you start your KYC"

    static let UPDATE_PROFILE_KYC_Withdraw              = "To use this feature first you need to update your profile and complete your KYC process."

    
    static let LogoutApp                            = "Are you sure you want to logout?"
    static let LeaveRummyApp                        = "Are you sure you want to exit the game?"

    static let keyQuitKyc                           = "Do you really want to quit this journey?"

    static let ENT_VALID_ADDRESS                    = "Please enter valid address"
    static let ENT_CITY_                            = "Please enter city name"
    static let ENT_PIN_CODE_                        = "Please enter pin code"
    static let ENT_VALID_PIN_CODE                   = "Please enter a valid pin code"

    static let ENT_STATE                            = "Please enter your state"
    static let ENT_GST                              = "Please enter your GST Number"

    static let Update_Email                         = "Please update your email first in your profile"

    static let NoUpcomingMatches                    = "You have not joined any contests yet."

    static let NoLiveMatches                        = "You have not joined any contests yet."

    static let NoCompletedMatches                   = "No completed matches found!"

    static let kDisclaimerText                      = "I am 18+ and confirm that I'm not playing from Assam, Odisha, Andhra Pradesh, Telangana, Nagaland, Sikkim, Meghalaya."
    static let kDeleteNotification                      = "Are you sure you want to delete?"
    
    static let kGloryMessage                        = "No Cash Prizes in Practice Contests."
    static let kGloryMessageShort                   = "Glory awaits!"
    static let kGuaranteeMessage                    = "Guaranteed to take place regardless of spots filled"
    
    static let kExtraCashMessage                    = "Extra cash is similar to deposit cash, it can be used to play any game or tournament."
    static let kBonusMessage                        = "Bonus is additional cash provided by India’s fantasy, a part of which can be used to participate in some tournaments (Depends upon Tournament T&C)"
    
    static let kPanVerificationSubmissionMessage   = "Your PAN Card KYC Verification is Successfully Submitted!"
    
    static let kMatchNotStarted                    = "Match deadline is over!"
    static let kPoolExpired                        = "The pool joining deadline is over!"
    static let kRummyNotAvailable                  = "Game is not available at this moment"

    static let kWKSelectionMessage                 = "Please select at least 1 Wicketkeeper!"
    static let kBatSelectionMessage                = "Please select at least 1 Batsman!"
    static let kAllRounderSelectionMessage         = "Please select at least 1 All rounder!"
    static let kBowlerSelectionMessage             = "Please select at least 1 Bowlers!"
    
    static let kBannedLocationMessage              = "Oh! You're from a restricted state. As per state laws, you are not allowed to play on this app."
    static let kEnableLocationServices             = "You have not enabled your location service. Please enable your location services first to play India’s fantasy!"
    
    static let NoLeaguesAvailable                  = "No leagues available!"
    static let NoContestAvailable                  = "No contest found!"
    static let NoTeamAvailable                     = "You haven't created any team yet!"
    static let NoStatsAvailable                    = "No stats found!"
    static let NoPointsFound                       = "See how many points you earned for each match here."
    static let NoTransfersFound                    = "See how many transfers you made for each match here."
    static let UnlimitedTransfers                  = "You have unlimited transfers for the Season Fun."
    static let NoMatchDetailsFound                 = "Match details not found!"
    static let NotFound                            = "No data found!"
    static let UnJoinedTeamFound                   = ""
    static let NoSeriesFound                       = "No series found!"
    static let NoUpcomingMatchesFound              = "No upcoming matches found!"
    static let OTPResend                           = "OTP resent successfully on email and mobile."
    
    static let TransactionError                    = "Transaction Failed!"
    static let PaymentSuccessful                   = "Payment successful"
    static let BoosterAppliedError                 = "You can only select two boosters and one debuff."
    static let SelectBoosterAppliedError           = "Please select booster to apply."
    static let DiscardTeamAlert                    = "Are you sure you want to discard your team?"
    static let CancelBtn                           = "Cancel"
    static let OkBtn                               = "OK"
    static let ContinueBtn                         = "Continue"
    static let ApplyDebuffMessage                  = "Are you sure you want to apply"
    static let NoBoostersFound                     = "You do not have any boosters in your inventory. Visit the shop to purchase boosters."
    static let NoDebuffFound                       = "You do not have any debuffs in your inventory. Visit the shop to purchase debuffs."
    static let SendBoosterGiftAlert                = "Are you sure you want to send"
    
    static let EnableInAppPurchaseAlert            = "Please enable In App Purchase in Settings."
    static let TransactionFailedError              = "Transaction Failed!!"
    static let NoSubscriptionFound                 = "You have not purchased any subscription."
    static let NoHistoryFound                      = "No histroy found!"
    static let NoBoosterHistoryFound               = "Booster history not found!"
    static let NoPaymentMethodsFound               = "Payment methods not found!"
    static let NoBoosterDebuffFound                = "You do not have any boosters/debuffs in your inventory. Visit the shop to purchase boosters/debuffs."
    static let NoEmailAppFound                     = "Can't send mail"
    
    static let Message_Empty                       = "Please enter message"
    static let InternetConnectionOffline           = "The Internet connection appears to be offline."
    static let ReportMessageAlert                  = "Are you sure you want to report?"
    
    static let kSocialEmailNotFound                = "Email ID is not associated with your account. Please sign up by manually entering your email to continue."
    
    static let kDeleteAccountMessage               = "Are you sure you want to delete your account? This will permanently erase your account."
    static let kDeleteAccount                       = "Delete Account"
    static let kDeleteBtn                           = "Delete"
    
    
    static let kEmptyQuantityError                  = "Please select or enter quantity."
    static let kQuantityLimitError                  = "Please enter valid quantity (max 100000)."
    static let kLowWalletBalanceError               = "Your wallet balance is lower than entered amount. Please recharge your wallet."
    static let kQuantityZeroError                   = "Amount should not be less than 1."
    static let kSelectYourAnswer                    = "Please select your answer."
    static let kConfirmJoinPool                     = "Are you sure you want to confirm?"
        
    static let YesBtn                               = "Yes"
    static let ConfirmBtn                           = "Confirm"
}

