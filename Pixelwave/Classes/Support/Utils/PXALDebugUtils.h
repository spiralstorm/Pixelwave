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

#ifndef PX_AL_DEBUG_DONT_CHANGE

#pragma mark -
#pragma mark AL Func

#define alEnable                      _alEnable
#define alDisable                     _alDisable
#define alIsEnabled                   _alIsEnabled
#define alGetString                   _alGetString
#define alGetBooleanv                 _alGetBooleanv
#define alGetIntegerv                 _alGetIntegerv
#define alGetFloatv                   _alGetFloatv
#define alGetDoublev                  _alGetDoublev
#define alGetBoolean                  _alGetBoolean
#define alGetInteger                  _alGetInteger
#define alGetFloat                    _alGetFloat
#define alGetDouble                   _alGetDouble
#define alGetError                    _alGetError
#define alIsExtensionPresent          _alIsExtensionPresent
#define alGetProcAddress              _alGetProcAddress
#define alGetEnumValue                _alGetEnumValue
#define alListenerf                   _alListenerf
#define alListener3f                  _alListener3f
#define alListenerfv                  _alListenerfv
#define alListeneri                   _alListeneri
#define alListener3i                  _alListener3i
#define alListeneriv                  _alListeneriv
#define alGetListenerf                _alGetListenerf
#define alGetListener3f               _alGetListener3f
#define alGetListenerfv               _alGetListenerfv
#define alGetListeneri                _alGetListeneri
#define alGetListener3i               _alGetListener3i
#define alGetListeneriv               _alGetListeneriv
#define alGenSources                  _alGenSources
#define alDeleteSources               _alDeleteSources
#define alIsSource                    _alIsSource
#define alSourcef                     _alSourcef
#define alSource3f                    _alSource3f
#define alSourcefv                    _alSourcefv
#define alSourcei                     _alSourcei
#define alSource3i                    _alSource3i
#define alSourceiv                    _alSourceiv
#define alGetSourcef                  _alGetSourcef
#define alGetSource3f                 _alGetSource3f
#define alGetSourcefv                 _alGetSourcefv
#define alGetSourcei                  _alGetSourcei
#define alGetSource3i                 _alGetSource3i
#define alGetSourceiv                 _alGetSourceiv
#define alSourcePlayv                 _alSourcePlayv
#define alSourceStopv                 _alSourceStopv
#define alSourceRewindv               _alSourceRewindv
#define alSourcePausev                _alSourcePausev
#define alSourcePlay                  _alSourcePlay
#define alSourceStop                  _alSourceStop
#define alSourceRewind                _alSourceRewind
#define alSourcePause                 _alSourcePause
#define alSourceQueueBuffers          _alSourceQueueBuffers
#define alSourceUnqueueBuffers        _alSourceUnqueueBuffers
#define alGenBuffers                  _alGenBuffers
#define alDeleteBuffers               _alDeleteBuffers
#define alIsBuffer                    _alIsBuffer
#define alBufferData                  _alBufferData
#define alBufferf                     _alBufferf
#define alBuffer3f                    _alBuffer3f
#define alBufferfv                    _alBufferfv
#define alBufferi                     _alBufferi
#define alBuffer3i                    _alBuffer3i
#define alBufferiv                    _alBufferiv
#define alGetBufferf                  _alGetBufferf
#define alGetBuffer3f                 _alGetBuffer3f
#define alGetBufferfv                 _alGetBufferfv
#define alGetBufferi                  _alGetBufferi
#define alGetBuffer3i                 _alGetBuffer3i
#define alGetBufferiv                 _alGetBufferiv
#define alDopplerFactor               _alDopplerFactor
#define alDopplerVelocity             _alDopplerVelocity
#define alSpeedOfSound                _alSpeedOfSound
#define alDistanceModel               _alDistanceModel


#pragma mark -
#pragma mark ALC Func

#define alcCreateContext              _alcCreateContext
#define alcMakeContextCurrent         _alcMakeContextCurrent
#define alcProcessContext             _alcProcessContext
#define alcSuspendContext             _alcSuspendContext
#define alcDestroyContext             _alcDestroyContext
#define alcGetCurrentContext          _alcGetCurrentContext
#define alcGetContextsDevice          _alcGetContextsDevice
#define alcOpenDevice                 _alcOpenDevice
#define alcCloseDevice                _alcCloseDevice
#define alcGetError                   _alcGetError
#define alcIsExtensionPresent         _alcIsExtensionPresent
#define alcGetProcAddress             _alcGetProcAddress
#define alcGetEnumValue               _alcGetEnumValue
#define alcGetString                  _alcGetString
#define alcGetIntegerv                _alcGetIntegerv
#define alcCaptureOpenDevice          _alcCaptureOpenDevice
#define alcCaptureCloseDevice         _alcCaptureCloseDevice
#define alcCaptureStart               _alcCaptureStart
#define alcCaptureStop                _alcCaptureStop
#define alcCaptureSamples             _alcCaptureSamples



#ifndef _PX_AL_UTILS_CHANGER_H_
#define _PX_AL_UTILS_CHANGER_H_

#pragma mark -
#pragma mark AL_H

#if defined(_WIN32) && !defined(_XBOX)
/* _OPENAL32LIB is deprecated */
#if defined(AL_BUILD_LIBRARY) || defined (_OPENAL32LIB)
#define AL_API __declspec(dllexport)
#else
#define AL_API __declspec(dllimport)
#endif
#else
#if defined(AL_BUILD_LIBRARY) && defined(HAVE_GCC_VISIBILITY)
#define AL_API __attribute__((visibility("default")))
#else
#define AL_API extern
#endif
#endif

#if defined(_WIN32)
#define AL_APIENTRY __cdecl
#else
#define AL_APIENTRY
#endif

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC
// #pragma export on
#endif

typedef char ALboolean;
typedef char ALchar;
typedef char ALbyte;
typedef unsigned char ALubyte;
typedef short ALshort;
typedef unsigned short ALushort;
typedef int ALint;
typedef unsigned int ALuint;
typedef int ALsizei;
typedef int ALenum;
typedef float ALfloat;
typedef double ALdouble;
typedef void ALvoid;

#define AL_NONE                                   0
#define AL_FALSE                                  0
#define AL_TRUE                                   1
#define AL_SOURCE_RELATIVE                        0x202
#define AL_CONE_INNER_ANGLE                       0x1001
#define AL_CONE_OUTER_ANGLE                       0x1002
#define AL_PITCH                                  0x1003
#define AL_POSITION                               0x1004
#define AL_DIRECTION                              0x1005
#define AL_VELOCITY                               0x1006
#define AL_LOOPING                                0x1007
#define AL_BUFFER                                 0x1009
#define AL_GAIN                                   0x100A
#define AL_MIN_GAIN                               0x100D
#define AL_MAX_GAIN                               0x100E
#define AL_ORIENTATION                            0x100F
#define AL_SOURCE_STATE                           0x1010
#define AL_INITIAL                                0x1011
#define AL_PLAYING                                0x1012
#define AL_PAUSED                                 0x1013
#define AL_STOPPED                                0x1014
#define AL_BUFFERS_QUEUED                         0x1015
#define AL_BUFFERS_PROCESSED                      0x1016
#define AL_SEC_OFFSET                             0x1024
#define AL_SAMPLE_OFFSET                          0x1025
#define AL_BYTE_OFFSET                            0x1026
#define AL_SOURCE_TYPE                            0x1027
#define AL_STATIC                                 0x1028
#define AL_STREAMING                              0x1029
#define AL_UNDETERMINED                           0x1030
#define AL_FORMAT_MONO8                           0x1100
#define AL_FORMAT_MONO16                          0x1101
#define AL_FORMAT_STEREO8                         0x1102
#define AL_FORMAT_STEREO16                        0x1103
#define AL_REFERENCE_DISTANCE                     0x1020
#define AL_ROLLOFF_FACTOR                         0x1021
#define AL_CONE_OUTER_GAIN                        0x1022
#define AL_MAX_DISTANCE                           0x1023
#define AL_FREQUENCY                              0x2001
#define AL_BITS                                   0x2002
#define AL_CHANNELS                               0x2003
#define AL_SIZE                                   0x2004
#define AL_UNUSED                                 0x2010
#define AL_PENDING                                0x2011
#define AL_PROCESSED                              0x2012
#define AL_NO_ERROR                               AL_FALSE
#define AL_INVALID_NAME                           0xA001
#define AL_INVALID_ENUM                           0xA002
#define AL_INVALID_VALUE                          0xA003
#define AL_INVALID_OPERATION                      0xA004
#define AL_OUT_OF_MEMORY                          0xA005
#define AL_VENDOR                                 0xB001
#define AL_VERSION                                0xB002
#define AL_RENDERER                               0xB003
#define AL_EXTENSIONS                             0xB004
#define AL_DOPPLER_FACTOR                         0xC000
#define AL_DOPPLER_VELOCITY                       0xC001
#define AL_SPEED_OF_SOUND                         0xC003
#define AL_DISTANCE_MODEL                         0xD000
#define AL_INVERSE_DISTANCE                       0xD001
#define AL_INVERSE_DISTANCE_CLAMPED               0xD002
#define AL_LINEAR_DISTANCE                        0xD003
#define AL_LINEAR_DISTANCE_CLAMPED                0xD004
#define AL_EXPONENT_DISTANCE                      0xD005
#define AL_EXPONENT_DISTANCE_CLAMPED              0xD006


#pragma mark -
#pragma mark ALC_H

#if defined(_WIN32) && !defined(_XBOX)
/* _OPENAL32LIB is deprecated */
#if defined(AL_BUILD_LIBRARY) || defined (_OPENAL32LIB)
#define ALC_API __declspec(dllexport)
#else
#define ALC_API __declspec(dllimport)
#endif
#else
#if defined(AL_BUILD_LIBRARY) && defined(HAVE_GCC_VISIBILITY)
#define ALC_API __attribute__((visibility("default")))
#else
#define ALC_API extern
#endif
#endif

#if defined(_WIN32)
#define ALC_APIENTRY __cdecl
#else
#define ALC_APIENTRY
#endif

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC
// #pragma export on
#endif

#define ALCAPI ALC_API
#define ALCAPIENTRY ALC_APIENTRY
#define ALC_INVALID 0
#define ALC_VERSION_0_1         1

typedef struct ALCdevice_struct ALCdevice;
typedef struct ALCcontext_struct ALCcontext;
typedef char ALCboolean;
typedef char ALCchar;
typedef char ALCbyte;
typedef unsigned char ALCubyte;
typedef short ALCshort;
typedef unsigned short ALCushort;
typedef int ALCint;
typedef unsigned int ALCuint;
typedef int ALCsizei;
typedef int ALCenum;
typedef float ALCfloat;
typedef double ALCdouble;
typedef void ALCvoid;

#define ALC_FALSE                                0
#define ALC_TRUE                                 1
#define ALC_FREQUENCY                            0x1007
#define ALC_REFRESH                              0x1008
#define ALC_SYNC                                 0x1009
#define ALC_MONO_SOURCES                         0x1010
#define ALC_STEREO_SOURCES                       0x1011
#define ALC_NO_ERROR                             ALC_FALSE
#define ALC_INVALID_DEVICE                       0xA001
#define ALC_INVALID_CONTEXT                      0xA002
#define ALC_INVALID_ENUM                         0xA003
#define ALC_INVALID_VALUE                        0xA004
#define ALC_OUT_OF_MEMORY                        0xA005
#define ALC_DEFAULT_DEVICE_SPECIFIER             0x1004
#define ALC_DEVICE_SPECIFIER                     0x1005
#define ALC_EXTENSIONS                           0x1006
#define ALC_MAJOR_VERSION                        0x1000
#define ALC_MINOR_VERSION                        0x1001
#define ALC_ATTRIBUTES_SIZE                      0x1002
#define ALC_ALL_ATTRIBUTES                       0x1003
#define ALC_DEFAULT_ALL_DEVICES_SPECIFIER        0x1012
#define ALC_ALL_DEVICES_SPECIFIER                0x1013
#define ALC_CAPTURE_DEVICE_SPECIFIER             0x310
#define ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER     0x311
#define ALC_CAPTURE_SAMPLES                      0x312


#endif


#endif



#ifndef _PX_ALV2_UTILS_H_
#define _PX_ALV2_UTILS_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef char _ALboolean;
typedef char _ALchar;
typedef char _ALbyte;
typedef unsigned char _ALubyte;
typedef short _ALshort;
typedef unsigned short _ALushort;
typedef int _ALint;
typedef unsigned int _ALuint;
typedef int _ALsizei;
typedef int _ALenum;
typedef float _ALfloat;
typedef double _ALdouble;
typedef void _ALvoid;

void _alEnable(_ALenum capability);
void _alDisable(_ALenum capability); 
_ALboolean _alIsEnabled(_ALenum capability); 
const _ALchar* _alGetString(_ALenum param);
void _alGetBooleanv(_ALenum param, _ALboolean* data);
void _alGetIntegerv(_ALenum param, _ALint* data);
void _alGetFloatv(_ALenum param, _ALfloat* data);
void _alGetDoublev(_ALenum param, _ALdouble* data);
_ALboolean _alGetBoolean(_ALenum param);
_ALint _alGetInteger(_ALenum param);
_ALfloat _alGetFloat(_ALenum param);
_ALdouble _alGetDouble(_ALenum param);
_ALenum _alGetError(void);
_ALboolean _alIsExtensionPresent(const _ALchar* extname);
void* _alGetProcAddress(const _ALchar* fname);
_ALenum _alGetEnumValue(const _ALchar* ename);
void _alListenerf(_ALenum param, _ALfloat value);
void _alListener3f(_ALenum param, _ALfloat value1, _ALfloat value2, _ALfloat value3);
void _alListenerfv(_ALenum param, const _ALfloat* values); 
void _alListeneri(_ALenum param, _ALint value);
void _alListener3i(_ALenum param, _ALint value1, _ALint value2, _ALint value3);
void _alListeneriv(_ALenum param, const _ALint* values);
void _alGetListenerf(_ALenum param, _ALfloat* value);
void _alGetListener3f(_ALenum param, _ALfloat *value1, _ALfloat *value2, _ALfloat *value3);
void _alGetListenerfv(_ALenum param, _ALfloat* values);
void _alGetListeneri(_ALenum param, _ALint* value);
void _alGetListener3i(_ALenum param, _ALint *value1, _ALint *value2, _ALint *value3);
void _alGetListeneriv(_ALenum param, _ALint* values);
void _alGenSources(_ALsizei n, _ALuint* sources); 
void _alDeleteSources(_ALsizei n, const _ALuint* sources); 
_ALboolean _alIsSource(_ALuint sid); 
void _alSourcef(_ALuint sid, _ALenum param, _ALfloat value);
void _alSource3f(_ALuint sid, _ALenum param, _ALfloat value1, _ALfloat value2, _ALfloat value3);
void _alSourcefv(_ALuint sid, _ALenum param, const _ALfloat* values);
void _alSourcei(_ALuint sid, _ALenum param, _ALint value);
void _alSource3i(_ALuint sid, _ALenum param, _ALint value1, _ALint value2, _ALint value3);
void _alSourceiv(_ALuint sid, _ALenum param, const _ALint* values);
void _alGetSourcef(_ALuint sid, _ALenum param, _ALfloat* value);
void _alGetSource3f( _ALuint sid, _ALenum param, _ALfloat* value1, _ALfloat* value2, _ALfloat* value3);
void _alGetSourcefv(_ALuint sid, _ALenum param, _ALfloat* values);
void _alGetSourcei(_ALuint sid,  _ALenum param, _ALint* value);
void _alGetSource3i( _ALuint sid, _ALenum param, _ALint* value1, _ALint* value2, _ALint* value3);
void _alGetSourceiv(_ALuint sid,  _ALenum param, _ALint* values);
void _alSourcePlayv(_ALsizei ns, const _ALuint *sids);
void _alSourceStopv(_ALsizei ns, const _ALuint *sids);
void _alSourceRewindv(_ALsizei ns, const _ALuint *sids);
void _alSourcePausev(_ALsizei ns, const _ALuint *sids);
void _alSourcePlay(_ALuint sid);
void _alSourceStop(_ALuint sid);
void _alSourceRewind(_ALuint sid);
void _alSourcePause(_ALuint sid);
void _alSourceQueueBuffers(_ALuint sid, _ALsizei numEntries, const _ALuint *bids);
void _alSourceUnqueueBuffers(_ALuint sid, _ALsizei numEntries, _ALuint *bids);
void _alGenBuffers(_ALsizei n, _ALuint* buffers);
void _alDeleteBuffers(_ALsizei n, const _ALuint* buffers);
_ALboolean _alIsBuffer(_ALuint bid);
void _alBufferData(_ALuint bid, _ALenum format, const _ALvoid* data, _ALsizei size, _ALsizei freq);
void _alBufferf(_ALuint bid, _ALenum param, _ALfloat value);
void _alBuffer3f(_ALuint bid, _ALenum param, _ALfloat value1, _ALfloat value2, _ALfloat value3);
void _alBufferfv(_ALuint bid, _ALenum param, const _ALfloat* values);
void _alBufferi(_ALuint bid, _ALenum param, _ALint value);
void _alBuffer3i(_ALuint bid, _ALenum param, _ALint value1, _ALint value2, _ALint value3);
void _alBufferiv(_ALuint bid, _ALenum param, const _ALint* values);
void _alGetBufferf(_ALuint bid, _ALenum param, _ALfloat* value);
void _alGetBuffer3f( _ALuint bid, _ALenum param, _ALfloat* value1, _ALfloat* value2, _ALfloat* value3);
void _alGetBufferfv(_ALuint bid, _ALenum param, _ALfloat* values);
void _alGetBufferi(_ALuint bid, _ALenum param, _ALint* value);
void _alGetBuffer3i( _ALuint bid, _ALenum param, _ALint* value1, _ALint* value2, _ALint* value3);
void _alGetBufferiv(_ALuint bid, _ALenum param, _ALint* values);
void _alDopplerFactor(_ALfloat value);
void _alDopplerVelocity(_ALfloat value);
void _alSpeedOfSound(_ALfloat value);
void _alDistanceModel(_ALenum distanceModel);

typedef struct ALCdevice_struct _ALCdevice;
typedef struct ALCcontext_struct _ALCcontext;
typedef char _ALCboolean;
typedef char _ALCchar;
typedef char _ALCbyte;
typedef unsigned char _ALCubyte;
typedef short _ALCshort;
typedef unsigned short _ALCushort;
typedef int _ALCint;
typedef unsigned int _ALCuint;
typedef int _ALCsizei;
typedef int _ALCenum;
typedef float _ALCfloat;
typedef double _ALCdouble;
typedef void _ALCvoid;

_ALCcontext *    _alcCreateContext(_ALCdevice *device, const _ALCint* attrlist);
_ALCboolean      _alcMakeContextCurrent(_ALCcontext *context);
void            _alcProcessContext(_ALCcontext *context);
void            _alcSuspendContext(_ALCcontext *context);
void            _alcDestroyContext(_ALCcontext *context);
_ALCcontext *    _alcGetCurrentContext(void);
_ALCdevice*      _alcGetContextsDevice(_ALCcontext *context);
_ALCdevice *     _alcOpenDevice(const _ALCchar *devicename);
_ALCboolean      _alcCloseDevice(_ALCdevice *device);
_ALCenum         _alcGetError(_ALCdevice *device);
_ALCboolean      _alcIsExtensionPresent(_ALCdevice *device, const _ALCchar *extname);
void  *         _alcGetProcAddress(_ALCdevice *device, const _ALCchar *funcname);
_ALCenum         _alcGetEnumValue(_ALCdevice *device, const _ALCchar *enumname);
const _ALCchar * _alcGetString(_ALCdevice *device, _ALCenum param);
void            _alcGetIntegerv(_ALCdevice *device, _ALCenum param, _ALCsizei size, _ALCint *data);
_ALCdevice*      _alcCaptureOpenDevice(const _ALCchar *devicename, _ALCuint frequency, _ALCenum format, _ALCsizei buffersize);
_ALCboolean      _alcCaptureCloseDevice(_ALCdevice *device);
void            _alcCaptureStart(_ALCdevice *device);
void            _alcCaptureStop(_ALCdevice *device);
void            _alcCaptureSamples(_ALCdevice *device, _ALCvoid *buffer, _ALCsizei samples);

#ifdef __cplusplus
}
#endif

#endif
