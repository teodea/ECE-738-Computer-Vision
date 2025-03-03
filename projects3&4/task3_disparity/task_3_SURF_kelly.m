clc; clear; close all; % Clear workspace, command window, and close figures
%https://www.mathworks.com/help/matlab/ref/clc.html
%https://www.mathworks.com/help/matlab/ref/clear.html
%https://www.mathworks.com/help/matlab/ref/close.html

% Ensure the output folder exists for storing disparity maps
output_folder = 'disparity_maps';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
%https://www.mathworks.com/help/matlab/ref/exist.html
%https://www.mathworks.com/help/matlab/ref/mkdir.html

% Load rectified stereo image pairs
left_files = dir(fullfile('L_rectified', '*.JPG')); % Adjust file type if necessary
right_files = dir(fullfile('R_rectified', '*.JPG'));
% https://www.mathworks.com/help/matlab/ref/dir.html

% Ensure the number of left and right images match
if length(left_files) ~= length(right_files)
    error('mismatch between the number of left and right images');
end
% https://www.mathworks.com/help/matlab/ref/error.html

numPairs = length(left_files); % Number of stereo pairs
disparity_maps = cell(numPairs, 1); % Store disparity maps

% Processing each stereo pair
for i = 1:numPairs
    % Load grayscale images
    left_img = im2gray(imread(fullfile('L_rectified', left_files(i).name)));
    right_img = im2gray(imread(fullfile('R_rectified', right_files(i).name)));

    % Load matched feature points from Task 2
    matched_features_file = fullfile('matched_features', ['matchedFeatures_' num2str(i) '.mat']);
    if exist(matched_features_file, 'file')
        load(matched_features_file, 'matchedPoints_left', 'matchedPoints_right');
    else
        warning(['matched feature file not found: ', matched_features_file]);
        continue;
    end

    % Compute initial disparity values (x - x')
    disparity_values = matchedPoints_left.Location(:,1) - matchedPoints_right.Location(:,1);

    % Initialize disparity map with zeros
    disparity_map = zeros(size(left_img));

    % Populate initial disparity values at matched feature locations
    for j = 1:length(disparity_values)
        x = round(matchedPoints_left.Location(j,1));
        y = round(matchedPoints_left.Location(j,2));
        if x > 0 && y > 0 && x <= size(left_img,2) && y <= size(left_img,1)
            disparity_map(y, x) = disparity_values(j);
        end
    end

    % Disparity Growing Method: Expanding disparity information
    disparity_grown = disparity_map;
    [rows, cols] = find(disparity_map > 0); % Identify initial disparity points
    
    for k = 1:length(rows)
        x = cols(k);
        y = rows(k);
        d = disparity_map(y, x);

        % Define 3x3 neighborhood
        for dx = -1:1
            for dy = -1:1
                if dx == 0 && dy == 0
                    continue; % Skip center pixel
                end
                
                % Neighboring pixel coordinates
                nx = x + dx;
                ny = y + dy;
                
                % Ensure within bounds
                if nx > 0 && ny > 0 && nx <= size(left_img,2) && ny <= size(left_img,1)
                    % Compute SSD (sum squared difference) for similarity
                    if abs(left_img(y, x) - left_img(ny, nx)) < 20 % Threshold for similarity
                        % Assign disparity within a small variation
                        disparity_grown(ny, nx) = d + randi([-1, 1]); 
                    end
                end
            end
        end
    end

    % Store disparity map for this stereo pair
    disparity_maps{i} = disparity_grown;

    % Visualize Disparity Map
    figure;
    imagesc(disparity_grown);
    colormap jet;
    colorbar;
    title(['Disparity Map (Grown) for Image Pair ', num2str(i)]);
    saveas(gcf, fullfile(output_folder, ['DisparityMap_' num2str(i) '.png']));
end

% Save all disparity maps
save(fullfile(output_folder, 'disparity_maps.mat'), 'disparity_maps');