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

#ifndef _PX_GL_STATE_PRIVATE_H_
#define _PX_GL_STATE_PRIVATE_H_

#ifdef __cplusplus
extern "C" {
#endif

/*	              STATE					*
 * EF0000000000SLPT - 16 bits, 6 used	*
 * ----------------------------------	*
 * E = Draw elements			1 bit	*
 * F = Shade Model Flat		1 bit	*
 * S = Point sprite			1 bit	*
 * L = Line smooth				1 bit	*
 * P = Point smooth			1 bit	*
 * T = Texture 2D				1 bit	*/
#define PX_GL_DRAW_ELEMENTS				0x8000
#define PX_GL_SHADE_MODEL_FLAT			0x4000
#define PX_GL_POINT_SPRITE				0x0008
#define PX_GL_LINE_SMOOTH				0x0004
#define PX_GL_POINT_SMOOTH				0x0002
#define PX_GL_TEXTURE_2D				0x0001

/*	          CLIENT STATE				*
 * 000000000000CPTV - 16 bits, 4 used	*
 * ----------------------------------	*
 * C = Color array				1 bit	*
 * P = Point Size array		1 bit	*
 * T = Texture coord array		1 bit	*
 * V = Vertex array			1 bit	*/
#define PX_GL_COLOR_ARRAY				0x0008
#define PX_GL_POINT_SIZE_ARRAY			0x0004
#define PX_GL_TEXTURE_COORD_ARRAY		0x0002
#define PX_GL_VERTEX_ARRAY				0x0001

#ifdef __cplusplus
}
#endif

#endif
