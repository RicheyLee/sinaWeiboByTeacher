//
//  comments.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/17.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#ifndef Flo_Weibo_comments_h
#define Flo_Weibo_comments_h

#define kAppKey         @"2809542451"
#define kAppSecret      @"6c06aa4b91690d9ea3d5349c9f2f6456"

//#define kAppKey         @"4028596770"
//#define kAppSecret      @"2e71ecd87b72c0dc463c764f990b89d1"

// 通知
#define kLoginSuccess          @"kLoginSuccess"
#define kLoginOut              @"loginOut"
#define kFavorite              @"favoritedStatus"
#define kHiddenTabBarV         @"hiddenTabBarV"
#define kShowPrompt            @"showPromptView"
#define kCancelFavoriteSuccess @"cancelFavorite"

// 请求URL
#define kRedirectURL          @"http://api.weibo.com/oauth2/default.html"
#define kAccessTokenURL       @"https://api.weibo.com/oauth2/access_token"
#define kAuthorizeURL         @"https://api.weibo.com/oauth2/authorize"
#define kUsersShowURL         @"https://api.weibo.com/2/users/show.json"
#define kUpdateStatusURL      @"https://api.weibo.com/2/statuses/update.json"
#define kHomeStatusesURL      @"https://api.weibo.com/2/statuses/home_timeline.json"
#define kFavoriteStatusURl    @"https://api.weibo.com/2/favorites/create.json"
#define kPublicStatusURl      @"https://api.weibo.com/2/statuses/public_timeline.json"
#define kCommentStatusURl     @"https://api.weibo.com/2/comments/create.json"
#define kRepostStatusURL      @"https://api.weibo.com/2/statuses/repost.json"
#define kShowCommentsURL      @"https://api.weibo.com/2/comments/show.json"
#define kShowRepostURl        @"https://api.weibo.com/2/statuses/repost_timeline.json"
#define kMessageCommentURL    @"https://api.weibo.com/2/comments/to_me.json"
#define kMessageComAtmeURL    @"https://api.weibo.com/2/comments/mentions.json"
#define kMessageStatusAtmeURL @"https://api.weibo.com/2/statuses/mentions.json"
#define kReplyCommentsURL     @"https://api.weibo.com/2/comments/reply.json"
#define kCancelFollowUserURL  @"https://api.weibo.com/2/friendships/destroy.json"
#define kFollowUserURL        @"https://api.weibo.com/2/friendships/create.json"
#define kFollowListURL        @"https://api.weibo.com/2/friendships/friends.json"
#define kUserStatusURL        @"https://api.weibo.com/2/statuses/user_timeline.json"
#define kUserInterestedURL    @"https://api.weibo.com/2/suggestions/users/may_interested.json"
#define kUserHotURL           @"https://api.weibo.com/2/suggestions/users/hot.json"
#define kUserFriendsURL       @"https://api.weibo.com/2/friendships/friends/bilateral.json"
#define kFavoriteListURL      @"https://api.weibo.com/2/favorites.json"
#define kFavoriteCancelURL    @"https://api.weibo.com/2/favorites/destroy.json"

// 登陆信息
#define kGrantType      @"authorization_code"
#define kAccessToken    @"access_token"
#define kTokenTime      @"expires_in"
#define kUID            @"uid"

#define kStatus         @"status"

// 用户信息
#define kIDStr              @"idstr"
#define kScreenName         @"screen_name"
#define kLevel              @"mbrank"
#define kLocation           @"location"
#define kDescription        @"description"
#define kBlogURL            @"url"
#define kUserIconURL        @"profile_image_url"
#define kSex                @"gender"
#define kIsFollowing        @"following"
#define kStatusCount        @"statuses_count"
#define kFollowingCount     @"friends_count"
#define kFollowerCount      @"followers_count"
#define kFavouriteCount     @"favourites_count"
#define kCreateTime         @"created_at"
#define kIsVerified         @"verified"
#define kVerifiedReason     @"verified_reason"
#define kIconLargeURL       @"avatar_large"
#define kBothFollowingCount @"bi_followers_count"
#define kUserRank           @"urank"
#define kVerifiedSource     @"verified_source"

//解析微博所使用的关键字常量，也就是新浪服务器返回的数据由JSONKit解析后生成的字典关于微博信息的key值
static NSString * const kStatusStatuses        = @"statuses";
static NSString * const kStatusCreateTime      = @"created_at";
static NSString * const kStatusID              = @"id";
static NSString * const kStatusMID             = @"mid";
static NSString * const kStatusText            = @"text";
static NSString * const kStatusSource          = @"source";
static NSString * const kStatusThumbnailPic    = @"thumbnail_pic";
static NSString * const kStatusOriginalPic     = @"original_pic";
static NSString * const kStatusPicUrls         = @"pic_urls";
static NSString * const kStatusRetweetStatus   = @"retweeted_status";
static NSString * const kStatusUserInfo        = @"user";
static NSString * const kStatusRetweetStatusID = @"retweeted_status_id";
static NSString * const kStatusRepostsCount    = @"reposts_count";
static NSString * const kStatusCommentsCount   = @"comments_count";
static NSString * const kStatusAttitudesCount  = @"attitudes_count";
static NSString * const kstatusFavorited       = @"favorited";

//解析微博评论列表用到的key值
static NSString * const kCommontCreated_at    = @"created_at";//string	评论创建时间
static NSString * const kCommontID            = @"id";//int64	评论的ID
static NSString * const kCommontText          = @"text";//string	评论的内容
static NSString * const kCommontSource        = @"source";//string	评论的来源
static NSString * const kCommontUser          = @"user";//object	评论作者的用户信息字段 详细
static NSString * const kCommontReply_comment = @"reply_comment";//object 评论来源评论，当本评论属于对另一评论的回复时返回此字段


// storyboard identifier
#define kLoginVCIdentifier   @"loginVC"
#define kAccountManagerTVC   @"accountManagerTVC"
#define kSendMessageVC       @"sendMessageVC"
#define kStatusDetailVC      @"statusDetailVC"
#define kMessageDetailVC     @"messageDetailVC"
#define kUserInfoTVC         @"userInfoTVC"
#define kPostStatusWithPicVC @"postStatusWithPic"
#define kPostStatusWithLocVC @"locationVC"


// file name
#define kAuthorizationArchiver @"authorization"
#define kCurrentUserIDFile     @"currentuserid.plist"
#define kCurrentUserID         @"currentUserID"

// 发微博ModelView的按钮
#define kBtnControlBeTouched @"btnControlBeTouched"
#define kHomeBtnTouchAgain   @"homeBtnTouchAgain"

#endif
