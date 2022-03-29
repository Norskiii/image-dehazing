import argparse
import numpy as np
from PIL import Image
from dehaze import dehaze


def main():
    parser = argparse.ArgumentParser(description='Fast Image Dehazing Using Improved Dark Channel Prior')
    parser.add_argument('-i', nargs=1, type=str, help='Input image path', required=True)
    parser.add_argument('-o', nargs=1, type=str, help='Ouput image path', required=True)

    args = parser.parse_args()

    input_path = args.i[0]
    output_path = args.o[0]

    # open input image
    try:
        img = Image.open(input_path)
    except IOError:
        print(input_path, 'not found')
        return

    # dehaze the image
    d_img = dehaze(np.array(img), plot=True)

    # save dehazed image
    #d_img = d_img.save(output_path)


if __name__ == '__main__':
    main()