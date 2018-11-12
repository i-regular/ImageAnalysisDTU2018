

close all
clear all

%% Sign number
nSign1 = 1;

%% Image Name
ImageName = sprintf('DTUSignPhotos/DTUSigns%03d.jpg', nSign1);

%% Loading in image
I = imread(ImageName);


%%
r = I(:, :, 1);
g = I(:, :, 2);
b = I(:, :, 3);

%% Enhance Truecolor composite with a contrast stretch


%% Enhance Truecolor Composite  with a Decorrelation stretch 
decorrstretched_truecolor = decorrstretch(I, 'Tol', 0.01);
figure
imshow(decorrstretched_truecolor)
title('Truecolor composite after Decorrelation Stretch')

%% Showing scatter plot for decorrstretched
r = decorrstretched_truecolor(:,:,1);
g = decorrstretched_truecolor(:,:,2);
b = decorrstretched_truecolor(:,:,3);

%% lABEL Image
IB = r > 189 & g < 5 & b < 180 ;
labeledImage = IB;

%% Filling out holes in image
BF = imfill(IB, 'holes');
imshow(BF)


%% Thresholding Intensity Space
se1 = strel('disk',3);
se2 = strel('disk',3);      %Husk at en 3x3 disk har indekset 1 i koden.

BF = bwareaopen(BF,1187);
BF = imfill(BF,'holes');
BF = imclearborder(BF,8);
NewImage3 = BF;

%% Thresholding on Normalized Image feature
BinaryI = my_threshold(I,[120,256;37,80;37,80]);
figure()
imshow(BinaryI)
title('Type = Normalized')

BinaryI = bwareaopen(BinaryI,1187);
BinaryI = imfill(BinaryI,'holes');
BinaryI = imclearborder(BinaryI,8);

%% Closeing with line kernel
se1 = strel('line',8,0);
se2 = strel('line',8,0);

NormalizedI = mclose(BinaryI,se1);
IntensityI  = mclose(NewImage3,se1);

%% Filling holes
NormalizedI = imfill(NormalizedI,'holes');
IntensityI  = imfill(IntensityI,'holes');
    
%% Removing outliers
se1 = strel('square',3);
NormalizedI = imerode(NormalizedI,se1);
IntensityI = imerode(IntensityI,se1);

%% 
sign=NormalizedI & IntensityI;
NewImage1 = sign;

figure 
imshow(NewImage1);
title("Thresholded image");

%% Clearing borders
BWnobord = imclearborder(NewImage1, 8);
figure, imshow(BWnobord), title('cleared border image');

imwrite(BWnobord, 'BWnobord.png')

%% remove small stuff
BW_out = bwareaopen(BWnobord, 1000);

[B,L,N] = bwboundaries(BW_out);

ISigns = BW_out;

figure
subplot(1,2,1)
imshow(I)
title('Original Image');
subplot(1,2,2)
imshow(ISigns)
title('Sign detection');

[labeledImage, numBlobs] = bwlabel(ISigns);

BLOOBS = {}
for i = 1: numBlobs
    k = ismember(labeledImage, i) > 0;
    BLOOBS(i) = {k}
    figure
    imshow(k)
    title(strcat('plot',num2str(i)))
end 

%%
[B,L] = bwboundaries(ISigns,'noholes');


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

% Plot circles over the corners, just for visualization purposes - for fun - woho.
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

%% Plotting ROI In own image
FINALBLOOBS = {}
count = 1;
for i = 1:numBlobs
    
    xValues = IDEALCOORNERS{i}(:,1);
    yValues = IDEALCOORNERS{i}(:,2);
    imperfectBloob = BLOOBS{1,i};
    imperfectstats = regionprops(imperfectBloob,'BoundingBox', 'Area','Extent');
    idealbloob = roipoly(I,xValues, yValues);
    % let's do some awesome things on this 
    % do some redundant work just to get it running
    statsideal = regionprops(idealbloob,'BoundingBox', 'Area');

    %% gets the relationship between the area and the bounding box
    BBAreaRatio = ((abs((statsideal.BoundingBox(3) * statsideal.BoundingBox(4))) / statsideal.Area));
    % find out whether or not we should include the image based on my
    % magic numbers 
    % below wont work on big skilte
    maxArea = max(statsideal.Area, imperfectstats.Area);
    minArea = min(statsideal.Area, imperfectstats.Area);
    width = statsideal.BoundingBox(3);
    height = statsideal.BoundingBox(4);

    disp(imperfectstats.Extent);
    if(imperfectstats.Extent > 0.45 && ((minArea / maxArea) > 0.4) && width > (height * 2))
        disp("hello world")
        disp(maxArea);
        disp(minArea);
        FINALBLOOBS{count} = imperfectBloob;
        count = count + 1;
        % show the shit
        [r,c,d]=size(I);
        Ir=I(:,:,1);
        Ib=I(:,:,2);
        Ig=I(:,:,3);
        Iz=zeros(r,c,d);
        zr=Iz(:,:,1);
        zb=Iz(:,:,2);
        zg=Iz(:,:,3);
        zr(imperfectBloob)=Ir(imperfectBloob);
        zb(imperfectBloob)=Ib(imperfectBloob);
        zg(imperfectBloob)=Ig(imperfectBloob);
        Iz(:,:,1)=zr;
        Iz(:,:,2)=zb;
        Iz(:,:,3)=zg;
        rgbImage = uint8(Iz);
        %figure
        %imshow(rgbImage);
        % 
        hsvImage = rgb2hsv(rgbImage);
        hImage = hsvImage(:, :, 1);
        sImage = hsvImage(:, :, 2);
        vImage = hsvImage(:, :, 3);
        
        rnew = rgbImage(:, :, 1);
        gnew = rgbImage(:, :, 2);
        bnew = rgbImage(:, :, 3);
        GreyImage = gnew+bnew;
        whiteImage = ImageThreshold(GreyImage,225);
        % Now get white pixels.
        %whitePixels = vImage > 0.7; % or whatever.
        % Now get black pixels.
        threshedImage = (rnew > 0) | (gnew > 0) | (bnew > 0);
        allPixelscount = sum((threshedImage(:)));
        allWhitePixelcount = sum(whiteImage(:));
        disp("printing whitepixel pixel count and all count");
        disp(allWhitePixelcount);
        disp(allPixelscount);
        whitetotalratio = ((allWhitePixelcount / (allPixelscount)) * 100)
        disp(whitetotalratio);
        if(allWhitePixelcount > 30)
           figure;
           imshow(rgbImage)
           title("I believe this shit is a sign");
        end
    end
end

