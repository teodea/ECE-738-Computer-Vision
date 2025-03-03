addpath("../task2_feature_matching");

%[all_matched_points_left, all_matched_points_right] = task2();

num_picture_pairs = length(all_matched_points_left);

all_disparities = cell(num_picture_pairs, 1);

for i = 1:num_picture_pairs
    points_left = all_matched_points_left{i}.Location;
    points_right = all_matched_points_right{i}.Location;
    
    disparities = points_left(:, 1) - points_right(:, 1); % using only x-coordinate
    all_disparities{i} = disparities;
end

f = 1277;
B = 259.3;

all_depths = cell(num_picture_pairs, 1);

for i = 1:num_picture_pairs
    disparities = all_disparities{i};

    depths = f * B ./ disparities;
    all_depths{i} = depths;
end

left_files = dir(fullfile('../images/ReconstructionData/L_rectified_stereo', '*.jpg'));
right_files = dir(fullfile('../images/ReconstructionData/R_rectified_stereo', '*.jpg'));

for i = 1:num_picture_pairs
    left_img = imread(fullfile('../images/ReconstructionData/L_rectified_stereo', left_files(i).name));
    right_img = imread(fullfile('../images/ReconstructionData/R_rectified_stereo', right_files(i).name));

    figure;
    subplot(1, 2, 1);
    imshow(left_img); hold on;
    scatter(all_matched_points_left{i}.Location(:,1), all_matched_points_left{i}.Location(:,2), 10, all_depths{i}, 'filled');
    title(['Left Image with Depth for Pair ', num2str(i)]);
    colormap jet;
    colorbar;

    subplot(1, 2, 2);
    imshow(right_img); hold on;
    scatter(all_matched_points_right{i}.Location(:,1), all_matched_points_right{i}.Location(:,2), 36, all_depths{i}, 'filled');
    title(['Right Image with Depth for Pair ', num2str(i)]);
    colormap jet;

    axis equal;
    hold off;
end


