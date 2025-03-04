addpath("../task2_feature_matching/");

% PARAMS
SSD_threshold = 5000;

% get left and right images. Pad by 3 on right and bottom for SSD calculation
left_img_path = fullfile('../images/ReconstructionData/L_rectified_stereo', "L_rectified_stereoU1.jpg");
right_img_path = fullfile('../images/ReconstructionData/R_rectified_stereo', "R_rectified_stereoU1.jpg");
left_img = rgb2gray(imread(left_img_path));
right_img = rgb2gray(imread(right_img_path));
left_img = padarray(left_img, [3 3], 0, "post");
right_img = padarray(right_img, [3 3], 0, "post");

% get matches from task 2
[all_matched_points_left, all_matched_points_right] = task2();
left_matches = round(all_matched_points_left{1}.Location(:, :));
right_matches = round(all_matched_points_right{1}.Location(:, :));

% show initial
figure;
showMatchedFeatures(left_img, right_img, left_matches, right_matches, 'montage');
disp("initial matches")
disp(size(left_matches, 1))

% go through all matches and do neighbor growing on each
i = 1;
visited = zeros(size(left_img, 1:2));
visited(left_matches) = 1;
while i<=size(left_matches, 1)
    x_l = left_matches(i, 1);
    y_l = left_matches(i, 2);
    x_r = right_matches(i, 1);
    y_r = right_matches(i, 2);
    disparity = x_r - x_l;
    % go through all neighbors of (x_l, y_l) and find best match for each
    for dx=-1:1
        for dy=-1:1
            % skip current pixel
            if dx == 0 && dy == 0
                continue
            end
            x_l_match = x_l + dx;
            y_l_match = y_l + dy;

            % skip IOB pixels or visited pixles
            if invalid_pixel(x_l_match, y_l_match, left_img)
                continue
            end

            if visited(y_l_match, x_l_match) == 1
                continue
            end

            % get best match in right image and its SSD
            [x_r_match, y_r_match, SSD] = best_match(x_l_match, y_l_match, disparity, left_img, right_img);

            % only keep match if SSD below threshold
            if SSD <= SSD_threshold
                left_matches = [left_matches; x_l_match y_l_match];
                right_matches = [right_matches; x_r_match y_r_match];
                visited(y_l_match, x_l_match) = 1;
            end
        end
    end
    i = i + 1;
end

% show after
figure;
showMatchedFeatures(left_img, right_img, left_matches, right_matches, 'montage');

disp("final matches")
disp(size(left_matches, 1))

function [x_r_match, y_r_match, SSD] = best_match(x_l_match, y_l_match, disparity, left_img, right_img)
    % center is what would be the match if disparity was the same and y was the same
    x_r_center = x_l_match + disparity;
    y_r_center = y_l_match;

    x_r_match = -1;
    y_r_match = -1;
    best_SSD = Inf;

    % go through all possible matches (i.e. the region surrounding and including the center
    for dx=-1:1
        for dy=-1:1
            x_r_cur = x_r_center + dx;
            y_r_cur = y_r_center + dy;

            % skip IOB pixels
            if invalid_pixel(x_r_cur, y_r_cur, right_img)
                continue
            end

            SSD = get_SSD(x_l_match, y_l_match, x_r_cur, y_r_cur, left_img, right_img);
            if SSD < best_SSD
                x_r_match = x_r_cur;
                y_r_match = y_r_cur;
                best_SSD = SSD;
            end
        end
    end
end

function [SSD] = get_SSD(x_l, y_l, x_r, y_r, left_img, right_img)
    % Assumes all coordinates are not IOB
    % Important: matlab images are (y,x) NOT (x,y)!
    left_patch = double(left_img(y_l:y_l+3, x_l:x_l+3));
    right_patch = double(right_img(y_r:y_r+3, x_r:x_r+3));
    diff = left_patch - right_patch;
    SSD = sum(diff(:).^2);
end

function [invalid] = invalid_pixel(x, y, img)
    if x < 1 || x + 3 > size(img, 2) || y < 1 || y + 3 > size(img, 1)
        invalid = true;
    else
        invalid = false;
    end
end