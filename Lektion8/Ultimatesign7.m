close all
clear all

%% Sign number
nSign1 = 5;

%% Image Name
ImageName = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign1);

%% Loading in image
I = imread(ImageName);

%% Red, green & blue channels
redChannel = I(:, :, 1); % Call imshow(redChannel) if you want to see it.
greenChannel = I(:, :, 2);
blueChannel = I(:, :, 3);

Ired = redChannel;
Igreen = greenChannel;
Iblue = blueChannel;
%% Thresholding - Inspect picture to decide thresshold
threshold = 120;
thresholdgreen = 90;
thresholdblue  = 90;
%% Using Threshold to highlight redPixels.
redPixels = redChannel > threshold & greenChannel < threshold & blueChannel < threshold;
redPixels = Ired > 105 & Ired < 235  & Igreen > 26 & Igreen < 117 & Iblue > 25 & Iblue < 129 & (abs(Iblue - Igreen) < 20);
%% Filling out holes in image
redFilled = imfill(redPixels, 'holes');

%% Connecting components
[ImageConnected1, CON1] = bwlabel(redFilled);
[ImageConnected2, CON2] = bwlabel(redFilled);

%%
%stats = [regionprops(ImageConnected1); regionprops(not(ImageConnected1))]
% show the image and draw the detected rectangles on it
figure
imshow(ImageConnected1); 

%% Creating Kernel 
% Designing kernels/structural elements
se1 = strel('square',3);
se2 = strel('disk',1);      %Husk at en 3x3 disk har indekset 1 i koden.

ClosedImage = mclose(ImageConnected1,se1);
OpenedImage = mopen(ImageConnected1,se2);

%%%%%% SHOWING IMAGE %%%%%%
%figure
%imshow(ClosedImage)
%title('ClosedImage');

%figure
%imshow(OpenedImage)
%title('OpenedImage');

%% Removing noice further;
NewImage1 = imopen(OpenedImage, strel('square',9));
NewImage2 = imopen(ClosedImage, strel('square',9));

%%%%%% SHOWING IMAGE %%%%%%
%figure
%imshow(NewImage1)
%title('opened - opened')

%figure
%imshow(NewImage2)
%title('closed - opened')

%% Finding edges
[a, threshold] = edge(NewImage1, 'sobel');

fudgeFactor = .5;
BWs = edge(NewImage1,'sobel', threshold * fudgeFactor);
%%%%%% SHOWING IMAGE %%%%%%
%figure
%subplot(1,2,1)
%imshow(a)
%title('Edgde-detection 1.0')
%subplot(1,2,2)
%imshow(BWs),
%title('binary gradient mask');

%% Filling with jizz
BWdfill = imfill(BWs, 'holes');
%figure, imshow(BWdfill);
%title('binary image with filled holes');

%% Clearing borders
BWnobord = imclearborder(BWdfill, 26);
%figure, imshow(BWnobord), title('cleared border image');

imwrite(BWnobord, 'BWnobord.png')

%% Region properties
BW_out = BWnobord;
properties = regionprops(BW_out, 'Area', 'Perimeter','Extrema');

sortedValues = sort([properties.Area]);
Length_sorted = length(sortedValues);

BlobUP_Thres = sortedValues(Length_sorted);
BlobLP_Thres = sortedValues(Length_sorted-1)+1;

%%
[B,L,N] = bwboundaries(BW_out);
%Display object boundaries in red and hole boundaries in green.

%imshow(BW_out); hold on;
%for k=1:length(B),
%   boundary = B{k};
%   if(k > N)
%     plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
%   else
%     plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
%   end
%end

imshow(bwareaopen(BW_out,sortedValues(length(sortedValues)-1)))
ISigns = bwareaopen(BW_out,sortedValues(length(sortedValues)-3));
imshow(ISigns)

figure
subplot(1,2,1)
imshow(I)
title('Original Image');
subplot(1,2,2)
imshow(ISigns)
title('Sign detection');

for i = 1:4 
    k = bwareaopen(BW_out,sortedValues(length(sortedValues)-(i-1)));
    figure
    imshow(k)
    title(strcat('plot',num2str(i)))
end
%%
% Region props
stats = regionprops(k, 'Area', 'Perimeter','Boundingbox');
% Label Image
[labeledImage, numBlobs] = bwlabel(ISigns);

%% Extract the 4th blob into it's own binary image.
BLOOBS = {}
for i = 1: numBlobs
    k = ismember(labeledImage, i) > 0;
    BLOOBS(i) = {k}
    figure
    imshow(k)
    title(strcat('plot',num2str(i)))
end 
%%
figure
subplot(2,2,1)
imshow(BLOOBS{1,1})
title('Top-left sign')
subplot(2,2,2)
imshow(BLOOBS{1,2})
title('Bottom-left sign')
subplot(2,2,3)
imshow(BLOOBS{1,3})
title('Top-right sign')
subplot(2,2,4)
imshow(BLOOBS{1,4})
title('Bottom-right sign')

%%
[B,L] = bwboundaries(ISigns,'noholes');
%imshow(label2rgb(L, @jet, [.5 .5 .5]))
%hold on
%for k = 1:length(B)
%   boundary = B{k};
%   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
%end

%% Finding corners in image.
COORNERS = {}
IDEALCOORNERS = {}
for i = 1: numBlobs
% Finding corners in image
        [rows columns numberOfColorBands] = size(ISigns);
        boundaries = bwboundaries(BLOOBS{1,i});
        xCoords = boundaries{1}(:, 2);
        yCoords = boundaries{1}(:, 1);

% Find out which index is closest to the upper left corner
        distances = sqrt((xCoords-1).^2+(yCoords-1).^2);
        [minDistanceUL, minIndexUL] = min(distances);

% Find out which index is closest to the upper right corner
        distances = sqrt((xCoords-columns).^2 + (yCoords - 1).^2);
        [minDistanceUR, minIndexUR] = min(distances)
% Find out which index is closest to the lower left corner
        distances = sqrt((xCoords - 1).^2 + (yCoords - rows).^2);
        [minDistanceLL, minIndexLL] = min(distances)
% Find out which index is closest to the lower right corner
        distances = sqrt((xCoords - columns).^2 + (yCoords - rows).^2);
        [minDistanceLR, minIndexLR] = min(distances)

% Plot circles over the corners, just for visualization purposes - for fun.
        xCorners = [xCoords(minIndexUL), xCoords(minIndexUR), xCoords(minIndexLR), xCoords(minIndexLL)]
        yCorners = [yCoords(minIndexUL), yCoords(minIndexUR), yCoords(minIndexLR), yCoords(minIndexLL)]
        figure
        imshow(ISigns)
        hold on;
        plot(xCorners, yCorners, 'ro');
        title(strcat('Bad image with corners located - ',num2str(i)));
        
        A = [xCorners(:), yCorners(:)];
        COORNERS{i}=A;  
        
% Determine ideal corner locations - aligned with raster lines
        x1 = mean([xCorners(1), xCorners(4)])
        x2 = mean([xCorners(2), xCorners(3)])
        y1 = mean([yCorners(1), yCorners(2)])
        y2 = mean([yCorners(3), yCorners(4)])
        
        xIdealCorners = [x1 x2 x2 x1];
        yIdealCorners = [y1 y1 y2 y2];
        B = [xIdealCorners(:), yIdealCorners(:)];
        IDEALCOORNERS{i} = B;
% Show this
    figure
    subplot(2, 2, 2);
    imshow(ISigns);
    hold on;
    plot([x1 x2 x2 x1 x1], [y1 y1 y2 y2 y1], 'r-', 'LineWidth', 3);
    title('Bad image with perfect rectangular overlaid');
end

%% Determine ideal corner locations - aligned with raster lines
x1 = mean([xCorners(1), xCorners(4)])
x2 = mean([xCorners(2), xCorners(3)])
y1 = mean([yCorners(1), yCorners(2)])
y2 = mean([yCorners(3), yCorners(4)])
% Show this
figure
subplot(2, 2, 2);
imshow(ISigns);
hold on;
plot([x1 x2 x2 x1 x1], [y1 y1 y2 y2 y1], 'r-', 'LineWidth', 3);
title('Bad image with perfect rectangular overlaid');

%%
% Warp the image to straighten it.
%badXY = [xCorners; yCorners]'
%desiredXY = [x1 x2 x2 x1; y1 y1 y2 y2]'
% Transform to a quadrilateral with vertices badXY
% into a quadrilateral with vertices desiredXY.
%tform = maketform('projective', badXY, desiredXY);
% Fix/warp the image.
%[binaryImage3, xdata, ydata] = imtransform(ISigns, ...
%	tform, 'bicubic', 'size', size(ISigns));
% Display the fixed image.
%subplot(2, 2, 3);
%imshow(binaryImage3);
%title('Fixed image');

%% Plotting ROI in original image.
BW = roipoly(ISigns, xCorners, yCorners);


desiredColor = [146, 40, 146];

redChannel(BW) = desiredColor(1);
greenChannel(BW) = desiredColor(2);
blueChannel(BW) = desiredColor(3);

%Recombine separate color channels into a single, true color RGB image.
rgbImage = cat(3, redChannel, greenChannel, blueChannel);
% Display the image.
subplot(1, 2, 1);
imshow(rgbImage);
title('Image with color inside the mask region');


%% Plotting ROI In own image
FINALBLOOBS = {}
for i = 1:numBlobs
    
    xValues = IDEALCOORNERS{i}(:,1);
    yValues = IDEALCOORNERS{i}(:,2);
    
    C = roipoly(I,xValues, yValues);
    
    FINALBLOOBS{i} = C;
    %COORNERS{i}=A;
    %IDEALCOORNERS{i} = B;
end

