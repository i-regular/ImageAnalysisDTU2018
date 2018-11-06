function I2 = mopen(I,se)
tempErosion = imerode(I,se);
I2 = imdilate(tempErosion,se);
%MOPEN Open image.
%I2 = MOPEN(I,SE) %opens the image I with the structuring
% element SE and returns image I2