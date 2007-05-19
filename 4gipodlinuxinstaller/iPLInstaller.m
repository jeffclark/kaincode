//
//  iPLInstaller.m
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "iPLInstaller.h"
#import "iPLPod.h"
#import "NSTaskXtra.h"

@interface iPLInstaller (priv)

- (iPLPod *)installerPod;
- (iPLInstallType)installType;
- (void)setStatus:(NSString *)status;

// install and uninstall
- (void)doInstall;
- (void)doUninstall;

// step 1
- (void)backupiPod;

// step 2
- (void)installKernel;
- (void)extractAppleOS;
- (void)createNewOSImage;
- (void)copyNewImageToiPod;
- (void)copyKernelModules;

// step 3
- (void)installFilesystem;

// step 4
- (void)installPodzilla;

// extra
- (void)patchRC;

@end;

@implementation iPLInstaller

- (id)initWithDelegate:(id)delegate iPod:(iPLPod *)iPod bootToLinux:(BOOL)bootToLinux
{
	if (self = [super init])
	{
		_delegate = [delegate retain];
		_installerPod = [iPod retain];
		_defaultBoot = !bootToLinux;
		_working = NO;
		_installType = iPLInstallFull;
		_podzillaPath = nil;
		_kernelPath = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[_delegate release];
	[_installerPod release];
	[_workingDir release];
	[_podzillaPath release];
	[_kernelPath release];
	
	[super dealloc];
}

- (iPLPod *)installerPod
{
	return _installerPod;
}

- (iPLInstallType)installType
{
	return _installType;
}

#pragma mark -

- (void)setInstallType:(iPLInstallType)installType
{
	_installType = installType;
}

- (void)setPodzillaPath:(NSString *)podzillaPath
{
	if (_podzillaPath != podzillaPath)
	{
		[_podzillaPath release];
		_podzillaPath = [podzillaPath retain];
	}
}

- (void)setKernelPath:(NSString *)kernelPath
{
	if (_kernelPath != kernelPath)
	{
		[_kernelPath release];
		_kernelPath = [kernelPath retain];
	}
}

- (void)uninstall
{
	_working = YES;
	[NSThread detachNewThreadSelector:@selector(doUninstall) toTarget:self withObject:nil];
}

- (void)install;
{
	_working = YES;
	[NSThread detachNewThreadSelector:@selector(doInstall) toTarget:self withObject:nil];
}

- (BOOL)isWorking
{
	return _working;
}

#pragma mark -

- (void)setStatus:(NSString *)status
{
	if (status == nil)
		_working = NO;
	
	SEL sel = @selector(handleUpdatedInstallationStatus:);
	if ([_delegate respondsToSelector:sel])
		[_delegate performSelectorOnMainThread:sel withObject:status waitUntilDone:YES];
}

#pragma mark --Uninstall--

- (void)doUninstall
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[_workingDir release];
	_workingDir = [[[@"~/Library/Application Support/4G iPodLinux Installer" stringByAppendingPathComponent:[[self installerPod] name]] stringByExpandingTildeInPath] retain];
	
	NSFileManager *fm = [NSFileManager defaultManager];

	[self setStatus:NSLocalizedStringFromTable(@"Restoring Firmware", nil, nil)];
	
	NSString *backup = [_workingDir stringByAppendingPathComponent:@"ipod_os_partition_backup"];
	if ([fm fileExistsAtPath:backup])
	{
		NSArray *args = [NSArray arrayWithObjects:
			[NSString stringWithFormat:@"if=%@", backup],
			[NSString stringWithFormat:@"of=/dev/disk%ds2", [[self installerPod] deviceID]],
			nil];
		NSData *outputData = [NSTask runTaskWithLaunchPath:@"/bin/dd" arguments:args inputData:nil];
		NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
	}
	else
	{
		NSLog(@"backup doesn't exist!");
	}
	
	[self setStatus:NSLocalizedStringFromTable(@"Removing Files", nil, nil)];

	BOOL removeFiles = YES;
	if (removeFiles)
	{
		NSString *uninstallFiles = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"uninstallFiles" ofType:@"txt"]];
		if (uninstallFiles)
		{
			NSEnumerator *filesEnum = [[uninstallFiles componentsSeparatedByString:@"\n"] objectEnumerator];
			NSString *file;
			while (file = [filesEnum nextObject])
			{
				NSString *fullPath = [[[self installerPod] path] stringByAppendingPathComponent:file];
				if ([fm fileExistsAtPath:fullPath])
					[fm removeFileAtPath:fullPath handler:nil];
			}
		}
	}
	
	[self setStatus:nil]; // done

	[pool release];
}

#pragma mark -- Install --

- (void)doInstall
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSString *applicationSupport = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
	if (![fm fileExistsAtPath:applicationSupport])
		[fm createDirectoryAtPath:applicationSupport attributes:nil];
	
	NSString *iPLInstallerDir = [applicationSupport stringByAppendingPathComponent:@"4G iPodLinux Installer"];
	if (![fm fileExistsAtPath:iPLInstallerDir])
		[fm createDirectoryAtPath:iPLInstallerDir attributes:nil];

	NSString *workingDir = [iPLInstallerDir stringByAppendingPathComponent:[[self installerPod] name]];
	if (![fm fileExistsAtPath:workingDir])
		[fm createDirectoryAtPath:workingDir attributes:nil];
	
	// iPod/Recordings directory
	NSString *ipodRecordingsDirectory = [[[self installerPod] path] stringByAppendingPathComponent:@"Recordings"];
	if (![fm fileExistsAtPath:ipodRecordingsDirectory])
		[fm createDirectoryAtPath:ipodRecordingsDirectory attributes:nil];
	
	[_workingDir release];
	_workingDir = [workingDir retain];
	
	switch ([self installType])
	{
		case iPLInstallFull:
		{
			[self backupiPod];
			[self installKernel];
			[self installFilesystem];
			[self installPodzilla];
			[self patchRC];
			break;
		}
			
		case iPLInstallKernelOnly:
		{
			[self installKernel];
			break;
		}
			
		case iPLInstallPodzillaOnly:
		{
			[self installPodzilla];
			break;
		}
		
		case iPLInstallKernelAndPodzillaOnly:
		{
			[self installKernel];
			[self installPodzilla];
			break;
		}

		default:
			break;
	}
	
	[self setStatus:nil]; // done
	
	[pool release];
}

#pragma mark Step 1

- (void)backupiPod
{
	[self setStatus:NSLocalizedStringFromTable(@"Backup", nil, nil)];
	
	NSArray *args = [NSArray arrayWithObjects:
		[NSString stringWithFormat:@"if=/dev/disk%ds2", [[self installerPod] deviceID]],
		[NSString stringWithFormat:@"of=%@", [_workingDir stringByAppendingPathComponent:@"ipod_os_partition_backup"]],
		nil];
	NSData *outputData = [NSTask runTaskWithLaunchPath:@"/bin/dd" arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
}

#pragma mark Step 2

- (void)installKernel
{
	if (_kernelPath == nil)
		_kernelPath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/2005-08-23-kernel.bin"] retain];
	
	[self extractAppleOS];
}

- (void)extractAppleOS
{
	[self setStatus:NSLocalizedStringFromTable(@"Installing iPodLinux Kernel", nil, nil)];
	
	NSArray *args = [NSArray arrayWithObjects:
		@"-3",
		@"-o",
		[_workingDir stringByAppendingPathComponent:@"apple_os.bin"],
		@"-e",
		@"0",
		[_workingDir stringByAppendingPathComponent:@"ipod_os_partition_backup"],
		nil];
	NSString *launchPath = [[NSBundle mainBundle] pathForResource:@"make_fw" ofType:nil inDirectory:@"InstallationStuff"];
	NSData *outputData = [NSTask runTaskWithLaunchPath:launchPath arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
	
	[self createNewOSImage];
}

- (void)createNewOSImage
{
	NSArray *args = nil;
	if (_defaultBoot)
	{
		args = [NSArray arrayWithObjects:
			@"-3",
			@"-o",
			[_workingDir stringByAppendingPathComponent:@"my_sw.bin"],
			@"-i",
			[_workingDir stringByAppendingPathComponent:@"apple_os.bin"],
			@"-l",
			_kernelPath,
			[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/loader.bin"],
			nil];
	}
	else
	{
		args = [NSArray arrayWithObjects:
			@"-3",
			@"-o",
			[_workingDir stringByAppendingPathComponent:@"my_sw.bin"],
			@"-l",
			_kernelPath,
			@"-i",
			[_workingDir stringByAppendingPathComponent:@"apple_os.bin"],
			[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/loader.bin"],
			nil];
	}
	NSString *launchPath = [[NSBundle mainBundle] pathForResource:@"make_fw" ofType:nil inDirectory:@"InstallationStuff"];
	NSData *outputData = [NSTask runTaskWithLaunchPath:launchPath arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
	
	[self copyNewImageToiPod];
}

- (void)copyNewImageToiPod
{
	NSArray *args = [NSArray arrayWithObjects:
		[NSString stringWithFormat:@"if=%@", [_workingDir stringByAppendingPathComponent:@"my_sw.bin"]],
		[NSString stringWithFormat:@"of=/dev/disk%ds2", [[self installerPod] deviceID]],
		nil];
	NSData *outputData = [NSTask runTaskWithLaunchPath:@"/bin/dd" arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
	
	[self copyKernelModules];
}

- (void)copyKernelModules
{
	NSArray *args = [NSArray arrayWithObjects:
		@"-r",
		[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/uclinux-2.4.24-ipod2/lib"],
		[[self installerPod] path],
		nil];
	NSData *outputData = [NSTask runTaskWithLaunchPath:@"/bin/cp" arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);	
}

#pragma mark Step 3

- (void)installFilesystem
{
	[self setStatus:NSLocalizedStringFromTable(@"Installing File System", nil, nil)];

	NSArray *args = [NSArray arrayWithObjects:
		@"zxf",
		[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/ipod_fs_040403.tar.gz"],
		nil];
	NSData *outputData = [NSTask runTaskWithLaunchPath:@"/usr/bin/tar" arguments:args inputData:nil currentDirectory:[[self installerPod] path]];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
}

#pragma mark Step 4

- (void)installPodzilla
{
	if (_podzillaPath == nil)
		_podzillaPath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/2005-08-23-podzilla"] retain];
	
	[self setStatus:NSLocalizedStringFromTable(@"Installing Podzilla", nil, nil)];
	
	NSString *iPodPodzillaPath = [[[self installerPod] path] stringByAppendingPathComponent:@"sbin/podzilla"];
	
	// copy podzilla
	NSArray *args = [NSArray arrayWithObjects:
		_podzillaPath,
		iPodPodzillaPath,
		nil];
	NSData *outputData = [NSTask runTaskWithLaunchPath:@"/bin/cp" arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@1: %@", NSStringFromSelector(_cmd), output);
	
	// chmod 755 podzilla
	args = [NSArray arrayWithObjects:
		@"755",
		iPodPodzillaPath,
		nil];
	outputData = [NSTask runTaskWithLaunchPath:@"/bin/chmod" arguments:args inputData:nil];
	output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@2: %@", NSStringFromSelector(_cmd), output);
}

#pragma mark extra

- (void)patchRC
{
	NSArray *args = [NSArray arrayWithObjects:
		[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InstallationStuff/rc_patched"],
		[[[self installerPod] path] stringByAppendingPathComponent:@"etc/rc"],
		nil];
	NSData *outputData = [NSTask runTaskWithLaunchPath:@"/bin/cp" arguments:args inputData:nil];
	NSString *output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), output);
}

@end
