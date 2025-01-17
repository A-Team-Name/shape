import imageio.v3 as iio
import numpy as np
from math import floor
import matplotlib.pyplot as plt

def split(image):
    # this will be disgusting to read and I can only apologise
    data = image[:, :, 0] != 255
    h, w = data.shape
    p = np.zeros((h, w, 2), dtype = np.dtype(int))
    for i in range(h):
        for j in range(w):
            p[i, j, :] = [i, j]
            if not data[i, j]: continue
            k = []
            if i >= 1 and data[i - 1, j]: k.append((i - 1, j))
            if j >= 1 and data[i, j - 1]: k.append((i, j - 1))
            if len(k) == 0: continue
            for l, (ii, jj) in enumerate(k):
                iii, jjj = p[ii, jj, :]
                while (iii, jjj) != (ii, jj):
                    ii, jj = iii, jjj
                    iii, jjj = p[ii, jj, :]
                k[l] = (iii, jjj)
            p[i, j, :] = k[0]
            if len(k) == 1: continue
            ii, jj = k[1]
            p[ii, jj, :] = k[0]

    p = np.multiply(p, [w, 1]).sum(axis = 2).ravel()
    q = p[p]
    while not np.array_equiv(p, q):
        p = q
        q = p[p]

    s = data.ravel() * (p + 1)
    c = np.sort(np.unique(s))
    s = np.searchsorted(c, s)

    min = np.zeros(len(c) - 1)
    max = np.zeros(len(c) - 1)
    for e in range(1, len(c)):
        i = np.argwhere(s == e).ravel() % w
        min[e - 1] = i.min()
        max[e - 1] = i.max()

    b = np.logical_and(
        np.greater_equal.outer(min, min),
        np.logical_or(
            np.less_equal.outer(max, max),
            np.less_equal.outer(min, min + 0.5 * (max - min)),
        ),
    )
    b = np.logical_or(b, b.T)
    bb = b.dot(b)
    while not np.array_equiv(b, bb):
        b = bb
        bb = b.dot(b)

    for e in range(1, len(c)):
        s[np.argwhere(s == e).ravel()] = np.nonzero(b[e - 1, :])[0][0] + 1

    # FIXME: it's inefficient to just do this all over, try save some results idk
    c = np.sort(np.unique(s))
    s = np.searchsorted(c, s)
    glyphs = []
    for e in range(1, len(c)):
        i = np.argwhere(s == e).ravel() % w
        min = i.min()
        max = i.max()
        glyphs.append((min, max, e == s.reshape([h, w])[:, min : max + 1]))
    glyphs.sort()
    glyphs = [glyph[2] for glyph in glyphs]

    # for glyph in glyphs: plt.matshow(glyph)
    # plt.show()

    return glyphs

image = iio.imread('josh.webp')
split(image)
