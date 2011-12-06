//
//  inkCommand.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkCommand.h"

inkInline size_t inkCommandDataSizeFromType(inkCommandType type);

inkCommand* inkCommandCreate(inkCommandType type, void* data)
{
	inkCommand* command = malloc(sizeof(inkCommand));

	if (command != NULL)
	{
		size_t dataSize = inkCommandDataSizeFromType(type);

		if (dataSize == 0)
		{
			command->data = NULL;
		}
		else
		{
			command->data = malloc(dataSize);
			memcpy(command->data, data, dataSize);
		}

		command->type = type;
	}

	return command;
}

void inkCommandDestroy(inkCommand* command)
{
	if (command != NULL)
	{
		if (command->data != NULL)
		{
			free(command->data);
		}

		free(command);
	}
}

inkInline size_t inkCommandDataSizeFromType(inkCommandType type)
{
	switch(type)
	{
		case inkCommandType_MoveTo:
			return sizeof(inkMoveToCommand);
		case inkCommandType_LineTo:
			return sizeof(inkLineToCommand);
		case inkCommandType_QuadraticCurveTo:
			return sizeof(inkQuadraticCurveToCommand);
		case inkCommandType_CubicCurveTo:
			return sizeof(inkCubicCurveToCommand);
		case inkCommandType_SolidFill:
			return sizeof(inkSolidFillCommand);
		case inkCommandType_BitmapFill:
			return sizeof(inkBitmapFillCommand);
		case inkCommandType_GradientFill:
			return sizeof(inkGradientFillCommand);
		case inkCommandType_LineStyle:
			return sizeof(inkLineStyleCommand);
		case inkCommandType_LineBitmap:
			return sizeof(inkLineBitmapCommand);
		case inkCommandType_LineGradient:
			return sizeof(inkLineGradientCommand);
		case inkCommandType_Winding:
			return sizeof(inkWindingCommand);
		case inkCommandType_EndFill:
		default:
			break;
	}

	return 0;
}
