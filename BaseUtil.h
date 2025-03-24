@interface BaseUtil : NSObject
@property (nonatomic, retain)   UIViewController* vv;
+ (id)sharedInstance ;
- (void)Init;
+ (NSString*)GetUnityReceiver;
+ (void)UnityLog :(NSString *)msg;
+(void)nativeError:(NSString*)msg;
+ (void)UnityLogDic:(NSDictionary*)dict;
+ (void)sendMessage:(NSString *)messageName  param:(NSString *)param;
+ (void)sendDictMessage:(NSString *)messageName param:(NSDictionary *)dict;
- (void)HandleOpenUrl:(NSURL *)url;
- (UIWindow*)GetMainWindow;
@end
