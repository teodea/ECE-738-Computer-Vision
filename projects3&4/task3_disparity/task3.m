left_img_path = fullfile('../images/ReconstructionData/L_rectified_stereo', "L_rectified_stereoU1.jpg");
right_img_path = fullfile('../images/ReconstructionData/R_rectified_stereo', "R_rectified_stereoU1.jpg");
left_img = rgb2gray(imread(left_img_path));
right_img = rgb2gray(imread(right_img_path));
left_img = padarray(left_img, [3 3], 0, "post");
right_img = padarray(right_img, [3 3], 0, "post");

visited = [];
i = 1;
left_matches = all_left{1}.Location(:, :);
right_matches = all_right{1}.Location(:, :);

figure;
showMatchedFeatures(left_img, right_img, left_matches, right_matches, 'montage');

disp(length(left_matches))
while i < length(left_matches)
    left = round(left_matches(i, :)); 
    right = round(right_matches(i, :));
    [new_left_matches, new_right_matches, visited] = disparity_grow(left, right, visited, left_img, right_img);
    for j=1:size(new_left_matches, 1)
        left_matches = [left_matches;new_left_matches(j, :)];
        right_matches = [right_matches;new_right_matches(j, :)];
    end
    i = i + 1;
end
disp(i)

figure;
showMatchedFeatures(left_img, right_img, left_matches, right_matches, 'montage');


function [new_left_matches, new_right_matches, visited] = disparity_grow(left, right, visited, left_img, right_img)
    disparity = right(1,1) - left(1,1);
    x_l = left(1, 1);
    y_l = left(1, 2);
    new_left_matches = [];
    new_right_matches = [];
    neighbors = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
    for i=1:size(neighbors,1)
        dx = neighbors(i, 1);
        dy = neighbors(i, 2);
        x_l_cur = x_l + dx;
        y_l_cur = y_l + dy;
        if x_l_cur < 1 || x_l_cur > size(left_img, 1) || y_l_cur < 1 || y_l_cur > size(left_img, 2)
            continue
        end
        if any(ismember(visited,[x_l_cur y_l_cur]))
            disp("SKIP")
            continue
        end
        visited = [visited;x_l_cur y_l_cur];
        [x_r_cur, y_r_cur] = best_disparity(x_l_cur, y_l_cur, disparity, left_img, right_img);
        if x_r_cur > -1
            new_left_matches = [new_left_matches;x_l_cur y_l_cur];
            new_right_matches = [new_right_matches;x_r_cur y_r_cur];
        end
    end
end

function [best_x, best_y] = best_disparity(x_l, y_l, disparity, left_img, right_img)
    x_r = x_l + disparity;
    y_r = y_l;
    neighbors = [[-1, -1], [0, -1], [1, -1], [0,0], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
    best_SSD = 1000000; % need to finetune this
    best_x = -1;
    best_y = -1;
    for i=1:size(neighbors,1)
        % NEED TO DEAL WITH IOB. IF IOB, DO NOT CALL GET_SSD
        dx = neighbors(i, 1);
        dy = neighbors(i, 2);
        x_r_cur = x_r + dx;
        y_r_cur = y_r + dy;
        if x_r_cur < 1 || x_r_cur > size(right_img, 1) || y_r_cur < 1 || y_r_cur > size(right_img, 2)
            continue
        end
        SSD = get_SSD(x_l, y_l, x_r_cur, y_r_cur, left_img, right_img);
        if SSD < best_SSD
            best_SSD = SSD;
            best_x = x_r_cur;
            best_y = y_r_cur;
        end
    end
end

function [SSD] = get_SSD(x_l, y_l, x_r, y_r, left_img, right_img)
    % Assumes all coordinates are not IOB
    left_patch = double(left_img(x_l:x_l+3, y_l:y_l+3));
    right_patch = double(right_img(x_r:x_r+3, y_r:y_r+3));
    diff = left_patch - right_patch;
    SSD = sum(diff(:).^2);
    %disp(SSD)
end

%any(ismember(visited,new,'rows'));
