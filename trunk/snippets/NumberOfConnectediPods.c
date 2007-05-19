#import <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>

int NumberOfConnectediPods()
{
	int count = 0;
	CFMutableDictionaryRef myDict;
	io_iterator_t media_iterator;
	io_object_t device;
	
	myDict = IOServiceMatching("IOUSBDevice");
	if (myDict == NULL)
		return nil;
	
	if (IOServiceGetMatchingServices(kIOMasterPortDefault, myDict, &media_iterator) == KERN_SUCCESS)
	{
		while (device = IOIteratorNext(media_iterator))
		{
			CFMutableDictionaryRef props = NULL;
			if (IORegistryEntryCreateCFProperties(device, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS)
			{
				if (props != NULL)
				{
					CFStringRef productName = (CFStringRef)CFDictionaryGetValue(props, CFSTR("USB Product Name"));
					if (productName != NULL)
					{
						if (CFStringCompare(productName, CFSTR("iPod"), 0) == KERN_SUCCESS
						 	|| CFStringCompare(productName, CFSTR("iPod            "), 0) == KERN_SUCCESS)
						{
							count++;
						}
					}

					CFRelease(props);				
				}
			}
			
			IOObjectRelease(device);
		}
	}

	IOObjectRelease(media_iterator);
	
	return count;
}

int main()
{
	printf("Number of connectediPods: %d\n", NumberOfConnectediPods());
	return 0;
}