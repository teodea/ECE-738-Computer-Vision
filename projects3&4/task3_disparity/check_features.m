[all_left_matches, all_right_matches] = task3();

left_files = dir(fullfile('../images/ReconstructionData/L_rectified_stereo', '*.jpg')); 
right_files = dir(fullfile('../images/ReconstructionData/R_rectified_stereo', '*.jpg')); 

while true
    % pick random image
    rand = randi([1, 10],1);
    left_img_path = fullfile('../images/ReconstructionData/L_rectified_stereo', left_files(rand).name);
    right_img_path = fullfile('../images/ReconstructionData/R_rectified_stereo', right_files(rand).name);

    left_img = imread(left_img_path);
    right_img = imread(right_img_path);
    left_matches = all_left_matches{rand};
    right_matches = all_right_matches{rand};

    % picks 10 random features and shows them
    mask = randi(size(left_matches, 1), 10, 1);  
    left_matches = left_matches(mask, :);
    right_matches = right_matches(mask, :);


    figure;
    showMatchedFeatures(left_img, right_img, left_matches, right_matches, 'montage');

    % waits until user hits enter
    pause;
end