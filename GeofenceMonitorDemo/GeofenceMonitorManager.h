//
//  GeofenceMonitorManager.h
//  GeofenceMonitorDemo
//
//  Created by 吕其瑞 on 2017/12/19.
//  Copyright © 2017年 吕其瑞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeofenceMonitorManager : NSObject

+(instancetype)shareInstance;

-(void)requestNetWorkForGeofences;

@end
