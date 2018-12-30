/**
 * 列表
 * @author 郑业强 2018-12-18 创建文件
 */

#import "ChartTableView.h"
#import "ChartTableCell.h"
#import "ChartTableHeader.h"
#import "ChartSectionHeader.h"
#import "CHART_EVENT.h"


#pragma mark - 声明
@interface ChartTableView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ChartTableHeader *tHeader;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation ChartTableView


+ (instancetype)initWithFrame:(CGRect)frame {
    ChartTableView *table = [[ChartTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [table setDelegate:table];
    [table setDataSource:table];
    [table lineHide];
    [table lineAll];
    [table setSeparatorColor:kColor_BG];
    [table setTableHeaderView:[table tHeader]];
    [table setShowsVerticalScrollIndicator:false];
    return table;
}


#pragma mark - set
- (void)setGroupModels:(NSMutableArray<ChartModel *> *)groupModels {
    _groupModels = groupModels;
    [self reloadData];
}
- (void)setListModels:(NSMutableArray<HomeListModel *> *)listModels {
    _listModels = listModels;
    _tHeader.listModels = listModels;
}
- (void)setSubModel:(ChartSubModel *)subModel {
    _subModel = subModel;
    _tHeader.subModel = subModel;
}
- (void)setNavigationIndex:(NSInteger)navigationIndex {
    _navigationIndex = navigationIndex;
    [self reloadData];
}
- (void)setSegmentIndex:(NSInteger)segmentIndex {
    _segmentIndex = segmentIndex;
    _tHeader.segmentIndex = segmentIndex;
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
// 点击图表
- (void)chartBeginTouch:(id)data {
    [self setScrollEnabled:false];
}
// 结束图表
- (void)chartEndTouch:(id)data {
    [self setScrollEnabled:true];
}
// 取消图表
- (void)chartCannelTouch:(id)data {
    [self setScrollEnabled:true];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChartTableCell *cell = [ChartTableCell loadFirstNib:tableView];
    cell.maxPrice = [[self.groupModels valueForKeyPath:@"@max.price.floatValue"] floatValue];
    cell.model = self.groupModels[indexPath.row];
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return countcoordinatesX(50);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ChartSectionHeader *header = [ChartSectionHeader loadFirstNib:CGRectMake(0, 0, SCREEN_WIDTH, countcoordinatesX(40))];
    header.navigationIndex = _navigationIndex;
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return countcoordinatesX(50);
}


#pragma mark - get
- (ChartTableHeader *)tHeader {
    if (!_tHeader) {
        _tHeader = [ChartTableHeader loadCode:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 2)];
    }
    return _tHeader;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           CHART_CHART_TOUCH_BEGIN: [self createInvocationWithSelector:@selector(chartBeginTouch:)],
                           CHART_CHART_TOUCH_END: [self createInvocationWithSelector:@selector(chartEndTouch:)],
                           CHART_CHART_TOUCH_CANNEL: [self createInvocationWithSelector:@selector(chartCannelTouch:)]
                           };
    }
    return _eventStrategy;
}


@end
