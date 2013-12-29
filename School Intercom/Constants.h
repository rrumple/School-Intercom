//
//  Constants.h
//  SchoolApp
//
//  Created by RandallRumple on 9/10/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//


//Pickers
typedef enum
{
    zPickerState = 100,
    zPickerCity,
    zPickerSchool
} PickerType;

//LoginScreen Alertview
typedef enum
{
    zAlertButtonNew = 0,
    zAlertButtonExisting
} AlertButtons;

#define zAlertEnterEmailOK 1

typedef enum
{
    zAlertNoUser = 10,
    zAlertEnterEmail,
    zAlertEmailError,
    zAlertAddKidError,
    zAlertVerifyPending,
    zAlertPurchase,
    zAlertInAppTemp,
    zAlertAddMoreError
} AlertTypes;

typedef enum
{
    zTextFieldEmail = 20,
    zTextFieldPin
    
} TextFieldTypes;

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
#define NEWS_IMAGE_URL @"http://www.myschoolintercom.com/news_images/"
#define AD_IMAGE_URL @"http://www.myschoolintercom.com/ad_images/"


//image suffixes
#define LOW_RES_SUFFIX @".png"
#define RETINA_SUFFIX @"@2x.png"
#define IPHONE5_SUFFIX @"-568h@2x.png"


//php file defines
#define GET_STATES @"get_states.php"
#define GET_CITIES @"get_cities.php"
#define GET_SCHOOLS @"get_schools.php"
#define ADD_USER @"add_user.php"
#define ADD_KID @"add_kid.php"
#define CHECK_STATUS @"verify_check.php"
#define LOAD_DATA @"load_data.php"
#define LOAD_LOCAL_AD @"load_local_ad.php"
#define ADD_SCHOOL @"add_school.php"
#define LOGIN_USER @"login_user.php"

//common fields
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

//adv table
#define AD_IMAGE_NAME @"adImageName"
#define AD_IMPRESSION_COUNT @"adImpCount"
#define AD_CLICK_COUNT @"adClickCount"
#define AD_URL_LINK @"adUrlLink"

//alert queue table
#define ALERT_TEXT @"alertText"
#define ALERT_LINK_URL @"alertLinkURL"
#define ALERT_TIME_SENT @"alertTimeSent"

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


//user table
#define USER_FIRST_NAME @"userFName"
#define USER_LAST_NAME @"userLName"
#define USER_EMAIL @"userEmail"
#define USER_PIN @"userPin"
#define USER_IS_VERIFIED @"userVerified"
#define USER_PUSH_NOTIFICATION_PIN @"userPushPin"
#define USER_PASSWORD @"userPassword"

//verify queue Table
#define VQ_MESSAGE @"vqMessage"
#define VQ_DATE_ADDED @"dateAdded"
#define VQ_DATE_APPROVED @"dateApproved"

//user schools table
#define US_NUMBER_OF_KIDS @"usNumOfKids"


//Segues
#define SEGUE_TO_MAIN_MENU @"mainmenu"
#define SEGUE_TO_HOME_VIEW  @"homeview"
#define SEGUE_TO_CALENDAR_VIEW @"calendarview"
#define SEGUE_TO_NEWS_VIEW @"newsview"
#define SEGUE_TO_CONTACT_VIEW @"contactview"
#define SEGUE_TO_SWITCH_VIEW @"switchview"
#define SEGUE_TO_REGISTER_VIEW @"registerview"
#define SEGUE_TO_SETTINGS_VIEW @"settingsview"


//Dictionary keys
#define DIC_CALENDAR_DATA @"calendarData"


