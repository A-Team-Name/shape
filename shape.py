import imageio.v3 as iio
import numpy as np
from math import floor

data = (iio.imread('josh.webp'))[:, :, 0] != 255
h, w = data.shape
p = np.arange(h * w)
for i in range(h):
    for j in range(w):
        if not data[i, j]: continue
        if i >= 1 and j >= 1:
            pass
        elif i >= 0:
            pass
        elif j >= 0:
            pass

