clc; clear; close all; %Clear workspace, command window, and close figures
% https://www.mathworks.com/help/matlab/ref/clc.html
% https://www.mathworks.com/help/matlab/ref/clear.html
% https://www.mathworks.com/help/matlab/ref/close.html


% Ensure output folder exists for storing matched feature data
output_folder = 'matched_features';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
% https://www.mathworks.com/help/matlab/ref/exist.html
% https://www.mathworks.com/help/matlab/ref/mkdir.html


% Extracting rectified stereo images from the zip folders helping to ensure
% that the required images are available for the processing section
unzip('L_rectified.zip', 'L_rectified');
unzip('R_rectified.zip', 'R_rectified');
% https://www.mathworks.com/help/matlab/ref/unzip.html


% Listing all image files in the extracted folders
left_files = dir(fullfile('L_rectified', '*.JPG')); % Adjust file type if necessary
right_files = dir(fullfile('R_rectified', '*.JPG'));
% https://www.mathworks.com/help/matlab/ref/dir.html


% This section helps to ensure the number of left & right images match.
% If there is a mismatch, then an error appears, stopping the program
% so we can fix the matching issue
if length(left_files) ~= length(right_files)
    error('Mismatch between the number of left and right images.');
end
% https://www.mathworks.com/help/matlab/ref/error.html


% Processing each stereo pair & also converting to grayscale because SIFT
% works better with grayscale images
% imread loads the image, im2gray converts to grayscale, & fullfile builds a full path
for i = 1:length(left_files)
    left_img = im2gray(imread(fullfile('L_rectified', left_files(i).name)));
    right_img = im2gray(imread(fullfile('R_rectified', right_files(i).name)));
    % https://www.mathworks.com/help/matlab/ref/imread.html
    % https://www.mathworks.com/help/matlab/ref/im2gray.html
    % https://www.mathworks.com/help/matlab/ref/fullfile.html


    % Detect & extract SIFT features
    [features_left, valid_points_left] = extractFeatures(left_img, detectSIFTFeatures(left_img));
    [features_right, valid_points_right] = extractFeatures(right_img, detectSIFTFeatures(right_img));
    % Uses Scale-Invariant Feature Transform (SIFT) detector to find keypoints in
    % each of the images. Also, extracts  feature descriptors from detected keypoints to be used for matching
    % SIFT is invariant to scale, rotation, and lighting conditions,  reliable for feature matching
    % detectSIFTFeatures() scans image & identifies crucial keypoints based on local gradients
    % This method ensures keypoint detection is robust across scales & views
    % https://www.mathworks.com/help/vision/ref/detectsiftfeatures.html
    % https://www.mathworks.com/help/vision/ref/extractfeatures.html


    % Match features
    indexPairs = matchFeatures(features_left, features_right, 'MatchThreshold', 10, 'MaxRatio', 0.7);
    % Finds correspondences b/w feature descriptors from the left & right images;
    % uses the descriptor similarity computed in extractFeatures() to determine best matching feature pairs
    % matchFeatures() uses a nearest-neighbor search to compare SIFT descriptors & find best matches
    % The Euclidean distance of feature vectors is used to measure similarity.
    % This function returns indexPairs, an Nx2 matrix where each row has indices of a matching feature
    % in features_left & features_right
    % https://www.mathworks.com/help/vision/ref/matchfeatures.html

    matchedPoints_left = valid_points_left(indexPairs(:,1));
    matchedPoints_right = valid_points_right(indexPairs(:,2));
    % Extracts matched keypoints from the left & right images based on indexPairs
    %used for visualization
    % indexPairs(:,1) selects indices of matched features in  left image
    % indexPairs(:,2) selects indices of matched features in  right image
    % valid_points_left(indexPairs(:,1)) gets  keypoint locations for  left image
    % valid_points_right(indexPairs(:,2)) gets keypoint locations for right image
    % ensures only  matched features contribute to visualization


    % Save matched feature points for use in Task 3
    save(fullfile(output_folder, ['matchedFeatures_' num2str(i) '.mat']), 'matchedPoints_left', 'matchedPoints_right');


    figure; % Creates new figure window that shows matched features
    % Helps to show each stereo pair in separate figure windows instead of overwriting previous results
    % https://www.mathworks.com/help/matlab/ref/figure.html
    showMatchedFeatures(left_img, right_img, matchedPoints_left, matchedPoints_right, 'montage');
    % Displays  matched feature points b/w left & right images.
    % showMatchedFeatures() overlays matching keypoints and connects them with lines.
    % 'Montage' mode places images side by side; helps assess feature matching quality.
    % https://www.mathworks.com/help/vision/ref/showmatchedfeatures.html

    title(['Matched features (pair ', num2str(i), ')']);
    % num2str(i) converts stereo pair index into string for labeling
    % ['Matched features (pair ', num2str(i), ')'] concatenates text & index
    % ensures each figure is labeled
    % https://www.mathworks.com/help/matlab/ref/title.html

    saveas(gcf, fullfile(output_folder, ['FeatureMatch_' num2str(i) '.png']));
    % Saves feature matching visualizations as image files
    % gcf gets the current figure handle
    % ['FeatureMatch_' numstr(i) '.png'] names each output file (e.g., "FeatureMatch_1.png")
    % allows for saving results w/o re-running script
    % https://www.mathworks.com/help/matlab/ref/saveas.html
end