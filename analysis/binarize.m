function binarized = binarize(original, thresh)
binarized = ( erf(original - thresh) + 1 )/2;
