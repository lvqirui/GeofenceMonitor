//
//  GeofenceMonitorManager.m
//  GeofenceMonitorDemo
//
//  Created by 吕其瑞 on 2017/12/19.
//  Copyright © 2017年 吕其瑞. All rights reserved.
//

#import "GeofenceMonitorManager.h"
#import "CacheFile.h"
#import "Geotification.h"

@import CoreLocation;

@interface GeofenceMonitorManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation GeofenceMonitorManager

static GeofenceMonitorManager *manager;

+(instancetype)shareInstance
{
    @synchronized(manager){
        if (!manager) {
            manager = [[GeofenceMonitorManager alloc] init];
            manager.locationManager = [[CLLocationManager alloc] init];
            // Configure the location manager.
            manager.locationManager.delegate = manager;
            manager.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
            manager.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
        return manager;
    }
}

//请求门店经纬度
-(void)requestNetWorkForGeofences
{
    //网络请求，如果有新数据加载，没新数据加载缓存
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // If status is not determined, then we should ask for authorization.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {

    } else { // We do have authorization.
        // Start the standard location service.
        [self loadGeofenceCacheWithFileName:@"test"];
    }
}


-(void)loadGeofenceCacheWithFileName:(NSString *)fileName {
    
    //保存数据
    [self saveGeofenceCacheWithFileName:fileName];
    
    if ([CacheFile cache_file_exists:fileName]) {
        //取数据,
        NSData *unarchiveData = [CacheFile cache_file_get_nsdata:fileName];
        NSMutableArray<Geotification *> *arr = (NSMutableArray<Geotification *> *)[NSKeyedUnarchiver unarchiveObjectWithData:unarchiveData];
        [self addGeofences:arr];
    }
}

-(void)saveGeofenceCacheWithFileName:(NSString *)fileName
{
    //将获取到的数据保存到网络中
    NSString *geofencePath = [CacheFile cache_file_path:fileName];
    NSLog(@"当前的路径是%@",geofencePath);
    NSMutableArray<Geotification *> *geofenceArr = [NSMutableArray array];
    for (int i = 0;i < 6;i++) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
        if (i == 0) {
            coordinate = CLLocationCoordinate2DMake(39.9151500000, 116.4927700000);
        } else if (i == 1) {
            coordinate = CLLocationCoordinate2DMake(39.9087890000, 116.4954640000);
        } else if (i == 2) {
            coordinate = CLLocationCoordinate2DMake(39.9098100000, 116.4285700000);
        } else if (i == 3) {
            coordinate = CLLocationCoordinate2DMake(39.9770540000, 116.4175870000);
        } else if (i == 4) {
            coordinate = CLLocationCoordinate2DMake(40.0531090000, 116.4124640000);
        } else if (i == 5) {
            coordinate = CLLocationCoordinate2DMake(40.0569900000, 116.4103000000);
        }
        
        Geotification *geofence = [[Geotification alloc] initWithCoordinate:coordinate radius:100 identifier:[NSString stringWithFormat:@"indenti%d",i] note:[NSString stringWithFormat:@"note%d",i] eventType:OnEntry];
        [geofenceArr addObject:geofence];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:geofenceArr];
    [CacheFile cache_file_set_nsdata:fileName contents:data];
}

-(void)addGeofences:(NSMutableArray<Geotification*> *)geofences
{
    [geofences enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Geotification *geotification = (Geotification *)obj;
        NSLog(@"当前的值是%f，%f",geotification.coordinate.latitude,geotification.coordinate.longitude);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [manager addRegion:geotification];
//        });
        [manager addRegion:geotification];
    }];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [manager.locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
}

- (void)addRegion:(Geotification *)geotification {
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        // Create a new region based on the center of the map view.
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geotification.coordinate.latitude, geotification.coordinate.longitude);
        NSLog(@"当前添加的坐标点%f,%f",geotification.coordinate.latitude,geotification.coordinate.longitude);
        
        CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coord
                                                                        radius:600
                                                                    identifier:[NSString stringWithFormat:@"%f, %f", geotification.coordinate.latitude, geotification.coordinate.longitude]];
        newRegion.notifyOnEntry = YES;
        newRegion.notifyOnExit = YES;
        
        // Start monitoring the newly created region.
        [self.locationManager startMonitoringForRegion:newRegion];
        
    }
    else {
        NSLog(@"Region monitoring is not available.");
    }
}

// When the user has granted authorization, start the standard location service.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        // Start the standard location service.
        [self loadGeofenceCacheWithFileName:@"test"];
    }
}

// The device entered a monitored region.
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
    NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, event);
    
    [self updateWithEvent:[NSString stringWithFormat:@"进入区域%@",region.identifier]];
}

// The device exited a monitored region.
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, event);
    
    [self updateWithEvent:[NSString stringWithFormat:@"离开区域%@",region.identifier]];
}

// A monitoring error occurred for a region.
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, event);
    
    [self updateWithEvent:event];
}

- (void)updateWithEvent:(NSString *)event {
    [self writeTXT:event];
    // Add region event to the updates array.
    UILocalNotification *notification = [UILocalNotification new];
    [notification setAlertBody:event];
    [notification setSoundName:@"Default"];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)writeTXT:(NSString *)str
{
//    首先查找document的存储路径,并设定具体存储路径
    
    NSArray *pathArr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *strPath=[pathArr lastObject];
    
    NSString *strFinalPath=[NSString stringWithFormat:@"%@/myfile.txt",strPath];
    
    
    //    读取数据
    
    NSError *error = nil;
    NSString *readStr=[[NSString alloc]initWithContentsOfFile:strFinalPath encoding:NSUTF8StringEncoding error:&error];
    if (readStr == nil) {
        readStr = @"-\n-";
    }
    
    NSString *newstr = [NSString stringWithFormat:@"%@\n%@",readStr,str];

//    写入数据
    
    BOOL aResult=[newstr writeToFile:strFinalPath atomically:YES];
    
}

@end
