
#import "BaseUtil.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>
#include "IosPlatformUtil.h"
#import "sys/utsname.h"
#define MakeStringCopy( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL
//代码定义区域 C - Begin
static NSMutableDictionary * _baseData;
@implementation BaseUtil

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

+ (id)sharedInstance {
    static  BaseUtil*  s_instance = nil;
    if (nil == s_instance) {
        @synchronized(self) {
            if (nil == s_instance) {
                s_instance = [[self alloc] init];
            }
        }
    }
    return s_instance;
}

- (UIWindow*)GetMainWindow{
    
    CGRect winSize = [UIScreen mainScreen].bounds;
    //IPHONEX
    if (winSize.size.height / winSize.size.width > 2) 
    {
        winSize.size.height -= 34;
        winSize.origin.y = 34;
    }  
    return [[UIWindow alloc] initWithFrame: winSize]; 
}
- (NSString*)getDeviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceVersion = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceVersion;
}

+ (void)sendDictMessage:(NSString *)messageName param:(NSDictionary *)dict
{
    NSString *param = @"";
    for (NSString *key in dict)
    {
        if ([param length] == 0)
        {
            param = [param stringByAppendingFormat:@"%@=%@", key, [dict valueForKey:key]];
        }
        else
        {
            param = [param stringByAppendingFormat:@"&%@=%@", key, [dict valueForKey:key]];
        }
    }
    //UnitySendMessage([[BaseUtil GetUnityReceiver] UTF8String], [messageName UTF8String], [param UTF8String]);
    
    [BaseUtil sendMessage:messageName param:param];
}
+ (void)sendMessage:(NSString *)messageName param: (NSString *)param
{
    UnitySendMessage([[BaseUtil GetUnityReceiver] UTF8String], [messageName UTF8String], [param UTF8String]);
}
+(void)nativeError:(NSString *)msg{
    [BaseUtil sendMessage:@"NativeError" param:msg];
}

- (void)Init{

    //工具初始化
    [[IosPlatformUtil sharedInstance]Init];
}

+(NSString*)GetUnityReceiver{
    return @"DDOLGameObject";
}

+(void)UnityLog:(NSString *) msg{
     NSLog(@"%@",msg);
    [BaseUtil sendMessage:@"UnityPrint" param:msg];
}
+(void)UnityLogDic:(NSDictionary *)dict{
    NSString *param = @"";
    for (NSString *key in dict)
    {
        if ([param length] == 0)
        {
            param = [param stringByAppendingFormat:@"%@=%@", key, [dict valueForKey:key]];
        }
        else
        {
            param = [param stringByAppendingFormat:@";%@=%@", key, [dict valueForKey:key]];
        }
    }
   
    NSLog(@"%@",param);
    [BaseUtil  UnityLog:param];
}



//APP唤起处理
- (void)HandleOpenUrl:(NSURL *)url{
    
    //专用唤起处理
    [[IosPlatformUtil sharedInstance] HandleOpenUrl:url];
    

    
    //通用唤起处理
    NSString * host = [[url host]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"唤起app:%@",host);
    NSArray *paramArray = [host componentsSeparatedByString:@"&"];
    if([paramArray count] == 0){
        return;
    }
    NSLog(@"paramArray: %@",paramArray);
    
}



const char * _getCountryCode()
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLog(@"countryCode:%@", countryCode);
    return MakeStringCopy(countryCode);
}



const char* getIPv6(const char *mHost,const char *mPort)
{
    if( nil == mHost )
        return NULL;
    const char *newChar = "No";
    struct addrinfo* res0;
    struct addrinfo hints;
    struct addrinfo* res;
    int n, s;

    memset(&hints, 0, sizeof(hints));

    hints.ai_flags = AI_DEFAULT;
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if((n=getaddrinfo(mHost, "http", &hints, &res0))!=0)
    {
        printf("getaddrinfo error: %s\n",gai_strerror(n));
        return NULL;
    }

    struct sockaddr_in6* addr6;
    struct sockaddr_in* addr;
    NSString * NewStr = NULL;
    char ipbuf[32];
    s = -1;
    for(res = res0; res; res = res->ai_next)
    {
        if (res->ai_family == AF_INET6)
        {
            addr6 =( struct sockaddr_in6*)res->ai_addr;
            newChar = inet_ntop(AF_INET6, &addr6->sin6_addr, ipbuf, sizeof(ipbuf));
            NSString * TempA = [[NSString alloc] initWithCString:(const char*)newChar
                                                        encoding:NSASCIIStringEncoding];
            NSString * TempB = [NSString stringWithUTF8String:"&&ipv6"];

            NewStr = [TempA stringByAppendingString: TempB];
            printf("%s\n", newChar);
        }
        else
        {
            addr =( struct sockaddr_in*)res->ai_addr;
            newChar = inet_ntop(AF_INET, &addr->sin_addr, ipbuf, sizeof(ipbuf));
            NSString * TempA = [[NSString alloc] initWithCString:(const char*)newChar
                                                        encoding:NSASCIIStringEncoding];
            NSString * TempB = [NSString stringWithUTF8String:"&&ipv4"];

            NewStr = [TempA stringByAppendingString: TempB];
            printf("%s\n", newChar);
        }
        break;
    }


    freeaddrinfo(res0);

    printf("getaddrinfo OK");

    NSString * mIPaddr = NewStr;
    NSLog(@"---------------%@",mIPaddr);
    return MakeStringCopy(mIPaddr);
}






extern void UnitySendMessage(const char *, const char *, const char *);


@end



