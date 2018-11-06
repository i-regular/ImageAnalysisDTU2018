
%%
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

%%
threshold = 90; % or whatever.
redPixels = redChannel > threshold & greenChannel < threshold & blueChannel < threshold;
greenPixels = redChannel < threshold & greenChannel > threshold & blueChannel < threshold;
bluePixels = redChannel < threshold & greenChannel < threshold & blueChannel > threshold;
% Then call imfill to fill the holes
redPixels = imfill(redPixels, 'holes');
greenPixels = imfill(greenPixels, 'holes');
bluePixels = imfill(bluePixels, 'holes');
% Then call bwlabel to count the number of blobs:
[lr, countR] = bwlabel(redPixels);
[lg, countG] = bwlabel(greenPixels);
[lb, countB] = bwlabel(bluePixels);
% Call regionprops if you want bounding boxes.
measurementsR = regionprops(lr, 'BoundingBox');
measurementsG = regionprops(lg, 'BoundingBox');
measurementsB = regionprops(lb, 'BoundingBox');
imshow(lr)

%% Type 2.
MR = regionprops(lr,'Area', 'Perimeter')
hist([MR.Area], 8)


maxValue = max([MR.Area]);
minValue = min([MR.Area]);
Idx16a = find([MR.Area] > 20);
Idx16b = find([MR.Area] < 440);
idx=Idx16b(ismember(Idx16b,Idx16a));

BW2 = ismember(MR,idx);

imshow(BW2)
%%
Im2 = imclearborder(I,4);
W = bwconncomp(Im2,8);
Stats8 = regionprops(L8, 'Area','Perimeter');
Stats4 = regionprops(L4, 'Area','Perimeter');



maxValue = max([Stats8.Area]);
minValue = min([Stats8.Area]);
Idx16a = find([Stats8.Area] > 20);
Idx16b = find([Stats8.Area] < 440);
idx=Idx16b(ismember(Idx16b,Idx16a));

BW2 = ismember(L8,idx);

imshow(BW2)