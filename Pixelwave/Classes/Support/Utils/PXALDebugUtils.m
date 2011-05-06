/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#define PX_AL_DEBUG_DONT_CHANGE

#import "PXALDebugUtils.h"

#include <OpenAL/al.h>
#include <OpenAL/alc.h>

#import "PXDebug.h"

ALenum pxALDebugLastError = 0;
ALCenum pxALCDebugLastError = 0;

NSString *_alGetErrorString(ALenum error)
{
	if (error == AL_NO_ERROR)
	{
		return [NSString stringWithString:@"no error"];
	}

	switch (error)
	{
		case AL_INVALID_NAME:
			return [NSString stringWithString:@"invalid name"];
		case AL_INVALID_ENUM:
			return [NSString stringWithString:@"invalid enum"];
		case AL_INVALID_VALUE:
			return [NSString stringWithString:@"invalid value"];
		case AL_INVALID_OPERATION:
			return [NSString stringWithString:@"invalid operation"];
		case AL_OUT_OF_MEMORY:
			return [NSString stringWithString:@"out of memory"];
		case 0xFFFFFFFF:
			return [NSString stringWithString:@"too many sounds playing"];
		default:
			return [NSString stringWithString:@"unknown error"];
	}

	return nil;
}

ALenum _alBeginDebug(NSString *value1)
{
	ALenum error = alGetError();
	
	if (error != AL_NO_ERROR)
	{
		PXDebugLog(@"%@ lingering error - ErrorID:0x%X, info:%@",
				   value1,
				   error,
				   _alGetErrorString(error));
	}
	
	return error;
}
ALenum _alEndDebug(NSString *value1)
{
	ALenum error = alGetError();
	
	if (error != AL_NO_ERROR)
	{
		PXDebugLog(@"%@ error - ErrorID:0x%X, info:%@",
				   value1,
				   error,
				   _alGetErrorString(error));
	}
	
	pxALDebugLastError = error;
	
	return error;
}

void _alEnable (ALenum capability)
{
	_alBeginDebug(@"alEnable");
	alEnable(capability);
	_alEndDebug(@"alEnable");
}

void _alDisable (ALenum capability)
{
	_alBeginDebug(@"alDisable");
	alDisable(capability);
	_alEndDebug(@"alDisable");
}

ALboolean _alIsEnabled (ALenum capability)
{
	_alBeginDebug(@"alIsEnabled");
	ALboolean ret = alIsEnabled(capability);
	_alEndDebug(@"alIsEnabled");
	
	return ret;
}

const ALchar* _alGetString (ALenum param)
{
	_alBeginDebug(@"alGetString");
	const ALchar* ret = alGetString(param);
	_alEndDebug(@"alGetString");
	
	return ret;
}

void _alGetBooleanv (ALenum param, ALboolean* data)
{
	_alBeginDebug(@"alGetBooleanv");
	alGetBooleanv(param, data);
	_alEndDebug(@"alGetBooleanv");
}

void _alGetIntegerv (ALenum param, ALint* data)
{
	_alBeginDebug(@"alGetIntegerv");
	alGetIntegerv(param, data);
	_alEndDebug(@"alGetIntegerv");
}

void _alGetFloatv (ALenum param, ALfloat* data)
{
	_alBeginDebug(@"alGetFloatv");
	alGetFloatv(param, data);
	_alEndDebug(@"alGetFloatv");
}

void _alGetDoublev (ALenum param, ALdouble* data)
{
	_alBeginDebug(@"alGetDoublev");
	alGetDoublev(param, data);
	_alEndDebug(@"alGetDoublev");
}

ALboolean _alGetBoolean (ALenum param)
{
	_alBeginDebug(@"alGetBoolean");
	ALboolean ret = alGetBoolean(param);
	_alEndDebug(@"alGetBoolean");
	return ret;
}

ALint _alGetInteger (ALenum param)
{
	_alBeginDebug(@"alGetInteger");
	ALint ret = alGetInteger(param);
	_alEndDebug(@"alGetInteger");
	
	return ret;
}

ALfloat _alGetFloat (ALenum param)
{
	_alBeginDebug(@"alGetFloat");
	ALfloat ret = alGetFloat(param);
	_alEndDebug(@"alGetFloat");
	
	return ret;
}

ALdouble _alGetDouble (ALenum param)
{
	_alBeginDebug(@"alGetDouble");
	ALdouble ret = alGetDouble(param);
	_alEndDebug(@"alGetDouble");
	
	return ret;
}

ALenum _alGetError (void)
{
	return pxALDebugLastError | alGetError();
}

ALboolean _alIsExtensionPresent (const ALchar* extname)
{
	_alBeginDebug(@"alIsExtensionPresent");
	ALboolean ret = alIsExtensionPresent(extname);
	_alEndDebug(@"alIsExtensionPresent");
	
	return ret;
}

void* _alGetProcAddress (const ALchar* fname)
{
	_alBeginDebug(@"alGetProcAddress");
	void* ret = alGetProcAddress(fname);
	_alEndDebug(@"alGetProcAddress");
	
	return ret;
}

ALenum _alGetEnumValue (const ALchar* ename)
{
	_alBeginDebug(@"alGetEnumValue");
	ALenum ret = alGetEnumValue(ename);
	_alEndDebug(@"alGetEnumValue");
	
	return ret;
}

void _alListenerf (ALenum param, ALfloat value)
{
	_alBeginDebug(@"alListenerf");
	alListenerf(param, value);
	_alEndDebug(@"alListenerf");
}

void _alListener3f (ALenum param, ALfloat value1, ALfloat value2, ALfloat value3)
{
	_alBeginDebug(@"alListener3f");
	alListener3f(param, value1, value2, value3);
	_alEndDebug(@"alListener3f");
}

void _alListenerfv (ALenum param, const ALfloat* values)
{
	_alBeginDebug(@"alListenerfv");
	alListenerfv(param, values);
	_alEndDebug(@"alListenerfv");
}

void _alListeneri (ALenum param, ALint value)
{
	_alBeginDebug(@"alListeneri");
	alListeneri(param, value);
	_alEndDebug(@"alListeneri");
}

void _alListener3i (ALenum param, ALint value1, ALint value2, ALint value3)
{
	_alBeginDebug(@"alListener3i");
	alListener3i(param, value1, value2, value3);
	_alEndDebug(@"alListener3i");
}

void _alListeneriv (ALenum param, const ALint* values)
{
	_alBeginDebug(@"alListeneriv");
	alListeneriv(param, values);
	_alEndDebug(@"alListeneriv");
}

void _alGetListenerf (ALenum param, ALfloat* value)
{
	_alBeginDebug(@"alGetListenerf");
	alGetListenerf(param, value);
	_alEndDebug(@"alGetListenerf");
}

void _alGetListener3f (ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3)
{
	_alBeginDebug(@"alGetListener3f");
	alGetListener3f(param, value1, value2, value3);
	_alEndDebug(@"alGetListener3f");
}

void _alGetListenerfv (ALenum param, ALfloat* values)
{
	_alBeginDebug(@"alGetListenerfv");
	alGetListenerfv(param, values);
	_alEndDebug(@"alGetListenerfv");
}

void _alGetListeneri (ALenum param, ALint* value)
{
	_alBeginDebug(@"alGetListeneri");
	alGetListeneri(param, value);
	_alEndDebug(@"alGetListeneri");
}

void _alGetListener3i (ALenum param, ALint *value1, ALint *value2, ALint *value3)
{
	_alBeginDebug(@"alGetListener3i");
	alGetListener3i(param, value1, value2, value3);
	_alEndDebug(@"alGetListener3i");
}

void _alGetListeneriv (ALenum param, ALint* values)
{
	_alBeginDebug(@"alGetListeneriv");
	alGetListeneriv(param, values);
	_alEndDebug(@"alGetListeneriv");
}

void _alGenSources (ALsizei n, ALuint* sources)
{
	_alBeginDebug(@"alGenSources");
	alGenSources(n, sources);
	_alEndDebug(@"alGenSources");
}

void _alDeleteSources (ALsizei n, const ALuint* sources)
{
	_alBeginDebug(@"alDeleteSources");
	alDeleteSources(n, sources );
	_alEndDebug(@"alDeleteSources");
}

ALboolean _alIsSource (ALuint sid)
{
	_alBeginDebug(@"alIsSource");
	ALboolean ret = alIsSource(sid);
	_alEndDebug(@"alIsSource");
	
	return ret;
}

void _alSourcef (ALuint sid, ALenum param, ALfloat value)
{
	_alBeginDebug(@"alSourcef");
	alSourcef(sid, param, value);
	_alEndDebug(@"alSourcef");
}

void _alSource3f (ALuint sid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3)
{
	_alBeginDebug(@"alSource3f");
	alSource3f(sid, param, value1, value2, value3);
	_alEndDebug(@"alSource3f");
}

void _alSourcefv (ALuint sid, ALenum param, const ALfloat* values)
{
	_alBeginDebug(@"alSourcefv");
	alSourcefv(sid, param, values);
	_alEndDebug(@"alSourcefv");
}

void _alSourcei (ALuint sid, ALenum param, ALint value)
{
	_alBeginDebug(@"alSourcei");
	alSourcei(sid, param, value);
	_alEndDebug(@"alSourcei");
}

void _alSource3i (ALuint sid, ALenum param, ALint value1, ALint value2, ALint value3)
{
	_alBeginDebug(@"alSource3i");
	alSource3i(sid, param, value1, value2, value3);
	_alEndDebug(@"alSource3i");
}

void _alSourceiv (ALuint sid, ALenum param, const ALint* values)
{
	_alBeginDebug(@"alSourceiv");
	alSourceiv(sid, param, values);
	_alEndDebug(@"alSourceiv");
}

void _alGetSourcef (ALuint sid, ALenum param, ALfloat* value)
{
	_alBeginDebug(@"alGetSourcef");
	alGetSourcef(sid, param, value);
	_alEndDebug(@"alGetSourcef");
}

void _alGetSource3f (ALuint sid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3)
{
	_alBeginDebug(@"alGetSource3f");
	alGetSource3f(sid, param, value1, value2, value3);
	_alEndDebug(@"alGetSource3f");
}

void _alGetSourcefv (ALuint sid, ALenum param, ALfloat* values)
{
	_alBeginDebug(@"alGetSourcefv");
	alGetSourcefv(sid, param, values);
	_alEndDebug(@"alGetSourcefv");
}

void _alGetSourcei (ALuint sid,  ALenum param, ALint* value)
{
	_alBeginDebug(@"alGetSourcei");
	alGetSourcei(sid, param, value);
	_alEndDebug(@"alGetSourcei");
}

void _alGetSource3i (ALuint sid, ALenum param, ALint* value1, ALint* value2, ALint* value3)
{
	_alBeginDebug(@"alGetSource3i");
	alGetSource3i(sid, param, value1, value2, value3);
	_alEndDebug(@"alGetSource3i");
}

void _alGetSourceiv (ALuint sid,  ALenum param, ALint* values)
{
	_alBeginDebug(@"alGetSourceiv");
	alGetSourceiv(sid, param, values);
	_alEndDebug(@"alGetSourceiv");
}

void _alSourcePlayv (ALsizei ns, const ALuint *sids)
{
	_alBeginDebug(@"alSourcePlayv");
	alSourcePlayv(ns, sids);
	_alEndDebug(@"alSourcePlayv");
}

void _alSourceStopv (ALsizei ns, const ALuint *sids)
{
	_alBeginDebug(@"alSourceStopv");
	alSourceStopv(ns, sids);
	_alEndDebug(@"alSourceStopv");
}

void _alSourceRewindv (ALsizei ns, const ALuint *sids)
{
	_alBeginDebug(@"alSourceRewindv");
	alSourceRewindv(ns, sids);
	_alEndDebug(@"alSourceRewindv");
}

void _alSourcePausev (ALsizei ns, const ALuint *sids)
{
	_alBeginDebug(@"alSourcePausev");
	alSourcePausev(ns, sids);
	_alEndDebug(@"alSourcePausev");
}

void _alSourcePlay (ALuint sid)
{
	_alBeginDebug(@"alSourcePlay");
	alSourcePlay(sid);
	_alEndDebug(@"alSourcePlay");
}

void _alSourceStop (ALuint sid)
{
	_alBeginDebug(@"alSourceStop");
	alSourceStop(sid);
	_alEndDebug(@"alSourceStop");
}

void _alSourceRewind (ALuint sid)
{
	_alBeginDebug(@"alSourceRewind");
	alSourceRewind(sid);
	_alEndDebug(@"alSourceRewind");
}

void _alSourcePause (ALuint sid)
{
	_alBeginDebug(@"alSourcePause");
	alSourcePause(sid);
	_alEndDebug(@"alSourcePause");
}

void _alSourceQueueBuffers (ALuint sid, ALsizei numEntries, const ALuint *bids)
{
	_alBeginDebug(@"alSourceQueueBuffers");
	alSourceQueueBuffers(sid, numEntries, bids);
	_alEndDebug(@"alSourceQueueBuffers");
}

void _alSourceUnqueueBuffers (ALuint sid, ALsizei numEntries, ALuint *bids)
{
	_alBeginDebug(@"alSourceUnqueueBuffers");
	alSourceUnqueueBuffers(sid, numEntries, bids);
	_alEndDebug(@"alSourceUnqueueBuffers");
}

void _alGenBuffers (ALsizei n, ALuint* buffers)
{
	_alBeginDebug(@"alGenBuffers");
	alGenBuffers(n, buffers);
	_alEndDebug(@"alGenBuffers");
}

void _alDeleteBuffers (ALsizei n, const ALuint* buffers)
{
	_alBeginDebug(@"alDeleteBuffers");
	alDeleteBuffers(n, buffers);
	_alEndDebug(@"alDeleteBuffers");
}

ALboolean _alIsBuffer (ALuint bid)
{
	_alBeginDebug(@"alIsBuffer");
	ALboolean ret = alIsBuffer(bid);
	_alEndDebug(@"alIsBuffer");
	
	return ret;
}

void _alBufferData (ALuint bid, ALenum format, const ALvoid* data, ALsizei size, ALsizei freq)
{
	_alBeginDebug(@"alBufferData");
	alBufferData(bid, format, data, size, freq);
	_alEndDebug(@"alBufferData");
}

void _alBufferf (ALuint bid, ALenum param, ALfloat value)
{
	_alBeginDebug(@"alBufferf");
	alBufferf(bid, param, value);
	_alEndDebug(@"alBufferf");
}

void _alBuffer3f (ALuint bid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3)
{
	_alBeginDebug(@"alBuffer3f");
	alBuffer3f(bid, param, value1, value2, value3);
	_alEndDebug(@"alBuffer3f");
}

void _alBufferfv (ALuint bid, ALenum param, const ALfloat* values)
{
	_alBeginDebug(@"alBufferfv");
	alBufferfv(bid, param, values);
	_alEndDebug(@"alBufferfv");
}

void _alBufferi (ALuint bid, ALenum param, ALint value)
{
	_alBeginDebug(@"alBufferi");
	alBufferi(bid, param, value);
	_alEndDebug(@"alBufferi");
}

void _alBuffer3i (ALuint bid, ALenum param, ALint value1, ALint value2, ALint value3)
{
	_alBeginDebug(@"alBuffer3i");
	alBuffer3i(bid, param, value1, value2, value3);
	_alEndDebug(@"alBuffer3i");
}

void _alBufferiv (ALuint bid, ALenum param, const ALint* values)
{
	_alBeginDebug(@"alBufferiv");
	alBufferiv(bid, param, values);
	_alEndDebug(@"alBufferiv");
}

void _alGetBufferf (ALuint bid, ALenum param, ALfloat* value)
{
	_alBeginDebug(@"alGetBufferf");
	alGetBufferf(bid, param, value);
	_alEndDebug(@"alGetBufferf");
}

void _alGetBuffer3f (ALuint bid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3)
{
	_alBeginDebug(@"alGetBuffer3f");
	alGetBuffer3f(bid, param, value1, value2, value3);
	_alEndDebug(@"alGetBuffer3f");
}

void _alGetBufferfv (ALuint bid, ALenum param, ALfloat* values)
{
	_alBeginDebug(@"alGetBufferfv");
	alGetBufferfv(bid, param, values);
	_alEndDebug(@"alGetBufferfv");
}

void _alGetBufferi (ALuint bid, ALenum param, ALint* value)
{
	_alBeginDebug(@"alGetBufferi");
	alGetBufferi(bid, param, value);
	_alEndDebug(@"alGetBufferi");
}

void _alGetBuffer3i (ALuint bid, ALenum param, ALint* value1, ALint* value2, ALint* value3)
{
	_alBeginDebug(@"alGetBuffer3i");
	alGetBuffer3i(bid, param, value1, value2, value3);
	_alEndDebug(@"alGetBuffer3i");
}

void _alGetBufferiv (ALuint bid, ALenum param, ALint* values)
{
	_alBeginDebug(@"alGetBufferiv");
	alGetBufferiv(bid, param, values);
	_alEndDebug(@"alGetBufferiv");
}

void _alDopplerFactor (ALfloat value)
{
	_alBeginDebug(@"alDopplerFactor");
	alDopplerFactor(value);
	_alEndDebug(@"alDopplerFactor");
}

void _alDopplerVelocity (ALfloat value)
{
	_alBeginDebug(@"alDopplerVelocity");
	alDopplerVelocity(value);
	_alEndDebug(@"alDopplerVelocity");
}

void _alSpeedOfSound (ALfloat value)
{
	_alBeginDebug(@"alSpeedOfSound");
	alSpeedOfSound(value);
	_alEndDebug(@"alSpeedOfSound");
}

void _alDistanceModel (ALenum distanceModel)
{
	_alBeginDebug(@"alDistanceModel");
	alDistanceModel(distanceModel);
	_alEndDebug(@"alDistanceModel");
}



NSString *_alcGetErrorString(ALCenum error)
{
	if (error == ALC_NO_ERROR)
	{
		return [NSString stringWithString:@"no error"];
	}
	
	switch (error)
	{
		case ALC_INVALID_DEVICE:
			return [NSString stringWithString:@"invalid device"];
		case ALC_INVALID_CONTEXT:
			return [NSString stringWithString:@"invalid context"];
		case ALC_INVALID_ENUM:
			return [NSString stringWithString:@"invalid enum"];
		case ALC_INVALID_VALUE:
			return [NSString stringWithString:@"invalid value"];
		case ALC_OUT_OF_MEMORY:
			return [NSString stringWithString:@"out of memory"];
		default:
			return [NSString stringWithString:@"unknown error"];
	}
	
	return nil;
}

ALCenum _alcBeginDebug(ALCdevice *device, NSString *value1)
{
	ALCenum error = alcGetError(device);
	
	if (error != ALC_NO_ERROR)
	{
		PXDebugLog(@"%@ lingering error - ErrorID:0x%X, info:%@",
				   value1,
				   error,
				   _alcGetErrorString(error));
	}
	
	return error;
}
ALCenum _alcEndDebug(ALCdevice *device, NSString *value1)
{
	ALCenum error = alcGetError(device);
	
	if (error != ALC_NO_ERROR)
	{
		PXDebugLog(@"%@ error - ErrorID:0x%X, info:%@",
				   value1,
				   error,
				   _alcGetErrorString(error));
	}
	
	pxALCDebugLastError = error;
	return error;
}


ALCcontext *    _alcCreateContext(ALCdevice *device, const ALCint* attrlist)
{
	_alcBeginDebug(device, @"alcCreateContext");
	ALCcontext *ret = alcCreateContext(device, attrlist);
	_alcEndDebug(device, @"alcCreateContext");
	
	return ret;
}
ALCboolean      _alcMakeContextCurrent(_ALCcontext *context)
{
	//	_alcBeginDebug(@"alcMakeContextCurrent");
	ALCboolean ret = alcMakeContextCurrent(context);
	//	_alcEndDebug(@"alcMakeContextCurrent");
	
	return ret;
}
void            _alcProcessContext(ALCcontext *context)
{
	//	_alcBeginDebug(@"alcProcessContext");
	alcProcessContext(context);
	//	_alcEndDebug(@"alcProcessContext");
}
void            _alcSuspendContext(ALCcontext *context)
{
	//	_alcBeginDebug(@"alcSuspendContext");
	alcSuspendContext(context);
	//	_alcEndDebug(@"alcSuspendContext");
}
void            _alcDestroyContext(ALCcontext *context)
{
	//	_alcBeginDebug(@"alcDestroyContext");
	alcDestroyContext(context);
	//	_alcEndDebug(@"alcDestroyContext");
}
ALCcontext *    _alcGetCurrentContext(void)
{
	//	_alcBeginDebug(@"alcGetCurrentContext");
	ALCcontext *ret = alcGetCurrentContext( );
	//	_alcEndDebug(@"alcGetCurrentContext");
	
	return ret;
}
ALCdevice*      _alcGetContextsDevice(ALCcontext *context)
{
	//	_alcBeginDebug(@"alcGetContextsDevice");
	_ALCdevice *ret = alcGetContextsDevice(context);
	//	_alcEndDebug(@"alcGetContextsDevice");
	
	return ret;
}
ALCdevice *     _alcOpenDevice(const ALCchar *devicename)
{
	//	_alcBeginDebug(@"alcOpenDevice");
	ALCdevice *ret = alcOpenDevice(devicename);
	_alcEndDebug(ret, @"alcOpenDevice");
	
	return ret;
}
ALCboolean      _alcCloseDevice(ALCdevice *device)
{
	_alcBeginDebug(device, @"alcCloseDevice");
	ALCboolean ret = alcCloseDevice(device);
	_alcEndDebug(device, @"alcCloseDevice");
	
	return ret;
}
_ALCenum         _alcGetError(ALCdevice *device)
{
	return pxALCDebugLastError | alcGetError(device);
}
_ALCboolean      _alcIsExtensionPresent(ALCdevice *device, const ALCchar *extname)
{
	_alcBeginDebug(device, @"alcIsExtensionPresent");
	_ALCboolean ret = alcIsExtensionPresent(device, extname);
	_alcEndDebug(device, @"alcIsExtensionPresent");
	
	return ret;
}
void  *         _alcGetProcAddress(ALCdevice *device, const ALCchar *funcname)
{
	_alcBeginDebug(device, @"alcGetProcAddress");
	void *ret = alcGetProcAddress(device, funcname);
	_alcEndDebug(device, @"alcGetProcAddress");
	
	return ret;
}
ALCenum         _alcGetEnumValue(ALCdevice *device, const ALCchar *enumname)
{
	_alcBeginDebug(device, @"alcGetEnumValue");
	ALCenum ret = alcGetEnumValue(device, enumname);
	_alcEndDebug(device, @"alcGetEnumValue");
	
	return ret;
}
const ALCchar * _alcGetString(ALCdevice *device, ALCenum param)
{
	_alcBeginDebug(device, @"alcGetString");
	const ALCchar *ret = alcGetString(device, param);
	_alcEndDebug(device, @"alcGetString");
	
	return ret;
}
void            _alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *data)
{
	_alcBeginDebug(device, @"alcGetIntegerv");
	alcGetIntegerv(device, param, size, data);
	_alcEndDebug(device, @"alcGetIntegerv");
}
ALCdevice*      _alcCaptureOpenDevice(const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize)
{
	//_alcBeginDebug(@"alcCaptureOpenDevice");
	ALCdevice *ret = alcCaptureOpenDevice(devicename, frequency, format, buffersize);
	_alcEndDebug(ret, @"alcCaptureOpenDevice");
	
	return ret;
}
ALCboolean      _alcCaptureCloseDevice(ALCdevice *device)
{
	_alcBeginDebug(device, @"alcCaptureCloseDevice");
	ALCboolean ret = alcCaptureCloseDevice(device);
	_alcEndDebug(device, @"alcCaptureCloseDevice");
	
	return ret;
}
void            _alcCaptureStart(ALCdevice *device)
{
	_alcBeginDebug(device, @"alcCaptureStart");
	alcCaptureStart(device);
	_alcEndDebug(device, @"alcCaptureStart");
}
void            _alcCaptureStop(ALCdevice *device)
{
	_alcBeginDebug(device, @"alcCaptureStop");
	alcCaptureStop(device);
	_alcEndDebug(device, @"alcCaptureStop");
}
void            _alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples)
{
	_alcBeginDebug(device, @"alcCaptureSamples");
	alcCaptureSamples(device, buffer, samples);
	_alcEndDebug(device, @"alcCaptureSamples");
}
