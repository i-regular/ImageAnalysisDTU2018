function I2 = mclose(I,se)
tempDiliate = imdilate(I,se);
I2 = imerode(tempDiliate,se);