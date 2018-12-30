/**
 * 首页
 * @author 郑业强 2018-12-16 创建文件
 */

#import "HomeController.h"
#import "HomeHeader.h"
#import "HomeList.h"
#import "LoginController.h"
#import "HomeListModel.h"
#import "HOME_EVENT_MANAGER.h"


#pragma mark - 声明
@interface HomeController()

@property (nonatomic, strong) HomeHeader *header;
@property (nonatomic, strong) HomeList *list;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSMutableArray<HomeListModel *> *datas;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<HomeListModel *> *> *models;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation HomeController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_share_shark"]]];
    [self setJz_navigationBarTintColor:kColor_Main_Color];
    [self header];
    [self list];
    [self setDate:[NSDate date]];
    [self bookGroupRequest:self.date];
    [self monitorNotification];

}
// 监听通知
- (void)monitorNotification {
    // 登录完成
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:NOT_BOOK_COMPLETE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        [self bookGroupRequest:self.date];
    }];
}


#pragma mark - 请求
// 查账
- (void)bookGroupRequest:(NSDate *)date {
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           @(date.year), @"year",
                           @(date.month), @"month", nil];
    @weakify(self)
    [AFNManager POST:GetBookListRequest params:param complete:^(APPResult *result) {
        @strongify(self)
        // 成功
        if (result.status == ServiceCodeSuccess) {
            [self setDatas:[HomeListModel mj_objectArrayWithKeyValuesArray:result.data]];
            [self setDate:date];
        }
        // 失败
        else {
            [self showWindowTextHUD:result.message delay:1.f];
        }
    }];
}


#pragma mark - set
- (void)setDatas:(NSMutableArray<HomeListModel *> *)datas {
    _datas = datas;
    NSDictionary *param = [HomeListModel createGroupWithList:datas];
    CGFloat income = [param[@"income"] floatValue];
    CGFloat pay = [param[@"pay"] floatValue];
    
    NSMutableArray<NSMutableArray<HomeListModel *> *> *models = param[@"data"];
    [self setModels:models];
    [self.header setPay:pay];
    [self.header setIncome:income];
}
- (void)setModels:(NSMutableArray<NSMutableArray<HomeListModel *> *> *)models {
    _models = models;
    _list.models = models;
}
- (void)setDate:(NSDate *)date {
    _date = date;
    _header.date = date;
}


#pragma mark - 事件
- (void)routerEventWithName:(NSString *)eventName data:(id)data {
    [self handleEventWithName:eventName data:data];
}
- (void)handleEventWithName:(NSString *)eventName data:(id)data {
    NSInvocation *invocation = self.eventStrategy[eventName];
    [invocation setArgument:&data atIndex:2];
    [invocation invoke];
    [super routerEventWithName:eventName data:data];
}
// 点击月份
- (void)homeMonthClick:(id)data {
    @weakify(self)
    NSDate *date = self.date;
    NSDate *min = [NSDate br_setYear:2000 month:1 day:1];
    NSDate *max = [NSDate br_setYear:date.year + 3 month:12 day:31];
    [BRDatePickerView showDatePickerWithTitle:@"选择日期" dateType:BRDatePickerModeYM defaultSelValue:[date formatYM] minDate:min maxDate:max isAutoSelect:false themeColor:nil resultBlock:^(NSString *selectValue) {
        @strongify(self)
        [self setDate:({
            NSDateFormatter *fora = [[NSDateFormatter alloc] init];
            [fora setDateFormat:@"yyyy-MM"];
            NSDate *date = [fora dateFromString:selectValue];
            date;
        })];
        [self bookGroupRequest:self.date];
    }];
}
// 下拉
- (void)homeTablePull:(id)data {
    NSDate *next = [self.date offsetMonths:1];
    [self bookGroupRequest:next];
}
// 上拉
- (void)homeTableUp:(id)data {
    NSDate *last = [self.date offsetMonths:-1];
    [self bookGroupRequest:last];
}


#pragma mark - get
- (HomeHeader *)header {
    if (!_header) {
        _header = [HomeHeader loadFirstNib:CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, countcoordinatesX(64))];
        [self.view addSubview:_header];
    }
    return _header;
}
- (HomeList *)list {
    if (!_list) {
        _list = [HomeList loadCode:({
            CGFloat top = CGRectGetMaxY(_header.frame);
            CGFloat height = SCREEN_HEIGHT - top - TabbarHeight;
            CGRectMake(0, top, SCREEN_WIDTH, height);
        })];
        [self.view addSubview:_list];
    }
    return _list;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           HOME_MONTH_CLICK: [self createInvocationWithSelector:@selector(homeMonthClick:)],
                           HOME_TABLE_PULL: [self createInvocationWithSelector:@selector(homeTablePull:)],
                           HOME_TABLE_UP: [self createInvocationWithSelector:@selector(homeTableUp:)],
                           };
    }
    return _eventStrategy;
}


@end
