//
//  inkFillGenerator.h
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_FILL_GENERATOR_H_
#define _INK_FILL_GENERATOR_H_

#include "inkHeader.h"
#include "inkArray.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	inkArray *vertices;
} inkFillGenerator;

inkFillGenerator *inkFillGeneratorCreate(size_t vertexSize);
void inkFillGeneratorDestroy(inkFillGenerator *fill);

void inkFillGeneratorMoveTo(inkFillGenerator *fill, float x, float y);
void inkFillGeneratorLineTo(inkFillGenerator *fill, float x, float y);

#ifdef __cplusplus
}
#endif

#endif
