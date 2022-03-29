#--------------------------------------------------------------------------
# Fast Image Dehazing Using Improved Dark Channel Prior
#
# Reference:
# H. Xu, J. Guo, Q. Liu and L. Ye, 
# "Fast image dehazing using improved dark channel prior",
# 2012 IEEE International Conference on Information Science and Technology, 
#2 012, pp. 663-667, doi: 10.1109/ICIST.2012.6221729.
#--------------------------------------------------------------------------

import numpy as np
from matplotlib import pyplot as plt


def get_dark_channel(j, w):
    """ Calculate dark channel

    Parameters
    ----------
    j:  a numpy array containing the RGB image
    w:  window size for local patch

    Returns
    -------
    Calculated dark channel
    """

    rows, cols, _ = j.shape
    j_dark = np.zeros((rows, cols))

    # window range
    r = round(w/2)

    # padded image to have (w, w) windows centered around each pixel
    img_pad = np.pad(j, ((r, r), (r, r), (0,0)), 'edge')

    for n in range(rows):
        for m in range(cols):
            # get (w, w) patch from padded image
            patch = img_pad[n:n+w, m:m+w, :]
            j_dark[n,m] = np.min(patch)

    return j_dark


def get_atmospheric_light(j, j_dark):
    """ Estimate atmospheric light

    Parameters
    ----------
    j:  a numpy array containing the RGB image
    j_dark: dark channel of image j

    Returns
    -------
    Estimated atmospheric light
    """

    # atmoshperic light for each color channel
    a = np.zeros(3)

    # find indices for 0.1 % brightest pixels in dark channel
    n = round(0.001*(j_dark.shape[0]*j_dark.shape[1]))
    ind = np.argsort(j_dark.flatten)[-n:]

    # find highest intensity pixel in each color channel
    for c in range(3):
        a[c] = np.max((j[:,:,c].flatten())[ind])

    return a


def bilateral_filter(t, j):
    """ Apply bilateral to transmission map

    Parameters
    ----------
    t:  estimated transmission map
    j:  gray image of the input

    Returns
    -------
    Refined transmission map
    """

    w = 0
    #for p in 
    return t


def get_transmission_map(i, a, p):
    """ Estimate the transmission map for image data

    Parameters
    ----------
    i:  original RBG image
    a:  atmospheric light for each color channel
    p:  brightness adjustment, in range [0.08-0.25]

    Returns
    -------
    Estimated transmission map
    """
    return 1 - get_dark_channel(i/a, 8) + p
    

def dehaze(j, plot=False):
    dark_channel = get_dark_channel(j, 8)
    a = get_atmospheric_light(j, dark_channel)
    t = get_transmission_map(j, a, 0.08)

   # t = bilateral_filter(t)

    # NEXT: fast bilateral filter -> refined transmission map

    if plot:
        plt.imshow(t, cmap='gray')
        plt.show()