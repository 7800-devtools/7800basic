/*
 * lib.h - LZSA library definitions
 *
 * Copyright (C) 2019 Emmanuel Marty
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
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

/*
 * Uses the libdivsufsort library Copyright (c) 2003-2008 Yuta Mori
 *
 * Inspired by LZ4 by Yann Collet. https://github.com/lz4/lz4
 * With help, ideas, optimizations and speed measurements by spke <zxintrospec@gmail.com>
 * With ideas from Lizard by Przemyslaw Skibinski and Yann Collet. https://github.com/inikep/lizard
 * Also with ideas from smallz4 by Stephan Brumme. https://create.stephan-brumme.com/smallz4/
 *
 */

/* !!! Modified from the original, to use as a library for 7800basic !!! */

#ifndef _LIB_H
#define _LIB_H

/* Compression flags */
#define LZSA_FLAG_FAVOR_RATIO    (1<<0)      /**< 1 to compress with the best ratio, 0 to trade some compression ratio for extra decompression speed */
#define LZSA_FLAG_RAW_BLOCK      (1<<1)      /**< 1 to emit raw block */
#define LZSA_FLAG_RAW_BACKWARD   (1<<2)      /**< 1 to compress or decompress raw block backward */

#endif /* _LIB_H */
