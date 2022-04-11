# Fast Image Dehazing Using Improved Dark Channel Prior
Implementation of fast image dehazing algorithm described in _Fast image dehazing using improved dark channel prior_ [1]. The script uses vanilla bilateral filtering instead of a fast approxmination.

## Runinng
Run dehaze.m script with haze image path as input. The script will save dehazing result in a file called 'dehazed.png' and also display input image, estimated transmission map, refined transmission map, and dehazed image.

## References
[1] H. Xu, J. Guo, Q. Liu and L. Ye, "Fast image dehazing using improved dark channel prior" 
2012 IEEE International Conference on Information Science and Technology, 2012, pp. 663-667, doi: 10.1109/ICIST.2012.6221729.
