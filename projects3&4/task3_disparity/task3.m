visited = [];
i = 1;
left_matches = matched_points_left.Location(:, :);
right_matches = matched_points_right.Location(:, :);
while i < length(left_matches)
    left = left_matches(i, :); 
    right = right_matches(i, :);
    [new_left_matches, new_right_matches] = disparity_grow(left, right, visited);
    for j=1:size(new_left_matches, 1)
        left_matches = [left_matches;new_left_matches(j, :)];
        right_matches = [right_matches;new_right_matches(j, :)];
    end
    i = i + 1;
end


function [new_left_matches, new_right_matches] = disparity_grow(left, right, visited)
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
        if any(ismember(visited,[x_l_cur y_l_cur]))
            continue
        end
        visited = [visited;x_l_cur y_l_cur];
        [x_r_cur, y_r_cur] = best_disparity(x_l_cur, y_l_cur, disparity);
        if x_r_cur > -1
            new_left_matches = [new_left_matches;x_l_cur y_l_cur];
            new_right_matches = [new_right_matches;x_r_cur y_r_cur];
        end
    end
end

function [best_x, best_y] = best_disparity(x_l, y_l, disparity)
    x_r = x_l + disparity;
    y_r = y_l;
    neighbors = [[-1, -1], [0, -1], [1, -1], [0,0], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
    best_SSD = 10000; % need to finetune this
    best_x = -1;
    best_y = -1;
    for i=1:size(neighbors,1)
        % NEED TO DEAL WITH IOB. IF IOB, DO NOT CALL GET_SSD
        dx = neighbors(i, 1);
        dy = neighbors(i, 2);
        x_r_cur = x_r + dx;
        y_r_cur = y_r + dy;
        SSD = get_SSD(x_l, y_l, x_r_cur, y_r_cur);
        if SSD < best_SSD
            best_SSD = SSD;
            best_x = x_r_cur;
            best_y = y_r_cur;
        end
    end
end

function [SSD] = get_SSD(x_l, y_l, x_r, y_r)
    % Assumes all coordinates are not IOB!
    left_img_path = fullfile('../images/L_rectified', "L_rectified1.JPG");
    right_img_path = fullfile('../images/R_rectified', "R_rectified1.JPG");
    left_img = rgb2gray(imread(left_img_path));
    right_img = rgb2gray(imread(right_img_path));
    left_img = padarray(left_img, [3 3], 0, "post");
    right_img = padarray(right_img, [3 3], 0, "post");
    left_patch = left_img(x_l:x_l+3, y_l:y_l+3);
    right_patch = right_img(x_r:x_r+3, y_r:y_r+3);
    diff = left_patch - right_patch;
    SSD = sum(diff(:).^2);

end

%any(ismember(visited,new,'rows'));
