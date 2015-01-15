//
//  Constants.h
//  SchoolApp
//
//  Created by RandallRumple on 9/10/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#define FONT_CHARCOAL_CY(s) [UIFont fontWithName:@"Charcoal CY" size:s]

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

//Pickers
typedef enum
{
    zPickerState = 100,
    zPickerCity,
    zPickerSchool,
    zPickerTeacher,
    zPickerGroup,
    zPickerSecondGroup,
    zPickerThirdGroup,
    zPickerFourthGroup,
    zPickerFifthGroup,
    zPickerGrade,
    zPickerPrefix
} PickerType;

//LoginScreen Alertview
typedef enum
{
    zAlertButtonNew = 0,
    zAlertButtonExisting,
    zAlertButtonAdminLogin
} AlertButtons;

#define zAlertEnterEmailOK 1

typedef enum
{
    groupTextbox1 = 1,
    groupTextbox2,
    groupTextbox3,
    groupTextbox4,
    groupTextbox5
}AlertGroupTextFields;

typedef enum
{
    quGetAllParent = 1,
    quGetAllTeachers,
    quGetAllSchools,
    quGetAllCorps,
    quGetAllParentsForOneSchool
}queryTypes;

typedef enum
{
    utParent,
    utTeacher,
    utSecretary,
    utPrincipal,
    utSuperintendent,
    utSales,
    utSuperUser,
    utBetaTester
}userTypes;

typedef enum
{
    zAlertNoUser = 10,
    zAlertEnterEmail,
    zAlertEmailError,
    zAlertAddKidError,
    zAlertVerifyPending,
    zAlertPurchase,
    zAlertInAppTemp,
    zAlertAddMoreError,
    zAlertExistingUserIncorrectPassword,
    zAlertNotifyOnly,
    zAlertForgotPasswordNoEmailEntered,
    zAlertForgotPassword,
    zAlertInAppPurchaseEnabledAlert,
    zAlertApproved,
    zAlertDeleteKid,
    zAlertDeleteKidSuccess,
    zAlertKidAddUpdatedSuccess,
    zAlertConfirmCalendarAdd,
    zAlertStartRestore,
    zAlertProductedRestored,
    zAlertRestoreFailed,
    zAlertConfirmRemoveSchool,
    zAlertTouchIDFailed,
    zAlertEmailInUseAlert,
    zAlertEmailSent,
    zAlertConfirmRemoveTeacher,
    zAlertConfirmSendAlert,
    zAlertUserApproved,
    zAlertUserDenied,
    zAlertEnterMessage,
    zAlertPasswordChangeSuccess,
    zAlertDeleteUser,
    zAlertDeleteUserSchool
} AlertTypes;

typedef enum
{
    zTextFieldEmail = 20,
    zTextFieldPin,
    zTextFieldMessage
    
} TextFieldTypes;

typedef enum
{
    mv_Home,
    mv_News,
    mv_Settings,
    mv_Contact,
    mv_Switch,
    mv_Calendar,
    mv_LunchMenu,
    mv_AdminTools,
    sv_UpdateKids,
    sv_UpdateKid,
    sv_UpdateProfile,
    sv_NewsDetail,
    sv_AddSchool,
    av_SendAlert,
    mvsvCount
} MainAndSubViews;

typedef enum
{
   agAllUsers = 1,
   agSchoolCorporation,
   agOneSchool,
   agOneClassroom,
   agOneTeacher,
   agOneParent
}AlertGroups;

typedef enum
{
    JANUARY = 1,
    FEBUARY,
    MARCH,
    APRIL,
    MAY,
    JUNE,
    JULY,
    AUGUST,
    SEPTEMBER,
    OCTOBER,
    NOVEMBER,
    DECEMBER
} Months;
//Database Constants
//base url
#define BASE_URL @"http://www.myschoolintercom.com/iPhone_php/"
#define IMAGE_URL @"http://www.myschoolintercom.com/school_images/"
#define NEWS_IMAGE_URL @"http://www.myschoolintercom.com/admin/_schoolNews/"
#define AD_IMAGE_URL @"http://www.myschoolintercom.com/admin/"
#define AD_DIRECTORY @"_schoolAdv/"
#define SCHOOL_NEWS_DIRECTORY @"_schoolNews/"
#define SCHOOL_LOGO_PATH @"http://www.myschoolintercom.com/admin/_schoolLogo/"
#define AD_OFFER_LINK @"http://www.myschoolintercom.com/offer/index.php"


//image suffixes
#define LOW_RES_SUFFIX @".png"
#define RETINA_SUFFIX @"@2x.png"
#define IPHONE5_SUFFIX @"-568h@2x.png"


//cellTypes
#define CELL_SEND_ALERT @"sendAlertCell"
#define CELL_APP_STATS @"appStatsCell"
#define CELL_MANAGE_TEACHERS @"manageTeachersCell"
#define CELL_MANAGE_USERS @"manageUsersCell"
#define CELL_EXIT @"exitCell"
#define CELL_USER_APPROVALS @"userApprovalsCell"
#define CELL_AD_STATS @"adStatsCell"
#define CELL_MANAGE_CALENDAR @"manageCalendarCell"
#define CELL_MANAGE_NEWS @"manageNewsCell"

#define CELL_FIRST_NAME @"firstNameCell"
#define CELL_LAST_NAME @"lastNameCell"
#define CELL_EMAIL @"emailCell"
#define CELL_RESET_PASSWORD @"resetPasswordCell"
#define CELL_ACCOUNT_TYPE @"accountTypeCell"
#define CELL_SCHOOLS @"schoolsCell"
#define CELL_PUSHPIN @"pushPinCell"
#define CELL_CREATED_ON @"createdOnCell"
#define CELL_DEVICE_MODEL @"deviceModelCell"
#define CELL_DEVICE_VERSION @"deviceVersionCell"

//php file defines

#define PHP_LOGIN_USER @"login_user_test.php"


#define PHP_GET_STATES @"get_states.php"
#define PHP_GET_CITIES @"get_cities.php"
#define PHP_GET_SCHOOLS @"get_schools.php"
#define PHP_ADD_USER @"add_user.php"
#define PHP_ADD_KID @"add_kid.php"
#define PHP_CHECK_STATUS @"verify_check.php"
#define PHP_LOAD_DATA @"load_data.php"
#define PHP_LOAD_LOCAL_AD @"load_local_ad.php"
#define PHP_ADD_SCHOOL @"add_school.php"
#define PHP_SEND_EMAIL @"send_email.php"
#define PHP_UPDATE_USER_PUSH_PIN @"update_push_pin.php"
#define PHP_RESET_PASSWORD @"reset_password.php"
#define PHP_UPDATE_PROFILE @"update_profile.php"
#define PHP_UPDATE_DEVICE_VERSION @"update_device_version.php"
#define PHP_UPDATE_AD_CLICKED @"update_ad_clicked.php"
#define PHP_UPDATE_HAS_PURCHASED @"update_has_purchased.php"
#define PHP_GET_KIDS @"get_kids.php"
#define PHP_UPDATE_KID @"update_kid.php"
#define PHP_DELETE_KID @"delete_kid.php"
#define PHP_ADD_SCHOOL_TO_USER @"add_school_to_user.php"
#define PHP_GET_PRODUCT_IDS @"get_product_ids.php"
#define PHP_GET_CURRENT_VERSION @"get_current_version.php"
#define PHP_ADD_SCHOOL_EMAIL @"send_add_school_email.php"
#define PHP_BADGE_UPDATE @"badge_update.php"
#define PHP_CHANGE_SCHOOL_STATUS @"change_school_status.php"
#define PHP_RESTORE_PURCHASE @"restore_purchase.php"
#define PHP_GET_EMAIL @"get_email.php"
#define PHP_GET_TEACHERS @"get_teachers.php"
#define PHP_GET_KID_TEACHERS @"get_kid_teachers.php"
#define PHP_ADD_TEACHER @"add_teacher.php"
#define PHP_DELETE_TEACHER_FROM_KID @"delete_teacher_from_kid.php"
#define PHP_GET_ALERT_GROUPS @"get_alert_groups.php"
#define PHP_GET_SECONDARY_ALERT_GROUP @"get_secondary_alert_groups.php"
#define PHP_INSERT_ALERT @"insert_alert.php"
#define PHP_GET_ADS @"get_ads.php"
#define PHP_GET_AD_STATS @"get_ad_stats.php"
#define PHP_APNS_RESPONSE @"apns_response.php"
#define PHP_UPDATE_USER_APPROVAL_STATUS @"update_approval_status.php"
#define PHP_GET_NEW_PENDING_USERS @"get_new_pending_users.php"
#define PHP_GET_USERS @"get_users.php"
#define PHP_GET_SINGLE_USER @"get_single_user.php"
#define PHP_GET_USERS_SCHOOLS @"get_users_schools.php"
#define PHP_GET_ALL_SCHOOLS @"get_all_schools.php"
#define PHP_GET_ALL_CORPS @"get_all_corps.php"
#define PHP_ADMIN_ADD_USER @"admin_add_user.php"
#define PHP_ADMIN_DELETE_USER @"delete_user.php"
#define PHP_ADMIN_UPDATE_USER @"admin_update_user.php"
#define PHP_ADMIN_ADD_USER_SCHOOL @"admin_add_user_school.php"
#define PHP_ADMIN_DELETE_USER_SCHOOL @"admin_delete_user_school.php"
#define PHP_ADMIN_UPDATE_USER_SCHOOL @"admin_update_user_school.php"

//common fields
#define MESSAGE_ID @"messageID"
#define SCHOOL_ID @"schoolID"
#define USER_ID @"userID"
#define ID @"id"
#define ACCOUNT_CREATED @"accountCreated"
#define SCHOOL_DATA @"schoolData"
#define NEWS_DATA @"newsData"
#define ALERT_DATA @"alertData"
#define CALENDAR_DATA @"calendarData"
#define HAS_MULTIPLE_SCHOOLS @"hasMultipleSchools"
#define NUMBER_OF_SCHOOLS @"numOfSchools"
#define SCHOOL_ID_ARRAY @"schoolIDArray"
#define WORKING_SCHOOL_ID @"workingSchoolID"
#define SCHOOL_DATA_ARRAY @"schoolDataArray"
#define EMAIL_SUBJECT @"emailSubject"
#define EMAIL_BODY @"emailBody"
#define PASSWORD_RESET @"passwordRest"
#define DEVICE_VERSION @"deviceVersion"
#define DEVICE_MODEL @"deviceModel"
#define CURRENT_VERSION @"currentVersion"
#define IS_APP_UP_TO_DATE @"isAppUpToDate"
#define WAS_UPDATE_ALERT_SHOWN @"wasUpdateAlertShown"
#define BADGE_COUNT @"badgeCount"
#define OLD_PASSWORD @"crWcmwaz"
#define NEW_PASSWORD @"mciwwuUR"
#define IS_DEMO_IN_USE @"isDemoInUse"
#define USER_SCHOOL_IS_ACTIVE @"isActive"
#define USER_IS_ADMIN @"isAdmin"
#define USER_ACCOUNT_TYPE @"userType"
#define DATA @"data"
#define IS_PENDING_APPROVAL @"isPendingApproval"

//alert_groups table
#define ALERT_GROUP_NAME @"groupName"
#define ALERT_GROUP_ID @"alertGroupID"

//adv table
#define AD_ID @"adID"
#define AD_IMAGE_NAME @"adImageName"
#define AD_IMPRESSION_COUNT @"adImpCount"
#define AD_CLICK_COUNT @"adClickCount"
#define AD_URL_LINK @"adUrlLink"
#define AD_TYPE @"adType"
#define AD_NAME @"adName"

//alert queue table
#define ALERT_TEXT @"alertText"
#define ALERT_LINK_URL @"alertLinkURL"
#define ALERT_TIME_SENT @"alertTimeSent"
#define ALERT_TYPE @"alertType"
#define ALERT_EXPIRE_DATE  @"alertExpireDate"

//calendar table
#define CAL_TITLE @"calTitle"
#define CAL_LOCATION @"calLocation"
#define CAL_START_DATE @"calStartDate"
#define CAL_END_DATE @"calEndDate"
#define CAL_IS_ALL_DAY @"calIsAllDay"
#define CAL_MORE_INFO @"calMoreInfo"

//invite table
#define INVITE_EMAIL @"email"
#define INVITE_TIMESTAMP @"timestamp"

//kid table
#define KID_FIRST_NAME @"kidFName"
#define KID_LAST_NAME @"kidLName"
#define KID_GRADE_LEVEL @"kidGradeLevel"
#define KID_ID @"kidID"

//login table
#define LOGIN_DATE @"loginDate"

//news table
#define NEWS_TITLE @"newsTitle"
#define NEWS_TEXT @"newsText"
#define NEWS_LINK_URL @"newsLinkURL"
#define NEWS_IMAGE_NAME @"newsImageName"
#define NEWS_GRADE_LEVEL @"newsGradeLevel"
#define NEWS_DATE @"newsDate"

//school table
#define SCHOOL_NAME @"schoolName"
#define SCHOOL_CORP_ID @"corpID"
#define SCHOOL_COLOR_1 @"schoolColor1"
#define SCHOOL_COLOR_2 @"schoolColor2"
#define SCHOOL_IMAGE_NAME @"schoolImageName"
#define SCHOOL_ADDRESS @"schoolAddress"
#define SCHOOL_STATE @"schoolState"
#define SCHOOL_ZIP @"schoolZip"
#define SCHOOL_CITY @"schoolCity"
#define SCHOOL_NEEDS_TO_VERIFY @"schoolVerifyUsers"
#define SCHOOL_IS_ACTIVE @"schoolActive"
#define SCHOOL_EMAIL @"schoolEmail"
#define SCHOOL_PHONE @"schoolPhone"
#define SCHOOL_NEWS_HEADER @"schoolNewsHeader"
#define SCHOOL_LUNCH @"schoolLunch"

//corporation table
#define CORP_ID @"corpID"

//user table
#define USER_FIRST_NAME @"userFName"
#define USER_LAST_NAME @"userLName"
#define USER_EMAIL @"userEmail"
#define USER_PIN @"userPin"
#define USER_PUSH_NOTIFICATION_PIN @"userPushPin"
#define USER_PASSWORD @"userPassword"

//verify queue Table
#define VQ_MESSAGE @"vqMessage"
#define VQ_DATE_ADDED @"dateAdded"
#define DATE_DENIED @"dateDenied"

//user schools table
#define US_NUMBER_OF_KIDS @"usNumOfKids"
#define USER_APPROVED @"usApproved"
#define USER_HAS_PURCHASED @"usHasPurchased"
#define US_PURCHASED_DATE @"purchasedDate"
#define US_TRANSACTION_ID @"transactionIdentifier"
#define US_IS_ACTIVE @"isActive"

//teacher table
#define TEACHER_ID @"teacherID"
#define TEACHER_PREFIX @"prefix"
#define TEACHER_FIRST_NAME @"userFName"
#define TEACHER_LAST_NAME @"userLName"
#define GRADE_LEVEL @"grade"
#define TEACHER_SUBJECT @"subject"
#define TEACHER_NAME @"teacherName"

//Segues
#define SEGUE_TO_MAIN_MENU @"mainmenu"
#define SEGUE_TO_HOME_VIEW  @"homeview"
#define SEGUE_TO_CALENDAR_VIEW @"calendarview"
#define SEGUE_TO_NEWS_VIEW @"newsview"
#define SEGUE_TO_CONTACT_VIEW @"contactview"
#define SEGUE_TO_SWITCH_VIEW @"switchview"
#define SEGUE_TO_REGISTER_VIEW @"registerview"
#define SEGUE_TO_SETTINGS_VIEW @"settingsview"
#define SEGUE_TO_UPDATE_PROFILE_VIEW @"updateprofileview"
#define SEGUE_TO_UPDATE_KIDS_VIEW @"updatekidsview"
#define SEGUE_TO_ADD_SCHOOL_VIEW @"addschoolview"
#define SEGUE_TO_NEWS_DETAIL_VIEW @"newsdetailview"
#define SEGUE_TO_LUNCH_MENU_VIEW @"lunchMenuSegue"
#define SEGUE_TO_UPDATE_KID_VIEW @"updateKidSegue"
#define SEGUE_TO_ADMIN_TOOLS @"adminToolsSegue"
#define SEGUE_TO_SEND_ALERTS_VIEW @"sendAlertSegue"
#define SEGUE_TO_USER_APPROVALS @"userApprovalsSegue"
#define SEGUE_TO_AD_STATS @"adStatsSegue"
#define SEGUE_TO_MANAGE_USERS @"manageUsersSegue"
#define SEGUE_TO_EDIT_SINGLE_USER @"editUserSegue"
#define SEGUE_TO_SELECT_USER_TYPE @"accountTypeSegue"
#define SEGUE_TO_USERS_SCHOOLS @"usersSchoolsSegue"
#define SEGUE_TO_SINGLE_SCHOOL @"singleSchoolSegue"
#define SEGUE_TO_ADD_NEW_USER @"addUserSegue"
#define SEGUE_TO_LIST_ALL_SCHOOLS @"allSchoolsSegue"

//Dictionary keys
#define DIC_CALENDAR_DATA @"calendarData"
#define USER_INFO @"userInfo"


