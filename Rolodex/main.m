 //
//  main.m
//  Rolodex
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
  [Parse setApplicationId:@"UXOEPJA0UFVFnupmpmDTrSleGqM1EyTGBFdyq9LT" 
                clientKey:@"JOTw7A2EkpUOfnFJTfv0pfEPFwZYdwtZzWW0do7P"];
  
  @autoreleasepool {
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
