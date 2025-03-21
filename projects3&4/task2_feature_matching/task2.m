function [all_matched_points_left, all_matched_points_right] = task2()
    
    % probably correct folder for task4 (for calibration data given) is
    % ReconstructionData
    left_files = dir(fullfile('../images/ReconstructionData/L_rectified_stereo', '*.jpg')); %'../images/ReconstructionData/L_rectified_stereo'
    right_files = dir(fullfile('../images/ReconstructionData/R_rectified_stereo', '*.jpg')); %'../images/ReconstructionData/R_rectified_stereo'
    
    all_matched_points_left = cell(length(left_files), 1);
    all_matched_points_right = cell(length(right_files), 1);

    for i = 1:length(left_files)
        left_img_path = fullfile('../images/ReconstructionData/L_rectified_stereo', left_files(i).name);
        right_img_path = fullfile('../images/ReconstructionData/R_rectified_stereo', right_files(i).name);
        left_img = rgb2gray(imread(left_img_path));
        right_img = rgb2gray(imread(right_img_path));
    
        left_features = retrievingFeatures(left_img_path);
        right_features = retrievingFeatures(right_img_path);
    
        [descriptors_left, valid_points_left] = extractFeatures(left_img, left_features);
        [descriptors_right, valid_points_right] = extractFeatures(right_img, right_features);
    
        indexPairs = matchFeatures(descriptors_left, descriptors_right, 'MatchThreshold', 10, 'MaxRatio', 0.6);
    
        matched_points_left = valid_points_left(indexPairs(:,1));
        matched_points_right = valid_points_right(indexPairs(:,2));

        % only keep features on nearly same scan line
        keep = true(size(matched_points_left, 1), 1);
        threshold = 20; % scan line offset
        [img_height, img_width] = size(left_img);
        fixed_margin_chosen = 400; % offset for x values margin
        for k = 1:length(keep)
            if abs(matched_points_left.Location(k,2) - matched_points_right.Location(k,2)) > threshold
                keep(k) = false;
            end
            if matched_points_left.Location(k,1) <= fixed_margin_chosen
                keep(k) = false;
            end
            if matched_points_right.Location(k,1) >= (img_width - fixed_margin_chosen)
                keep(k) = false;
            end
        end
        matched_points_left = matched_points_left(keep);
        matched_points_right = matched_points_right(keep);
      
        
        all_matched_points_left{i} = matched_points_left;
        all_matched_points_right{i} = matched_points_right;

        %figure;
        
        %showMatchedFeatures(left_img, right_img, matched_points_left, matched_points_right, 'montage');
    
        disp('done');
    end
end