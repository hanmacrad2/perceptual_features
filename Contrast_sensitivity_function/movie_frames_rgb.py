# -*- coding: utf-8 -*-
"""
Created on Tue Nov 17 10:56:36 2020

@author: Hannah Craddock
"""
import skvideo.io
from skimage import data
from skimage.color import rgb2lab, lab2lch

from skvideo.io import ffmpeg

import skvideo.datasets
videodata = skvideo.datasets.bigbuckbunny()

#videodata = skvideo.io.vread('Tom and jerry.mp4')


img = data.astronaut()
img_lab = rgb2lab(img)
img_lch = lab2lch(img_lab)


videogen = skvideo.io.vreader(skvideo.datasets.bigbuckbunny())
for frame in videogen:
        print(frame.shape)
        
#Convert from rgb2lab
img_lab = rgb2lab(img)  