addpath("../task1_feature_detection");

left_files = dir(fullfile('../images/L_rectified', '*.jpg'));
right_files = dir(fullfile('../images/R_rectified', '*.jpg'));

for i = 1:length(left_files)
    left_img_path = fullfile('../images/L_rectified', left_files(i).name);
    right_img_path = fullfile('../images/R_rectified', right_files(i).name);
    left_img = rgb2gray(imread(left_img_path));
    right_img = rgb2gray(imread(right_img_path));

    left_features = retrievingFeatures(left_img_path);
    right_features = retrievingFeatures(right_img_path);

    [descriptors_left, valid_points_left] = extractFeatures(left_img, left_features);
    [descriptors_right, valid_points_right] = extractFeatures(right_img, right_features);

    indexPairs = matchFeatures(descriptors_left, descriptors_right, 'MatchThreshold', 10, 'MaxRatio', 0.6);

    matched_points_left = valid_points_left(indexPairs(:,1));
    matched_points_right = valid_points_right(indexPairs(:,2));
    
    figure;
    
    showMatchedFeatures(left_img, right_img, matched_points_left, matched_points_right, 'montage');

    disp('done');
end