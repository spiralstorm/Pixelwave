/***************************************************************************/
/*                                                                         */
/*  ftbase.c                                                               */
/*                                                                         */
/*    Single object library component (body only).                         */
/*                                                                         */
/*  Copyright 1996-2001, 2002, 2003, 2004, 2006, 2007, 2008 by             */
/*  David Turner, Robert Wilhelm, and Werner Lemberg.                      */
/*                                                                         */
/*  This file is part of the FreeType project, and may only be used,       */
/*  modified, and distributed under the terms of the FreeType project      */
/*  license, LICENSE.TXT.  By continuing to use, modify, or distribute     */
/*  this file you indicate that you have read the license and              */
/*  understand and accept it fully.                                        */
/*                                                                         */
/***************************************************************************/


#include <ft2build.h>

#define  FT_MAKE_OPTION_SINGLE_OBJECT

#include "ftadvanc.c.h"
#include "ftcalc.c.h"
#include "ftdbgmem.c"
#include "ftgloadr.c.h"
#include "ftnames.c.h"
#include "ftobjs.c.h"
#include "ftoutln.c.h"
#include "ftrfork.c.h"
#include "ftstream.c.h"
#include "fttrigon.c.h"
#include "ftutil.c.h"

#if defined( FT_MACINTOSH ) && !defined ( DARWIN_NO_CARBON )
#include "ftmac.c"
#endif

/* END */
