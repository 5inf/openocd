/***************************************************************************
 *   Copyright (C) 2016 by Sysprogs                                        *
 *   sysprogs@sysprogs.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.           *
 ***************************************************************************/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <target/image.h>

struct advanced_elf_image {
	struct fileio *fileio;
	bool is_64_bit;
	union {
		Elf32_Ehdr header;
		Elf64_Ehdr header64;
	};
	union {
		Elf32_Phdr *segments;
		Elf64_Phdr *segments64;
	};
	uint32_t segment_count;
	uint8_t endianness;
    union{
        Elf32_Shdr *sections;
        Elf64_Shdr *sections64;
    };
    int num_sections;
    char *strtab;
    int strtab_size;
    union{
        Elf32_Sym *symbols;
        Elf64_Sym *symbols64;
    };
    int num_symbols;
};

int advanced_elf_image_open(struct advanced_elf_image *image, const char *URL);
void advanced_elf_image_close(struct advanced_elf_image *image);

uint64_t advanced_elf_image_find_symbol(struct advanced_elf_image *image, const char *symbol_name);
int advanced_elf_image_read_section(struct advanced_elf_image *image, int section, void *buf, size_t buf_size, size_t *done);


