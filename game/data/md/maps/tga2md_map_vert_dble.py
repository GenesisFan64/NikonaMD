#======================================================================
# TGA to MD
#
# Usage:
# python tga2md.py file.tga folder
#======================================================================

#======================================================================

import sys
import os

#======================================================================
# -------------------------------------------------
# SETTINGS
# -------------------------------------------------

START_MAP    = 0		# Mapping start at VRAM
BLANK_TILE   = -1#0x7FE		# Default Blank Tile
TILE_SAVE    = True		# Save cell VRAM
MAP_VERTICAL = True		# Make map in vertical order
MAP_VDOUBLE  = True		# only if MAP_VERTICAL = True

#======================================================================
# -------------------------------------------------
# Variables
# -------------------------------------------------

clist = list()

#======================================================================
# -------------------------------------------------
# Subs
# -------------------------------------------------

def make_cell(XPOS,YPOS,COLOR):
	global IMG_WDTH
	XPOS = XPOS * 8
	YPOS = (IMG_WDTH * YPOS) * 8

	d = IMG_POS+XPOS+YPOS
	c = 8
	while c:
		input_file.seek(d)
		b = 4
		while b:
			a = 0
			e = (ord(input_file.read(1)) & 0xFF)
			f = (ord(input_file.read(1)) & 0xFF)

			g = e >> 4
			if g == COLOR:
				a = (e << 4) & 0xF0
			g = f >> 4
			if g == COLOR:
				a += f & 0x0F

			#a = (ord(input_file.read(1)) & 0x0F) << 4
			#a += (ord(input_file.read(1)) & 0x0F)
			art_file.write( bytes([a]) )
			b -= 1

		c -= 1
		d += IMG_WDTH

def chk_cell(XPOS,YPOS,COLOR):
	global IMG_WDTH
	XPOS = XPOS * 8
	YPOS = (IMG_WDTH * YPOS) * 8
	d = IMG_POS+XPOS+YPOS
	a = 0
	c = 8
	while c:
		input_file.seek(d)
		b = 8
		while b:
			i = (ord(input_file.read(1)) & 0xFF)
			a += (b+c)+i | a
			b -= 1
		c -= 1
		d += IMG_WDTH
	return a

def make_map():
	global MAP_TILE

	b = (MAP_TILE >> 8) & 0xFF
	a = MAP_TILE & 0xFF
	MAP_TILE += 1
	map_file.write( bytes([b,a]) )


def clist_srch(a):
	global clist
	b = False
	c = 0

	d = len(clist)/2
	e = 0
	while d:
		if clist[e] == a:
			b = True
			c = clist[e+1]
			return b,c
		e += 2
		d -= 1

	return b,c

#======================================================================
# -------------------------------------------------
# Init
# -------------------------------------------------

if len(sys.argv) != 2+1:
	print("Usage: tga2md.py image.tga out_folder")
	exit()
if os.path.exists(sys.argv[1]) == False:
	print("TGA file not found")
	exit()

MAIN_NAME   = sys.argv[1][:-4]
FOLDER_NAME = sys.argv[2]
if not os.path.exists(FOLDER_NAME):
    os.makedirs(FOLDER_NAME)
input_file  = open(sys.argv[1],"rb")

#======================================================================
# -------------------------------------------------
# Read headers
# -------------------------------------------------

#    0  -  No image data included.
#    1  -  Uncompressed, color-mapped images.
#    2  -  Uncompressed, RGB images.
#    3  -  Uncompressed, black and white images.
#    9  -  Runlength encoded color-mapped images.
#   10  -  Runlength encoded RGB images.
#   11  -  Compressed, black and white images.
#   32  -  Compressed color-mapped data, using Huffman, Delta, and
#          runlength encoding.
#   33  -  Compressed color-mapped data, using Huffman, Delta, and
#          runlength encoding.  4-pass quadtree-type process.

input_file.seek(1)
color_type = ord(input_file.read(1))
image_type = ord(input_file.read(1))

# start checking
#print("CURRENT IMAGE TYPE: "+hex(image_type))

if color_type == 1:
	#print("FOUND PALETTE")
	pal_start = ord(input_file.read(1))
	pal_start += ord(input_file.read(1)) << 8
	pal_len = ord(input_file.read(1))
	pal_len += ord(input_file.read(1)) << 8
	ignore_this = ord(input_file.read(1))
	has_pal = True

if image_type == 1:
	#print("IMAGE TYPE 1: Indexed")
	img_xstart = ord(input_file.read(1))
	img_xstart += ord(input_file.read(1)) << 8
	img_ystart = ord(input_file.read(1))
	img_ystart += ord(input_file.read(1)) << 8
	img_width = ord(input_file.read(1))
	img_width += ord(input_file.read(1)) << 8
	img_height = ord(input_file.read(1))
	img_height += ord(input_file.read(1)) << 8

	img_pixbits = ord(input_file.read(1))
	img_type = ord(input_file.read(1))
	#print( hex(img_type) )

	#0 = Origin in lower left-hand corner
	#1 = Origin in upper left-hand corner
	if (img_type >> 5 & 1) == False:
		print("ERROR: TOP LEFT images only")
		quit()
	has_img = True
else:
	print("IMAGE TYPE NOT SUPPORTED:",hex(image_type))
	quit()

#======================================================================
# -------------------------------------------------
# Palette
# -------------------------------------------------

if has_pal == True:
	output_file = open(FOLDER_NAME+"/"+"pal.bin","wb")
	d = pal_len
	while d:
		d -= 1
		a = (ord(input_file.read(1)) & 0xE0 ) << 4
		a += (ord(input_file.read(1)) & 0xE0 )
		a += (ord(input_file.read(1)) & 0xE0 ) >> 4
		b = (a >> 8) & 0xFF
		a = a & 0xFF
		output_file.write( bytes([b,a]) )
	output_file.close()

#======================================================================
# -------------------------------------------------
# Picture
# -------------------------------------------------

if has_img == True:
	IMG_POS  = input_file.tell()
	IMG_WDTH = img_width
	IMG_MAX_X = img_width >> 3
	IMG_MAX_Y = img_height >> 3
	MAP_TILE = START_MAP
	art_file = open(FOLDER_NAME+"/"+"art.bin","wb")
	mstr_mapname = FOLDER_NAME+"/"+"map.bin"

	# ----------------------
	# LAYER 1
	# ----------------------

	input_file.seek(IMG_POS)
	map_file = open(mstr_mapname,"wb")
	CURR_X = 0
	CURR_Y = 0

	if MAP_VERTICAL == True:
		a = IMG_MAX_X
	else:
		a = IMG_MAX_Y

	y_loop = a
	while y_loop:
		if MAP_VERTICAL == True:
			a = IMG_MAX_Y
		else:
			a = IMG_MAX_X

		x_loop = a
		while x_loop:
			X_ADD = 1

			if MAP_VERTICAL == True:
				if MAP_VDOUBLE:
					b = chk_cell(CURR_Y,CURR_X,0)
					b += chk_cell(CURR_Y,CURR_X+1,0)
				else:
					b = chk_cell(CURR_Y,CURR_X,0)
			else:
				b = chk_cell(CURR_X,CURR_Y,0)

			a = BLANK_TILE
			if b != 0:
				if TILE_SAVE == True:
					if clist_srch(b)[0] == True:
						a = ( clist_srch(b)[1] )
					else:
						a = MAP_TILE
						clist.append(b)	# ID
						clist.append(a) # MAP

						if MAP_VERTICAL == True:
							if MAP_VDOUBLE:
								make_cell(CURR_Y,CURR_X,0)
								make_cell(CURR_Y,CURR_X+1,0)
								MAP_TILE += 2
								X_ADD = 2
							else:
								make_cell(CURR_Y,CURR_X,0)
								MAP_TILE += 1
						else:
							make_cell(CURR_X,CURR_Y,0)
							MAP_TILE += 1
				else:
					a = MAP_TILE
					clist.append(b)	# ID
					clist.append(a) # MAP
					MAP_TILE += 1
					if MAP_VERTICAL == True:
						if MAP_VDOUBLE:
							make_cell(CURR_X,CURR_Y,0)
							make_cell(CURR_X,CURR_Y+1,0)
							MAP_TILE += 1
							X_ADD = 2
						else:
							make_cell(CURR_X,CURR_Y,0)
					else:
						make_cell(CURR_X,CURR_Y,0)


			map_file.write( bytes([(a>>8)&0xFF,a&0xFF]) )
			if MAP_VERTICAL:
				if MAP_VDOUBLE:
					if a != BLANK_TILE:
						a += 1
					X_ADD = 2
					map_file.write( bytes([(a>>8)&0xFF,a&0xFF]) )
			CURR_X += X_ADD

			if MAP_VERTICAL:
				if MAP_VDOUBLE:
					x_loop -= 2
				else:
					x_loop -= 1
			else:
				x_loop -= 1
		CURR_X = 0
		CURR_Y += 1
		y_loop -= 1
	map_file.close()

	print("CELLS USED:",hex(MAP_TILE))
	art_file.close()

#======================================================================
# ----------------------------
# End
# ----------------------------

print("Done.")
input_file.close()
