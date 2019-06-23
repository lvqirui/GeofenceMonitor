//
//  GeofenceMonitorManager.h
//  GeofenceMonitorDemo
//
//  Created by 吕其瑞 on 2017/12/19.
//  Copyright © 2017年 吕其瑞. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;
@import CoreLocation;

typedef enum : NSInteger {
    OnEntry = 0,
    OnExit
} EventType;

@interface Geotification : NSObject <NSCoding, MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, assign) EventType eventType;
@property (nonatomic, copy) NSString *storeName;  //商店信息

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius identifier:(NSString *)identifier note:(NSString *)note eventType:(EventType)eventType;

@end
