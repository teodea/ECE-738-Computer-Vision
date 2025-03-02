clc; clear; close all; %Clear workspace, command window, and close figures
% https://www.mathworks.com/help/matlab/ref/clc.html
% https://www.mathworks.com/help/matlab/ref/clear.html
% https://www.mathworks.com/help/matlab/ref/close.html


% Ensure the output folder exists for storing matched feature data
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


% Processing each stereo pair & also converting to grayscale because SURF
% works better with grayscale images
% imread loads the image, im2gray converts to grayscale, & fullfile builds a full path
for i = 1:length(left_files)
    left_img = im2gray(imread(fullfile('L_rectified', left_files(i).name)));
    right_img = im2gray(imread(fullfile('R_rectified', right_files(i).name)));
    % https://www.mathworks.com/help/matlab/ref/imread.html
    % https://www.mathworks.com/help/matlab/ref/im2gray.html
    % https://www.mathworks.com/help/matlab/ref/fullfile.html


    % Detect & extract SURF features
    [features_left, valid_points_left] = extractFeatures(left_img, detectSURFFeatures(left_img));
    [features_right, valid_points_right] = extractFeatures(right_img, detectSURFFeatures(right_img));
    % Uses Speeded-Up Robust Features (SURF) detector to find keypoints in
    % each of the images. Also, extracts the feature descriptors from detected keypoints to be used for matching
    % Basically, detectSURFFeatures() helps with scanning the image &
    % identifying the crucial keypoints (e.g., edges, corners, textures).
    % Furthermore, it helps with identifying structures that look like corners
    % and blobs, where it could be obvious that the intensity has changed
    % significantly
    % Also, the keypoints are scale & rotation invariant, working under
    % different scales, rotations, and lighting conditions
    % As a result, SURF assists with feature detection that stays the same
    % across different views of a similar scene
    % https://www.mathworks.com/help/vision/ref/detectsurffeatures.html
    % https://www.mathworks.com/help/vision/ref/extractfeatures.html


    % Match features
    indexPairs = matchFeatures(features_left, features_right, 'MatchThreshold', 10, 'MaxRatio', 0.7);
    % Finds the correspondences between feature descriptors from the left & right images;
    % uses the descriptor similarity computed in extractFeatures() to determine the best matching feature pairs
    % This works the following way: Each feature descriptor (in this case,
    % the SURF descriptor) helps to represent a unique keypoint in the
    % image. matchFeatures() compares the feature descriptors in
    % features_left vs features_right. As a result, it can find the best
    % matches. Furthermore, this uses a nearest neighbor search to help
    % assess which features in the left image resemble those in the right
    % image the most. Note that these matches are identified based on the
    % Euclidean distance of the feature vectors. Finally, this returns
    % indexPairs, which is an Nx2 matrix, and each row has indices of a
    % matching feature in the features_left & features_right
    % https://www.mathworks.com/help/vision/ref/matchfeatures.html


    matchedPoints_left = valid_points_left(indexPairs(:,1));
    matchedPoints_right = valid_points_right(indexPairs(:,2));
    % This section extracts the matched keypoints from the left & right
    % images based on indexPairs (previously mentioned), and the points are
    % then used to help with visualization
    % Here is how this section works: indexPairs(:,1) selects the 1st
    % column of indexPairs, which contain the indices of the matched
    % features in the left image. Similarly, indexPairs(:,2) selects the
    % 2nd column of indexPairs, which also contains the indices of the
    % matched features in the right image
    % The valid_points_left(indexPairs(:,1)) obtains the actual keypoint
    % locations for the left image, and similarly,
    % valid_points_right(indexPairs(:,2)), obtains the actual keypoint
    % locations also for the right image
    % This section makes sure that only the matched features help to create
    % the visualization, instead of all the detected features


    % Save matched feature points for use in Task 3
    save(fullfile(output_folder, ['matchedFeatures_' num2str(i) '.mat']), 'matchedPoints_left', 'matchedPoints_right');
    % Saves the matched feature points as .mat files so they can be used
    % in Task 3, instead of re-detecting them again


    figure; % Creates a new figure window that shows the matched features;
    % helps to show each stereo pair in separate figure windows instead of overwriting the previous results
    % https://www.mathworks.com/help/matlab/ref/figure.html
    showMatchedFeatures(left_img, right_img, matchedPoints_left, matchedPoints_right, 'montage');
    % Helps to display the matched feature points between left & right images
    % Here left_img & right_img refer to the input images
    % matchPoints_left & matchedPoints_right are the matched keypoints that
    % would be drawn
    % Montage helps to show the images side by side with the lines
    % connecting all the matching points
    % Overall, this section helps to verify the quality of the feature
    % matching visually
    % https://www.mathworks.com/help/vision/ref/showmatchedfeatures.html


    title(['Matched features (pair ', num2str(i), ')']); % Creates a title on the figure window
    % num2str(i) helps to turn the stereo pair index into a string for the
    % labeling
    % ['Matched features (pair ', num2str(i), ')'] helps to concatenate the
    % text and index, which helps with labeling each figure separately
    % https://www.mathworks.com/help/matlab/ref/title.html

    
    saveas(gcf, fullfile(output_folder, ['FeatureMatch_' num2str(i) '.png']));
    % This section helps with saving the feature matching visualizations as image files
    % gcf helps with obtaining the current figure handle
    % ['FeatureMatch_' numstr(i) '.png'] names each output file as
    % "FeatureMatch_1.png", etc, & this is useful because we can save the
    % results for analysis without having to re-run the script
    % https://www.mathworks.com/help/matlab/ref/saveas.html
end



%this script extracts the rectified stereo image pirs from the provided zip
%folders, L_rectified.zip & R_rectified.zip. It then stores them into
%respective directories, L_rectified & R_rectified. Afterward, a list of
%image files is obtained from these directories

%Similarly to task 1, the script helps to make sure that the number of left
%& right images are the same. If there is a mismatch, an error will be
%shown & the program stops so it can be fixed. A processing loop iterates
%through the stereo image pairs, helping to load the left & right images.
%Furthermore, the images are converted to grayscale to help improve the
%feature detection through SURF

%The keypoints obtained identify the strong edges, corners, textured
%sections that remain invariant to the scale and rotation. The feature
%descriptors are then extracted for each detected keypoint, which helps to
%compare b/w the left & right images. Then, "matchFeatures" function is
%helps w/ searching for correspondences b/w the 2 sets of feature
%descriptors. It identifies pairs of points that may represent the same
%real-world feature

%When it comes to the visualization part, the script extracts the matched
%keypoints from both images & then plots. There is a figure for each of the
%stereo pairs. Also, "showMatchedFeatures" function helps w/ displaying
%matched features as a montage. In this section, the lines connect
%corresponding points b/w left & right images. As a result, the
%visualization section assists w/ assessing the feature matching quality

%For this script, the results are saved as image files using "saveas"
%function to avoid rerunning the script during future analyses, if needed