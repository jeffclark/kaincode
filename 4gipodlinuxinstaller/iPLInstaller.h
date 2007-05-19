//
//  iPLInstaller.h
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iPLPod;

typedef enum
{
	iPLInstallFull,
	iPLInstallKernelOnly,
	iPLInstallPodzillaOnly,
	iPLInstallKernelAndPodzillaOnly,
} iPLInstallType;

@interface iPLInstaller : NSObject
{
	id _delegate;
	iPLPod *_installerPod;
	NSString *_workingDir;
	BOOL _defaultBoot;
	iPLInstallType _installType;
	NSString *_podzillaPath, *_kernelPath;
	
	BOOL _working;
}

- (id)initWithDelegate:(id)delegate iPod:(iPLPod *)iPod bootToLinux:(BOOL)bootToLinux;

- (void)setInstallType:(iPLInstallType)installType;
- (void)setPodzillaPath:(NSString *)podzillaPath;
- (void)setKernelPath:(NSString *)kernelPath;

- (void)install;
- (void)uninstall;

- (BOOL)isWorking;

@end
