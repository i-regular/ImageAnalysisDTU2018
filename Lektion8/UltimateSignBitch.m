%%
close all 
clear all

nSign1 = 23;
nSign2 = 35;
nSign3 = 37;
nSign4 = 51;
nSign5 = 63;
nSign6 = 45;
nSign7 = 41;
nSign8 = 47;
 
%%

ImageName1 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign1);
ImageName2 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign2);
ImageName3 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign3);
ImageName4 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign4);
ImageName5 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign5);
ImageName6 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign6);
ImageName7 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign7);
ImageName8 = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign8);

%% Loading in images
I2 = imread(ImageName2);
I3 = imread(ImageName3);
I4 = imread(ImageName4);
I5 = imread(ImageName5);
I6 = imread(ImageName6);
I7 = imread(ImageName7);
I8 = imread(ImageName8);

%% Connectivity
%[L4,CON1] = bwlabel(I2, 4); %Using 4 neighboors i.e 4 connected components
%[L8,CON2] = bwlabel(I2, 8); %Using 8 neighboors i.e 8 connected components

%% Threshold value RGB
RedLowerThress    = 100;
RedHigherThress   = 180;

GreenLowerThress  = 25;
GreenHigherThress = 55;

BlueLowerThress   = 25
BlueHigherThress  = 55;



%%
I = imread(ImageName1);
BSROI = roipoly(I);
imwrite(BSROI,'BSROI.png')

Ired = I(:,:,1);
Igreen = I(:,:,2);
Iblue = I(:,:,3);

redVals = double(Ired(BSROI));
greenVals = double(Igreen(BSROI));
blueVals = double(Iblue(BSROI));

figure;
totVals = [redVals greenVals blueVals];
nbins = 255;
hist(totVals,nbins);
h = findobj(gca,'Type','patch');
set(h(3),'FaceColor','r','EdgeColor','r','FaceAlpha',0.3,'EdgeAlpha',0.3);
set(h(2),'FaceColor','g','EdgeColor','g','FaceAlpha',0.3,'EdgeAlpha',0.3);
set(h(1),'FaceColor','b','EdgeColor','b','FaceAlpha',0.3,'EdgeAlpha',0.3);
xlim([0 255]);


%% Images loaded in

%%
image = imread(ImageName1);

%Split into RGB Channels
Red = image(:,:,1);
Green = image(:,:,2);
Blue = image(:,:,3);
%Get histValues for each channel
[yRed, x] = imhist(Red);
[yGreen, x] = imhist(Green);
[yBlue, x] = imhist(Blue);
%Plot them together in one plot
figure
plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');


%<= ThresholdValue) = 0


labelImage = I >= t;
