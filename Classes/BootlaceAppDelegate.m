//
//  BootlaceAppDelegate.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright Nick Dawson 2010. All rights reserved.
//

#import "BootlaceAppDelegate.h"


@implementation BootlaceAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	commonData* sharedData = [commonData sharedData];
	commonFunctions *commonInstance = [[commonFunctions alloc] init];
	OpeniBootClass *opibInstance = [[OpeniBootClass alloc] init];
	
	//Check and setup working directory
	NSArray *homeDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	sharedData.workingDirectory = [[homeDirectory objectAtIndex:0] stringByAppendingPathComponent:@"Bootlace"];
	
	BOOL isDir;
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.workingDirectory isDirectory:&isDir]) {
		if(![[NSFileManager defaultManager] createDirectoryAtPath:sharedData.workingDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
			NSLog(@"Error: Create Bootlace working folder failed");
		}
	}
	
	//Read settings
	sharedData.firstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasRunOnce"];
	sharedData.secondLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasRunTwice"];
	sharedData.debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
	
	NSString *validKernelPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"validKernelPath"];
	NSString *validMD5 = [[NSUserDefaults standardUserDefaults] objectForKey:@"validMD5"];
	
	if(sharedData.debugMode) {
		DLog(@"Running in debug mode, using alternative servers");
	}
	
	//Setup variables
	sharedData.warningLive = NO;
	sharedData.bootlaceVersion = @"2.1.7";
	
	//Check the platform and iOS version
	[commonInstance getPlatform];
	[commonInstance getSystemVersion];
	
	//Dump nvram stuffs
	sharedData.opibBackupPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"NVRAM.plist.backup"];

	[opibInstance opibCheckInstalled];
	
	// Output current configuration
	DLog(@"Configuration");
	DLog(@"==========================================");
	DLog(@"console logfile = /var/tmp/Bootlace.log");
	DLog(@"==========================================");
	DLog(@"Version: %@", sharedData.bootlaceVersion);
	
	[commonInstance release];
		
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	if(!sharedData.firstLaunch) {
		FirstLaunchViewController *fullscreenController = [[FirstLaunchViewController alloc] init];
		[tabBarController presentModalViewController:fullscreenController animated:NO];
	} else if([validKernelPath length] > 0) {
		if(![validMD5 isEqualToString:[opibInstance opibKernelMD5:validKernelPath]]) {
			DLog(@"Failed MD5 check. Repatching kernel...");
			
			FirstLaunchViewController *fullscreenController = [[FirstLaunchViewController alloc] init];
			[tabBarController presentModalViewController:fullscreenController animated:NO];
		}				 
	}
	
	[opibInstance release];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)applicationWillTerminate:(UIApplication *)application {
	commonData* sharedData = [commonData sharedData];
	
	//Perform rudimentary cleanup so user can try kernel patch again
	if(sharedData.firstLaunch) {
		[[NSFileManager defaultManager] removeItemAtPath:sharedData.kernelCachePath error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:[sharedData.kernelCachePath stringByAppendingPathExtension:@"decrypted"] error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:[sharedData.kernelCachePath stringByAppendingPathExtension:@"decrypted.patched"] error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:[sharedData.kernelCachePath stringByAppendingPathExtension:@"encrypted"] error:nil];
	}
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

