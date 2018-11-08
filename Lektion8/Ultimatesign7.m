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
BI = Ired > 105 & Ired < 235  & Igreen > 26 & Igreen < 117 & Iblue > 25 & Iblue < 129 & (abs(Iblue - Igreen) < 20);
%% Filling out holes in image
BF = imfill(BI, 'holes');

%% Connecting components
[ImageConnected1, CON1] = bwlabel(BF);
[ImageConnected2, CON2] = bwlabel(BF);

%%
%stats = [regionprops(ImageConnected1); regionprops(not(ImageConnected1))]
% show the image and draw the detected rectangles on it
figure
imshow(ImageConnected1); 

%% Creating Kernel 
% Designing kernels/structural elements
se1 = strel('square',9);
se2 = strel('square',5);      %Husk at en 3x3 disk har indekset 1 i koden.

NewImage1 = mopen(ImageConnected1,se1);
NewImage1 = mclose(NewImage1,se2);

%% Clearing borders
BWnobord = imclearborder(NewImage1, 8);
figure, imshow(BWnobord), title('cleared border image');

imwrite(BWnobord, 'BWnobord.png')

%% remove small stuff
BW_out = bwareaopen(BWnobord, 4000);

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
    if( imperfectstats.Extent > 0.6 && ((statsideal.Area / imperfectstats.Area) > 0.9) && (statsideal.BoundingBox(3) > statsideal.BoundingBox(4)) && statsideal.BoundingBox(3)*2 >= statsideal.BoundingBox(4)) 
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
        figure;
        imshow(uint8(Iz))
        title("I believe this shit is a sign");
    end
end

