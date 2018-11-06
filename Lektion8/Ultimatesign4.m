
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
%hold on;
%for i = 1:numel(stats)
%    rectangle('Position', stats(i).BoundingBox, ...
%    'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
%end

%% Removing noise;


grayImage = rgb2gray(I);
BW = edge(ImageConnected1,'canny');
subplot(1,2,1)
imshow(grayImage)
title('grayscale image')
subplot(1,2,2)
imshow(BW)
title('Edge detection')

%%
img = I;
[x y z] = size(img); 

if z==1
    rslt=edge(img,'canny');
elseif z==3
    img1=rgb2ycbcr(img);
    dx1=edge(img1(:,:,1),'canny');
    dx1=(dx1*255);
    img2(:,:,1)=dx1;
    img2(:,:,2)=img1(:,:,2);
    img2(:,:,3)=img1(:,:,3);
    rslt=ycbcr2rgb(uint8(img2));
end
R=rslt;

%%
%smoothed partial derivatives using sobel filter (could use any other)
im = I;
	im = single(im) / 255;
	yfilter = fspecial('sobel');
	xfilter = yfilter';
	
	rx = imfilter(im(:,:,1), xfilter);
	gx = imfilter(im(:,:,2), xfilter);
	bx = imfilter(im(:,:,3), xfilter);
	
	ry = imfilter(im(:,:,1), yfilter);
	gy = imfilter(im(:,:,2), yfilter);
	by = imfilter(im(:,:,3), yfilter);
	
	Jx = rx.^2 + gx.^2 + bx.^2;
	Jy = ry.^2 + gy.^2 + by.^2;
	Jxy = rx.*ry + gx.*gy + bx.*by;
	
	%compute first (greatest) eigenvalue of 2x2 matrix J'*J.
	%note that the abs() is only needed because some values may be slightly
	%negative due to round-off error.
	D = sqrt(abs(Jx.^2 - 2*Jx.*Jy + Jy.^2 + 4*Jxy.^2));
	e1 = (Jx + Jy + D) / 2;
	%the 2nd eigenvalue would be:  e2 = (Jx + Jy - D) / 2;
	edge_magnitude = sqrt(e1);
	
	if nargout > 1,
		%compute edge orientation (from eigenvector tangent)
		edge_orientation = atan2(-Jxy, e1 - Jy);
    end
    
%%
%function [ im_ext ] = f_black_margin( imb, mask_size )
% v 2.0
% Baptiste Magnier, 2017,
mask_size = I;
if (mod ( mask_size , 2 ) == 0)
disp(['ERREUR : the window size is equal to ' num2str(tf) ', it must be odd']);  
end
  
n = mask_size;
[dimy , dimx]= size(imb); % nb lignes, nb colonnes
im_ext = zeros(dimy+(mask_size-1), dimx+(mask_size-1));
[dimy_ext, dimx_ext]=size(im_ext);
 
for i=1:(n-1)/2
    
  im_ext((n-1)/2+1:dimy_ext-(n-1)/2,i)=0; %first column 
  im_ext((n-1)/2+1:dimy_ext-(n-1)/2,dimx+(n-1)/2+i)=0; %last column
  im_ext(i,(n-1)/2+1:dimx_ext-(n-1)/2)=0; %first line
  im_ext(dimy+(n-1)/2+i,(n-1)/2+1:dimx_ext-(n-1)/2)=0; %last line
  
  %corners
  im_ext(i,1:(n-1)/2)=0; %left up
  im_ext(dimy+(n-1)/2+i,1:(n-1)/2)=0; %bottom left
  im_ext(i,(n-1)/2+dimx+1:dimx_ext)=0; %right up
  im_ext(dimy+(n-1)/2+i,(n-1)/2+dimx+1:dimx_ext)=0; %bottom right
end
im_ext((n-1)/2+1:dimy_ext-(n-1)/2,(n-1)/2+1:dimx_ext-(n-1)/2)=imb(1:dimy,1:dimx);