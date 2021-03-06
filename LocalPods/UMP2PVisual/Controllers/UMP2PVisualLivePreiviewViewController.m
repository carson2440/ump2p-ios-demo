//
//  UMP2PVisualLivePreiviewViewController
//  UMP2PVisual
//
//  Created by Fred on 2019/3/15.
//
#import "UMP2PVisualLivePreiviewViewController.h"
#import "UMP2PVisualLivePreiviewView.h"
#import "UMP2PVisualLivePreiviewViewModel.h"

#import <Masonry/Masonry.h>
@interface UMP2PVisualLivePreiviewViewController()

@property (nonatomic, strong) UMP2PVisualLivePreiviewView *mView;
@property (nonatomic, strong) UMP2PVisualLivePreiviewViewModel *viewModel;
@end
@implementation UMP2PVisualLivePreiviewViewController

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 开始播放
    [self.viewModel setupDeviceConnData:self.playItem];
    [self.viewModel subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } api:0];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 停止播放
    [self.viewModel subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } api:1];
}

/// 初始化数据
- (void)initialDefaultsForController{
    
}

/// 配置导航栏
- (void)configNavigationForController{
    
}

/// 创建视图
- (void)createViewForConctroller{
    [self.view addSubview:self.mView];
    // 播放视图，添加到显示视图
    [self.mView setupDisplayView:[self.viewModel displayView]];
    [self.view setNeedsUpdateConstraints];
}

/// 绑定 vm
- (void)bindViewModelForController{
    // 开始/停止
    [self.mView.startOrStopBtn addTarget:self action:@selector(playOrStop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mView.captureBtn addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mView.recordBtn addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    
    // 更新播放状态
    [RACObserve(self.viewModel, playState) subscribeNext:^(id  _Nullable x) {
        if (self.viewModel.playState == HKS_NPC_D_MON_DEV_PLAY_STATUS_STOP
            || self.viewModel.playState == HKS_NPC_D_MON_DEV_PLAY_STATUS_READY) {
            self.mView.startOrStopBtn.selected = NO;
        }else{
            self.mView.startOrStopBtn.selected = YES;
        }
        self.mView.stateLable.text = self.viewModel.playStateDescription;
    }];
}

- (void)updateViewConstraints{
    [self.mView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [super updateViewConstraints];
}

#pragma mark -
- (void)playOrStop{
    [self.viewModel setupDeviceConnData:self.playItem];
    [self.viewModel subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } api:3];
}

/// 本地抓拍
- (void)capture{
    [self.viewModel subscribeNext:^(id x) {
        [SVProgressHUD showSuccessWithStatus:@"抓拍成功"];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } api:4];
}

- (void)record{
    if (self.mView.recordBtn.selected) {
        // 停止录像
        [self.viewModel subscribeNext:^(id x) {
            self.mView.recordBtn.selected = NO;
            [SVProgressHUD showSuccessWithStatus:@"录像保存成功"];
        } error:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } api:5];
    }else{
        // 开启录像
        [self.viewModel subscribeNext:^(id x) {
            self.mView.recordBtn.selected = YES;
            [SVProgressHUD showSuccessWithStatus:@"开启录像"];
        } error:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } api:5];
    }
    
}
#pragma mark -
- (UMP2PVisualLivePreiviewView *)mView{
    if (!_mView) {
        _mView = [[UMP2PVisualLivePreiviewView alloc] init];
    }
    return _mView;
}

- (UMP2PVisualLivePreiviewViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[UMP2PVisualLivePreiviewViewModel alloc] init];
    }
    return _viewModel;
}

- (TreeListItem *)playItem{
    if (!_playItem) {
        _playItem = [[TreeListItem alloc] init];
        /*设置设备连接模式：p2p穿透模式或者直连，如果是p2p就需要设置把umid设置给sDeviceId，如果是direct直连模式，就需要把ip和端口设置给sAddress和iPort
         */
        _playItem.iConnMode = HKS_NPC_D_MON_DEV_CONN_MODE_CLOUD_P2P;
        //设备序列号
        _playItem.sDeviceId = @"0059f67caf1b4a0f";
        //设备用户名
        _playItem.sUserId = @"admin";
        //设备密码
        _playItem.sUserPwd = @"";
        //设备通道,从0开始
        _playItem.iChannel = 0;
        //设备码流，1:子码流，0:主码流
        _playItem.iStream = 1;
        //设置设备协议类型，p2p模式可以不填写，直连直接写死UMSP类型
        _playItem.iVendorId = HKS_NPC_D_MON_VENDOR_ID_UMSP;

    }
    return _playItem;
}
@end
