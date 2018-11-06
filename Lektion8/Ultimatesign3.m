

close all
clear all

%% Sign number
nSign1 = 23;

%% Image Name
ImageName = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign1);

%% Loading in image
I = imread(ImageName);

%% Red, green & blue channels
redChannel = I(:, :, 1); % Call imshow(redChannel) if you want to see it.
greenChannel = I(:, :, 2);
blueChannel = I(:, :, 3);

%% Thresholding - Inspect picture to decide thresshold
threshold = 130; 

%% Using Threshold to highlight redPixels.
redPixels = redChannel > threshold & greenChannel < threshold & blueChannel < threshold;

%% Filling out holes in image
redFilled = imfill(redPixels, 'holes');

%% Connecting components
[ImageConnected1, CON1] = bwlabel(redFilled);
[ImageConnected2, CON2] = bwlabel(redFilled);

%%
stats = [regionprops(ImageConnected1); regionprops(not(ImageConnected1))]
% show the image and draw the detected rectangles on it
figure
imshow(ImageConnected1); 
hold on;
for i = 1:numel(stats)
    rectangle('Position', stats(i).BoundingBox, ...
    'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
end

%% Creating Kernel 
% Designing kernels/structural elements
se1 = strel('square',3);
se2 = strel('disk',1);      %Husk at en 3x3 disk har indekset 1 i koden.

%% Removing noise open - close
erode1 = imopen(redPixels,se1);
erode2 = imopen(redPixels,se2);

dilate1 = imclose(erode1,se1);
dilate2 = imclose(erode2,se2);

figure
subplot(1,2,1)
imshow(dilate1)
title('OC - square')
subplot(1,2,2)
imshow(dilate2)
title('OC - DISK')

%% Removing noise 2 close - open
dilate3 = imclose(redPixels,se1);
dilate4 = imclose(redPixels,se2);

erode3 = imopen(dilate3,se1);
erode4 = imopen(dilate4,se2);

figure
subplot(1,2,1)
imshow(erode3)
title('CO - square')
subplot(1,2,2)
imshow(erode4)
title('CO - disk')