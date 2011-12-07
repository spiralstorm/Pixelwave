//
//  inkFillGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFillGenerator.h"

inkFillGenerator* inkFillGeneratorCreate(inkTessellator* tessellator, inkArray* renderGroups, void* fill)
{
	inkFillGenerator* fillGenerator = malloc(sizeof(inkFillGenerator));

	if (fillGenerator != NULL)
	{
		inkGenerator* generator = inkGeneratorCreate(tessellator, fill);

		if (generator == NULL)
		{
			inkFillGeneratorDestroy(fillGenerator);
			return NULL;
		}

		fillGenerator->generator = generator;

		inkTessellatorSetTextureName(tessellator, inkFillTextureName(fill));
		inkTessellatorBeginPolygon(tessellator, renderGroups);
	}

	return fillGenerator;
}

void inkFillGeneratorDestroy(inkFillGenerator* fillGenerator)
{
	if (fillGenerator != NULL)
	{
		if (fillGenerator->generator != NULL)
		{
			inkTessellatorEndPolygon(fillGenerator->generator->tessellator);

			/*if (fillGenerator->generator->tessellator != NULL)
			{
				if (fillGenerator->generator->tessellator->currentRenderGroup != NULL)
				{
					if (fillGenerator->generator->fill != NULL)
					{
						inkFillType fillType = ((inkFill*)fillGenerator->generator->fill)->fillType;

						if (fillType == inkFillType_Bitmap)
						{
							inkBitmapFill* bitmapFill = (inkBitmapFill*)fillGenerator->generator->fill;
							fillGenerator->generator->tessellator->currentRenderGroup->glTextureName = bitmapFill->bitmapInfo.glTextureName;
						}
					}
				}
			}*/

			inkGeneratorDestroy(fillGenerator->generator);
		}

		free(fillGenerator);
	}
}

void inkFillGeneratorMoveTo(inkFillGenerator* fillGenerator, inkPoint position)
{
	if (fillGenerator == NULL)
		return;

	inkGeneratorMoveTo(fillGenerator->generator, position, NULL, NULL);
}

void inkFillGeneratorLineTo(inkFillGenerator* fillGenerator, inkPoint position)
{
	if (fillGenerator == NULL)
		return;

	inkGeneratorLineTo(fillGenerator->generator, position);
}

void inkFillGeneratorEnd(inkFillGenerator* fillGenerator)
{
	if (fillGenerator == NULL)
		return;

	inkGeneratorEnd(fillGenerator->generator);
}
