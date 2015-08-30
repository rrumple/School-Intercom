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
    zPickerPrefix,
    zPickerName,
    zPickerClassRoom
} PickerType;

//LoginScreen Alertview
typedef enum
{
    zAlertButtonNew = 0,
    zAlertButtonExisting,
    zAlertButtonAdminLogin,
    zAlertButtonTryDemo
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
    quGetAllParentsForOneSchool,
    quGetAllClasses,
    quGetAllParentsInClass
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
    utBetaTester,
    utGrandparent
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
    zAlertDeleteUserSchool,
    zAlertAddEventSuccess,
    zAlertAddNewsSuccess,
    zAlertSuggestPurchase,
    zAlertPushPinChange,
    zAlertAddGrandparentSuccess,
    zAlertConfirmRemoveGrandparent,
    zAlertProductPurchaseError,
    zAlertFailedConnection
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
    mv_Offer,
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
   agOneParent,
   agAllClasses
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




#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define AD_MOB_TEST_UNIT_ID @"ca-app-pub-3940256099942544/2934735716"
#define AD_MOB_TEACHER_UNIT_ID @"ca-app-pub-4977472569676567/1916133132"
#define AD_REFRESH_RATE 45
#define AD_HIDE_TIME 1
#define IPHONE_UNIT_ID @"iphoneUnitID"


//Database Constants
//base url
#define BASE_URL @"http://www.myschoolintercom.com/iPhone_php/"
#define IMAGE_URL @"http://www.myschoolintercom.com/school_images/"
#define NEWS_IMAGE_URL @"http://www.myschoolintercom.com/admin/_schoolNews/"
#define NEWS_ATTACHMENT_URL @"http://www.myschoolintercom.com/admin/_schoolNews/attachments/"
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
#define CELL_PARENT_LIST @"parentListCell"
#define CELL_TEACHER_LIST @"teacherListCell"
#define CELL_PRINCIPAL_LIST @"principalListCell"

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
#define CELL_MANAGE_SCHOOLS @"manageSchoolsCell"
#define CELL_MANAGE_CLASSES @"manageClassesCell"

#define CELL_UPDATE_PROFILE @"updateProfileCell"
#define CELL_UPDATE_KIDS @"updateKidsCell"
#define CELL_ADD_SCHOOL @"addSchoolCell"
#define CELL_ADD_GRANDPARENT @"addGrandparentCell"
#define CELL_RESET_TUTORIAL @"resetTutorialCell"
#define CELL_EMPTY @"emptyCell"
#define CELL_ADD_CLASS @"addClassCell"

//php file defines

#define PHP_LOGIN_USER @"login_user_124.php"


#define PHP_GET_STATES @"get_states.php"
#define PHP_GET_CITIES @"get_cities.php"
#define PHP_GET_SCHOOLS @"get_schools.php"
#define PHP_ADD_USER @"add_user.php"
#define PHP_ADD_KID @"add_kid_122.php"
#define PHP_CHECK_STATUS @"verify_check.php"
#define PHP_LOAD_DATA @"load_data_124.php"
#define PHP_LOAD_LOCAL_AD @"load_local_ad_122.php"
#define PHP_ADD_SCHOOL @"add_school.php"
#define PHP_SEND_EMAIL @"send_email.php"
#define PHP_UPDATE_USER_PUSH_PIN @"update_push_pin.php"
#define PHP_RESET_PASSWORD @"reset_password.php"
#define PHP_UPDATE_PROFILE @"update_profile.php"
#define PHP_UPDATE_DEVICE_VERSION @"update_device_version.php"
#define PHP_UPDATE_AD_CLICKED @"update_ad_clicked.php"
#define PHP_UPDATE_MM_AD_CLICKED @"mm_update_ad_clicked.php"
#define PHP_UPDATE_MM_AD_FAILED @"mm_update_ad_failed.php"
#define PHP_UPDATE_MM_AD_IMP_COUNT @"mm_update_ad_imp.php"
#define PHP_UPDATE_HAS_PURCHASED @"update_has_purchased.php"
#define PHP_GET_KIDS @"get_kids.php"
#define PHP_UPDATE_KID @"update_kid_122.php"
#define PHP_DELETE_KID @"delete_kid.php"
#define PHP_ADD_SCHOOL_TO_USER @"add_school_to_user.php"
#define PHP_GET_PRODUCT_IDS @"get_product_ids.php"
#define PHP_GET_CURRENT_VERSION @"get_current_version.php"
#define PHP_ADD_SCHOOL_EMAIL @"send_add_school_email.php"
#define PHP_BADGE_UPDATE @"badge_update.php"
#define PHP_CHANGE_SCHOOL_STATUS @"change_school_status.php"
#define PHP_RESTORE_PURCHASE @"restore_purchase.php"
#define PHP_GET_EMAIL @"get_email.php"
#define PHP_GET_TEACHERS @"get_teachers_124.php"
#define PHP_GET_KID_TEACHERS @"get_kid_teachers_124.php"
#define PHP_ADD_TEACHER @"add_teacher_122.php"
#define PHP_DELETE_TEACHER_FROM_KID @"delete_teacher_from_kid_122.php"
#define PHP_GET_ALERT_GROUPS @"get_alert_groups.php"
#define PHP_GET_SECONDARY_ALERT_GROUP @"get_secondary_alert_groups.php"
#define PHP_INSERT_ALERT @"insert_alert_122.php"
#define PHP_GET_ADS @"get_ads.php"
#define PHP_GET_AD_STATS @"get_ad_stats.php"
#define PHP_APNS_RESPONSE @"apns_response.php"
#define PHP_UPDATE_USER_APPROVAL_STATUS @"update_approval_status.php"
#define PHP_GET_NEW_PENDING_USERS @"get_new_pending_users.php"
#define PHP_GET_USERS @"get_users.php"
#define PHP_GET_SINGLE_USER @"get_single_user.php"
#define PHP_GET_USERS_SCHOOLS @"get_users_schools_1-2-2.php"
#define PHP_GET_ALL_SCHOOLS @"get_all_schools.php"
#define PHP_GET_ALL_CORPS @"get_all_corps.php"
#define PHP_ADMIN_ADD_USER @"admin_add_user.php"
#define PHP_ADMIN_DELETE_USER @"delete_user.php"
#define PHP_ADMIN_UPDATE_USER @"admin_update_user.php"
#define PHP_ADMIN_ADD_USER_SCHOOL @"admin_add_user_school.php"
#define PHP_ADMIN_DELETE_USER_SCHOOL @"admin_delete_user_school.php"
#define PHP_ADMIN_UPDATE_USER_SCHOOL @"admin_update_user_school.php"
#define PHP_GET_USER_CALENDAR_EVENTS @"get_user_calendar_events.php"
#define PHP_ADD_EVENT @"add_event.php"
#define PHP_UPDATE_EVENT @"update_event.php"
#define PHP_DELETE_EVENT @"delete_event.php"
#define PHP_GET_USER_NEWS_POSTS @"get_user_news_posts.php"
#define PHP_ADD_NEWS_POST @"add_news.php"
#define PHP_UPDATE_NEWS_POST @"update_news.php"
#define PHP_DELETE_NEWS_POST @"delete_news.php"
#define PHP_GET_PARENTS_OF_TEACHER @"get_parents.php"
#define PHP_GET_PARENTS_OF_CLASS @"get_parents_class.php"
#define PHP_GET_TEACHERS_OF_PRINCIPAL @"get_teachers_principal.php"
#define PHP_GET_PRINCIPALS_OF_SUPER @"get_principals_super.php"
#define PHP_GET_OFFER_DATA @"get_fundraiser_data.php"
#define PHP_UPDATE_TEACHER_NAMES @"update_teacher_names_124.php"
#define PHP_LOG_OUT_USER @"log_out_user.php"
#define PHP_GET_SCHOOL_STATS @"get_school_stats.php"
#define PHP_GET_ALERTS_SUBMITTED_BY_USER @"get_alerts_for_user.php"
#define PHP_DELETE_ALERT @"delete_alert.php"
#define PHP_UPDATE_ALERT @"update_alert.php"
#define PHP_ADD_GRANDPARENT @"add_grandparent.php"
#define PHP_GET_GRANDPARENTS @"get_grandparents.php"
#define PHP_DELETE_SYSTEM_MESSAGE @"delete_system_message.php"
#define PHP_ADD_CLASS @"add_class.php"
#define PHP_UPDATE_CLASS @"update_class.php"
#define PHP_GET_TEACHER_CLASSES @"get_teacher_classes.php"
#define PHP_DELETE_CLASS @"delete_class.php"


//common fields
#define CLASS_ID @"classID"
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

//Offer table
#define OFFER_TITLE @"mainTitle"
#define OFFER_DETAIL_TEXT @"detailText"
#define OFFER_PRICE @"price"
#define OFFER_BUY_BUTTON_TEXT @"buyButtonText"
#define OFFER_BUY_BUTTON_LINK @"buyButtonLink"
#define OFFER_MORE_INFO_LINK @"moreInfoLink"
#define OFFER_IS_IN_APP_PURCHASE @"isInAppPurchase"


//Segues
#define SEGUE_TO_CLASS_LIST @"classListSegue"
#define SEGUE_TO_SEND_USER_ALERT @"sendUserAlertSegue"
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
#define SEGUE_TO_MANAGE_CALENDARS @"manageCalendarsSegue"
#define SEGUE_TO_MANAGE_EVENT @"manageEventSegue"
#define SEGUE_TO_MANAGE_NEWS @"manageNewsSegue"
#define SEGUE_TO_MANAGE_POST @"managePostSegue"
#define SEGUE_TO_PARENT_LIST @"parentListSegue"
#define SEGUE_TO_TEACHER_LIST @"teacherListSegue"
#define SEGUE_TO_PRINCIPAL_LIST @"principalListSegue"
#define SEGUE_TO_OFFER @"segueToOffer"
#define SEGUE_TO_MANAGE_SCHOOLS @"manageSchoolsSegue"
#define SEGUE_TO_SCHOOL_STATS @"schoolStatsSegue"
#define SEGUE_TO_MANAGE_ALERTS @"manageAlertsSegue"
#define SEGUE_TO_EDIT_ALERT @"editAlertSegue"
#define SEGUE_TO_ADD_GRANDPARENT @"addGrandParentSegue"
#define SEGUE_TO_ADD_UPDATE_CLASS @"addUpdateClassSegue"

//Dictionary keys
#define DIC_CALENDAR_DATA @"calendarData"
#define USER_INFO @"userInfo"


