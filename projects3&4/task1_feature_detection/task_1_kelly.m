clc; clear; close all;
%https://www.mathworks.com/help/matlab/ref/clc.html
%https://www.mathworks.com/help/matlab/ref/clear.html
%https://www.mathworks.com/help/matlab/ref/close.html


unzip('C:\Users\knr20\Downloads\Project 3 & 4\L_rectified.zip', 'left_images');
unzip('C:\Users\knr20\Downloads\Project 3 & 4\R_rectified.zip', 'right_images');
%https://www.mathworks.com/help/matlab/ref/unzip.html


leftFiles = dir(fullfile('left_images', '*.JPG')); 
rightFiles = dir(fullfile('right_images', '*.JPG'));
%https://www.mathworks.com/help/matlab/ref/dir.html; dir(pathname) lists
%all files in the specified folder that match the pattern (*.JPG)
%https://www.mathworks.com/help/matlab/ref/fullfile.html; fullfile(folder,
%filename) builds a file path regardless of the operating system


leftFiles = sort({leftFiles.name}); 
rightFiles = sort({rightFiles.name});
%https://www.mathworks.com/help/matlab/ref/sort.html;
%{leftFiles.name} extracts file names from the directory structure
%sort(cellArray) sorts filenames to make sure the images are processed in
%order


if length(leftFiles) ~= length(rightFiles)
    error('mismatch: number of left & right images must be equal');
end
%https://www.mathworks.com/help/matlab/ref/error.html
%length(array) helps with returning the number of elements in an array
%error(message) helps with displaying an error message. This also stops
%execution if the condition is met


numPairs = length(leftFiles);
featureData = struct();
%https://www.mathworks.com/help/matlab/ref/struct.html
%This section stores the number of image pairs & also starts a struct to
%help with storing the feature data
%struct helps w/ creating an empty structure array


for i = 1:numPairs %this for-loop iterates over all the image pairs; the 1:numPairs loops from 1 to the total number of image pairs (in our case is 15 images; so 1 to 15)
    fprintf('processing image pair %d of %d...\n', i, numPairs);
    %https://www.mathworks.com/help/matlab/ref/fprintf.html;
    %fprintf(format, values) helps w/ printing formatted text to the command
    %window; in this case, the code is simply mentioning which image pair
    %is being processed to help me keep track


    leftImage = imread(fullfile('left_images', leftFiles{i})); %imread helps w/ reading the image from the file; https://www.mathworks.com/help/matlab/ref/imread.html
    if size(leftImage, 3) == 3 %size(array, dim) helps w/ checking if the image has 3 channels RGB
        leftImage = rgb2gray(leftImage); %rgb2gray(image) helps w/ turning the image to grayscale (assuming it is in color, & which is the case for the images the professor provided)
    end
    %https://www.mathworks.com/help/matlab/ref/rgb2gray.html


    harrisPoints = detectHarrisFeatures(leftImage); %https://www.mathworks.com/help/vision/ref/detectharrisfeatures.html
    siftPoints = detectSIFTFeatures(leftImage); %https://www.mathworks.com/help/vision/ref/detectsiftfeatures.html
    surfPoints = detectSURFFeatures(leftImage); %https://www.mathworks.com/help/vision/ref/detectsurffeatures.html



    %Combine features & remove duplicates
    allPoints = [harrisPoints.Location; siftPoints.Location; surfPoints.Location]; %combines feature locations from the 3 methods
    allMetrics = [harrisPoints.Metric; siftPoints.Metric; surfPoints.Metric]; %Metric values represent feature strength for non-max suppression
    %https://www.mathworks.com/help/matlab/ref/unique.html

    [uniquePoints, idx] = unique(allPoints, 'rows'); %Remove duplicate feature locations
    uniqueMetrics = allMetrics(idx); %Get corresponding metric values after removing duplicates


    %Non-Maximum Suppression helps to ensure that features are well distributed in space and 
    %only strongest features remain within a certain neighborhood
    
    %Here the suppression radius is defined in pixels
    minDist = 5; %This value determines how close two keypoints are. In other words, it sets a minimum distance treshold (in this case, in pixels)
    %between 2 keypoints. This is needed because if 2 features are too
    %close, they may be representing the same part of a specific object on
    %the images. Therefore, choosing the strongest feature helps to
    %minimize redundancy
    %The minDist value can be selected manually based on the feature
    %distribution. A similar approach can be see in non maximum suppresion
    %techniques here: https://www.mathworks.com/help/vision/ref/selectstrongest.html


    %This step helps to create a logical array, which keeps track of selected features
    keep = true(size(uniquePoints,1),1);
    %The purpose is to create a logical array with the same length as the
    %uniquePoints section that identifies the keypoints that would need to
    %be kept
    %At the beginning, the script assumes that all the keypoints are to be
    %kept (which is "true" for every point, as shown above)
    %However, as the points are being processed, the script suppreses
    %weaker ones (false)
    %This logical array approach is often used for point selection:
    %https://www.mathworks.com/help/matlab/ref/logical.html



    %This section helps w/ iterating over every unique feature point
    for j = 1:size(uniquePoints,1)
        if keep(j) %This line/condition helps w/ only processing points that have not been suppressed
        %show reference here


            %This section helps w/ computing Euclidean distance from the
            %current keypoint "j" to the other keypoints
            dists = vecnorm(uniquePoints - uniquePoints(j,:), 2, 2); 
            %vecnorm(A,2,2) helps w/ computing the Euclidean norm (or L2
            %norm) row wise for each of the feature points
            %uniquePoints - uniquePoints(j,:) assists w/ substracting a jth
            %keypoint from the other points. Finally, the resulting
            %distances are stored in "dists"
            %https://www.mathworks.com/help/matlab/ref/vecnorm.html
       

            %This section helps w/ finding keypoints that are too close
            closePts = find(dists < minDist);
            %The purpose is to find indices of all points close than
            %minDist pixels to the current keypoint
            %Here is how this works: the find() function provides the
            %indices of elements in dists that meet the condition dists <
            %minDist
            %These indices correspond to the feature points too close to
            %the current keypoint
            %https://www.mathworks.com/help/matlab/ref/find.html

            
            %This section helps to identify the strongest feature in the
            %group of the close points
            [~, maxIdx] = max(uniqueMetrics(closePts));
            %Here is how this works: uniqueMetrics(closePts) obtains the
            %metric values (aka strengths) of the close points
            %max() helps w/ finding the index of the strongest feature
            %among the closePts (like the professor mentioned during
            %lecture)
            %Also, the "~" symbol assists w/ ignoring the max value as we'd
            %only need the index in this case
            %The max() function helps to find the maximum value in an
            %array: https://www.mathworks.com/help/matlab/ref/max.html
            
    
            %This section helps to suppress the weaker features
            %The purpose is to suppress the features in the close region
            %(shown below as "false" in "keep" array), & keeping the
            %strongest feature (shown below as "true" in "keep" array also)
            %The reason this works is because after maxIdx is determined,
            %the function would make sure that the other keypoints in
            %closePts section are removed. As a result, the strongest is
            %kept
            %I learned that this technique is often used in object
            %detection & feature selection: https://www.mathworks.com/help/vision/ref/selectstrongest.html
            keep(closePts) = false; %Suppressing weaker features
            keep(closePts(maxIdx)) = true; %Keeping strongest feature
        end
    end
    selectedPoints = uniquePoints(keep, :); %This section helps w/ storing the retained features. It would select the final non-suppresed feature points
    %the "keep" array masks the keypoints that remain
    %Finally, the set of filtered keypoints would be stored in
    %"selectedPoints"


    %This section stores feature points for each of the images in the structure
    featureData(i).leftImageName = leftFiles{i};
    featureData(i).featurePoints = selectedPoints;
end


save('featurePoints.mat', 'featureData'); %saves the extracted feature points
%https://www.mathworks.com/help/matlab/ref/save.html


%Visualize extracted features
for i = 1:numPairs %loops through each image pair to visualize feature points
    fprintf('Visualizing features for image pair %d of %d...\n', i, numPairs);

    % Reload grayscale image for display; this section reads & converts the
    % images to grayscale for visualization
    leftImage = imread(fullfile('left_images', leftFiles{i}));
    if size(leftImage, 3) == 3
        leftImage = rgb2gray(leftImage);
    end


    % Extract stored feature points
    allPoints = featureData(i).featurePoints;


    %display the image for visualization purposes; https://www.mathworks.com/help/matlab/ref/imshow.html
    figure; imshow(leftImage); hold on;

    % Plot extracted feature points as yellow circles; https://www.mathworks.com/help/matlab/ref/plot.html
    if ~isempty(allPoints)
        plot(allPoints(:,1), allPoints(:,2), 'yo', 'MarkerSize', 3, 'LineWidth', 1);
    end

    %display title & a pause before the next image
    title(sprintf('Detected features for left image %d', i));
    hold off;

    % Pause for user to view image; https://www.mathworks.com/help/matlab/ref/pause.html
    pause(0.5);
end


%this script follows a structured workflow for processing stereo image
%pairs. It also extracts the key feature points and applies non maximum
%suppresion to help w/ selecting high quality feature. This script begins
%w/ pre-processing. Here, the workspace is cleared & image files are
%extracted from the provided zip folders. Afterward, the images are loaded
%& sorted, obtaining the image names from the extracted folders, organizing
%them to keep the left & right image pairing. It also makes sures that
%the same number of left & right images exist to avoid any errors in the
%processing step

%this script also performs feature detection & storage. It uses three known
%methods (also mentioned in the project description for task 1), Harris,
%SIFT, & SURF. Combining these helps to have a set of features that
%identify different types of keypoints in the images. The duplicate points
%are removed using unique() function. Furthermore, the script also
%implements non-maximum suppression, which in this case, helps to minimize
%redundancy. It keeps the strongest features in the given neighborhood.
%Additionally, the suppression radius (in this case, minDist) helps w/
%defining a minimum distance between 2 keypoints. This help to prevent
%multiple weak detections arounf a similar region

%the script also calculates Euclidean distances b/w all detected keypoints
%using vecnorm() & assists w/ identifying the clusters of features within
%the suppresion radius using find(). The feature with highest strength
%metric (obtained using max()) is kept, & the weaker features are
%suppressed. As a result, only the well distributed features remain,
%helping to improve robustness in the extracted keypoints

%After the refined feature set is obtained the script also
%performs data storage. This helps to save the extarcted feature points
%into the structured array (in this case, "struct"). It then exports them
%as a .mat file for future use

%Finally, the visualization section uses imshow() function to help w/
%displaying images & plot() to identify the feature locations. The
%visualization part helps w/ assessing whether the feature distribution is
%appropriate. The strongest keypoints are shown after the suppresion