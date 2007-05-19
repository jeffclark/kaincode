/*
	iPod.h
	Author:		Kris Amico <macdev@krisamico.com>
	Revision:	1.1

	This header is a derivation of reverse engineering of the intellectual property of 
	Apple Computer, Inc. It is therefore only to be considered for informational or 
	entertainment purposes. Use of this informational material could be considered a 
	violation of the Digital Millenium Copyright Act.
	
	Use of the material herein implies agreement that destruction of property or data 
	resulting from said usage is not the responsibility of the material's author, point 
	of distribution, or of Apple Computer, Inc.
*/

#ifndef __iPod__
#define __iPod__

#include <CoreFoundation/CoreFoundation.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*
	iPod Types
*/
typedef const struct __iPod * iPodRef;
typedef const struct __iPodPreferences * iPodPreferencesRef;

/*
	iPod Errors
*/
typedef OSStatus iPodErr;

enum {
	kiPodErrNone			= 0,
	kiPodErrAnon0			= -25170,		
	kiPodErrAnon1			= -25171,		
	kiPodErrAnon2			= -25178		
};

/*
	Setting iPod preferences [apparently] affects various applications that make use of the iPod.
	Because these settings do not belong to you, fooling with them is ill advised.
*/
typedef UInt32 iPodPreferenceIndex;

enum {
	kiPodPrefConfigured			= 1,		/* effect of this flag is not yet clear */
	kiPodPrefEnableDiskMode		= 2,		/* [apparently] tells iTunes whether or not it should unmount after update */
	kiPodPrefNeedsSync			= 3,		/* [apparently] tells iSync whether it needs to sync to the iPod or not */
};


/*
	When registered for callbacks, you will receive notifications when events occur.
*/
typedef SInt32 iPodMessage;


enum {
	kiPodMsgAttached			= 1,		/* an iPod was just attached to the computer */
	kiPodMsgRemoved				= 2,		/* an iPod was just removed from the computer */
	kiPodMsgMounted				= 3,		/* an iPod was just mounted as a hard disk. msgData in the iPodServerCallback is a null-terminated C-string containing mount point path */
	kiPodMsgUnmounted			= 4,		/* a volume mounted from an attached iPod has just unmounted */
	kiPodMsgPrefsChanged		= 5,		/* the preferences of the referenced iPod have been set */
	kiPodMsgNameChanged			= 8			/* the name of the iPod was changed. msgData in the iPodServerCallback is a null-terminated C-string containing the new name */
};

typedef void (*iPodServerCallback)( iPodRef iPod, SInt32 msgCode, void* msgData, void* userInfo );

/*
	iPodGetTypeID
	
	Returns the core foundation type number for the iPodRef. Use this interface for typechecking.
*/
extern CFTypeID
iPodGetTypeID( void );

/*
	iPodPreferenceGetTypeID
	
	Returns the core foundation type number for the iPodPreferencfesRef. Use this interface for typechecking.
*/
extern CFTypeID
iPodPreferenceGetTypeID( void );

/*
	iPodCopyConnected
	
	Obtain an new array of iPodRef objects that represents the iPods connected to the Macintosh. 
	You are responsible for releasing this array.
*/
extern iPodErr
iPodCopyConnected( CFArrayRef* outArray );

/*
	iPodCopyMountpoint
	
	Obtain a path for a mounted iPod's mount point. If the hard drive of the iPod is not mounted, 
	this will return an error. A new CFURLRef is returned by reference. You are responsible for 
	releasing it.
*/
extern iPodErr
iPodCopyMountpoint(
	iPodRef iPod, 
	CFURLRef* outURL );

/*
	iPodCopyName
	
	Obtain the user-chosen name an iPod. A new CFString is returned by reference. You are 
	responsible for releasing it.
*/
extern iPodErr
iPodCopyName( 
	iPodRef iPod, 
	CFStringRef* outString );

/*
	iPodCopyRevision
	
	Obtain a string describing an iPod's revision. A new CFString is returned by reference. 
	You are responsible for releasing it.
*/
extern iPodErr
iPodCopyRevision( 
	iPodRef iPodRef, 
	CFStringRef* outString );

/*
	iPodGetUniqueID
	
	Obtain a wide integer that uniquely identifies an iPod.
*/
extern UInt64
iPodGetUniqueID( iPodRef iPod );

/*
	iPodCopyPreferences
	
	Obtain a copy of an iPod's settings. A new iPodPreferencesRef is returned by reference. 
	It is your responsibility to release it.
*/
extern iPodErr
iPodCopyPreferences( 
	iPodRef iPodRef, 
	iPodPreferencesRef* outPrefs );

/*
	iPodPreferenceGetValue
	
	Obtain the value of a given setting from an iPod's settings object.
*/
extern void
iPodPreferenceGetValue( 
	iPodPreferencesRef inPrefs, 
	iPodPreferenceIndex inPrefIndex, 
	Boolean* outValue );

/*
	iPodPreferenceSetValue
	
	Write a value for a given setting to an iPod's settings object.
*/
extern void
iPodPreferenceSetValue( 
	iPodPreferencesRef inPrefs, 
	iPodPreferenceIndex inPrefIndex, 
	const Boolean* inValue );

/*
	iPodSetPreferences
	
	Write settings to an iPod after changing them.
*/
extern OSStatus
iPodSetPreferences( 
	iPodRef iPodRef, 
	iPodPreferencesRef inPrefs );

/*
	iPodGetLockCount
	
	Obtain the number of locks that have been acquired for an iPod.
*/
extern CFIndex
iPodGetLockCount( iPodRef iPod );

/*
	iPodAquireLock
	
	Mount an iPod and prevent it from being unmounted while you are working with it.
*/
extern iPodErr
iPodAquireLock( iPodRef iPod );

/*
	iPodReleaseLock
	
	Relinquish a lock previously acquired with iPodAquireLock. If no locks remain, the iPod is 
	unmounted.
*/
extern iPodErr
iPodReleaseLock( iPodRef iPod );

/*
	iPodRegisterWithServer
	
	Install a callback for receiving messages of iPod-related events.
*/
extern iPodErr
iPodRegisterWithServer( CFRunLoopRef runloop, CFStringRef mode, iPodServerCallback callout, const void* userInfo );

/*
	iPodUnregisterFromServer
	
	Remove a callback previously installed with iPodRegisterWithServer to stop receiving messages 
	of iPod-related events.
*/
extern iPodErr
iPodUnregisterFromServer( void ); /* more than likely, this interface has arguments. This has yet to be investigated */

#if defined(__cplusplus)
	}
#endif

#endif /* __iPod__ */

