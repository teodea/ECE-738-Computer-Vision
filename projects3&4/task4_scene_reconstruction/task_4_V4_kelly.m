clc; clear; close all; 
%clears command window, removes variable from Workspace, & closes all figure windows
%https://www.mathworks.com/help/matlab/ref/clc.html


zip_folder = 'C:\Users\knr20\Downloads\Project 3 & 4\';
left_zip = fullfile(zip_folder, 'L_rectified.zip');
right_zip = fullfile(zip_folder, 'R_rectified.zip');
extract_folder = fullfile(zip_folder, 'Extracted_Images');
%This section helps w/ defining the folder where zipped image files are located.
%It also builds file paths for left & right stereo image zip files using fullfile,
%& creates the extraction folder path
%https://www.mathworks.com/help/matlab/ref/fullfile.html


if ~exist(extract_folder, 'dir')
    mkdir(extract_folder);
end
%This section checks whether the extraction directory exists already using "exist" function
%w/ "dir"
%Otherwise, it would create the directory using "mkdir"
%https://www.mathworks.com/help/matlab/ref/exist.html


unzip(left_zip, extract_folder);
unzip(right_zip, extract_folder);
%This section helps w/ unzipping left & right image files
%https://www.mathworks.com/help/matlab/ref/unzip.html


left_files = dir(fullfile(extract_folder, 'L_rectified*.*'));
right_files = dir(fullfile(extract_folder, 'R_rectified*.*'));
%Here the list of files with matching pattern is obtained ('L_rectified*.*'
%& 'R_rectified*.*') in the extraction folder using dir()
%https://www.mathworks.com/help/matlab/ref/dir.html


if isempty(left_files) || isempty(right_files)
    error('No images found');
end
%This section checks whether left/right image file lists are empty
%If there are no images, then the script shows an error
%https://www.mathworks.com/help/matlab/ref/error.html


left_img = imread(fullfile(left_files(1).folder, left_files(1).name));
right_img = imread(fullfile(right_files(1).folder, right_files(1).name));
%This section reads the first left/right images from extracted files
%https://www.mathworks.com/help/matlab/ref/imread.html


if size(left_img, 3) == 3
    left_img_gray = rgb2gray(left_img);
    right_img_gray = rgb2gray(right_img);
else
    left_img_gray = left_img;
    right_img_gray = right_img;
end
%Here RGB images are changed to grayscale using rgb2gray
%https://www.mathworks.com/help/matlab/ref/rgb2gray.html


disparityRange = [16 128];
disparityMap = disparitySGM(left_img_gray, right_img_gray, ...
                            'DisparityRange', disparityRange);
%This section computes stereo (fixed) disparity map using Semi-Global
%Matching (SGM) method; SGM finds correspondences b/w left & right images
%by minimizing an energy function. It tends to be accurate because it can
%help w/ occlusions, noise, & regions w/o texture
%disparity range is set from 16 to 128 pixels; disparity range defines the
%min/max values for disparity search
%https://www.mathworks.com/help/vision/ref/disparitysgm.html


%Visualization of the disparity map
figure;
imshow(disparityMap, []); %displays disparity map
colormap jet; %this line uses a heatmap-like color scale to help display the depth differences
colorbar; %shows a reference scale for the disparities
title('Fixed disparity map');
%https://www.mathworks.com/help/matlab/ref/imshow.html


disparityMap(disparityMap <= 5) = NaN;
%This line of code replaces disparity values ≤5 w/ NaN to prevent unrealistic depth calculations
%if disparity approaches 0, then depth would go to infinity (not realistic
%physically)
%the depth estimates are unstable or too large when they are below 5 pixels


% Converting disparity to depth (fixed scaling)
f = 1277;  % Focal length (in pixels)
B = 259.3; % Baseline distance between cameras (in mm)
depthMap = (f * B) ./ disparityMap;
% Computes the depth map using the formula Z = (f * B) / disparity.
% Here, f is the focal length, B is the baseline, and disparityMap contains disparity values.
%https://www.mathworks.com/help/vision/ug/reconstructing-a-3-d-scene-from-a-stereo-camera.html


depthMap(depthMap > 5000) = NaN; %
%This line removes unrealistic depth values above 5000 mm (5 meters) by converting them to NaN


figure;
imshow(depthMap, [0 5000]);
colormap jet;
colorbar;
title('Fixed depth map (Z in mm)');
%this section shows the depth map w/ a colorbar & a jet colormap
%depth range is set from 0 to 5000 mm
%https://www.mathworks.com/help/matlab/ref/colormap.html


[height, width] = size(disparityMap);
[X, Y] = meshgrid(1:width, 1:height);
%obtaining the image size using size(), & creating a coordinate frid using
%meshgrid() (needed for 3-D point cloud building from the disparity map)
%https://www.mathworks.com/help/matlab/ref/size.html
%https://www.mathworks.com/help/matlab/ref/meshgrid.html


P = [X(:), Y(:), depthMap(:)];
%this section reshapes & concatenates X, Y & depthmap matrices to help w/
%creating a 3D point cloud
%P contains X,Y,Z coordinates for each od the valid pixels in the image
%https://www.mathworks.com/help/matlab/ref/colon.html
%https://www.mathworks.com/help/matlab/ref/horzcat.html


validIdx = ~isnan(P(:,3)) & (P(:,3) > 0) & (P(:,3) < 5000);
%P(:,3) is referring to the Z (depth values) in the 3-D point cloud
P = P(validIdx, :); %only keeps the valid points in P, based on "validIdx"
%this section filters out NaN points or those w/ unrealistic depth values


figure;
scatter3(P(:,1), P(:,2), P(:,3), 3, P(:,3), 'filled');
colormap jet;
colorbar;
title('Fixed 3D point cloud');
xlabel('X (pixels)'); ylabel('Y (pixels)'); zlabel('Z (depth in mm)');
axis equal;
xlim([0, width]); ylim([0, height]); zlim([0, 5000]);
grid on;
%plots 3-D point cloud using scatter3. It colors points based on depth
%https://www.mathworks.com/help/matlab/ref/scatter3.html


macosx_folder = fullfile(extract_folder, '__MACOSX');
if exist(macosx_folder, 'dir')
    rmdir(macosx_folder, 's');
end
%Deletes '__MACOSX' folder if it exists. Otherwise, I personally get an
%error on my computer
%https://www.mathworks.com/help/matlab/ref/rmdir.html


file_list = dir(fullfile(extract_folder, '*.*'));
for i = 1:length(file_list)
    if ~file_list(i).isdir
        delete(fullfile(file_list(i).folder, file_list(i).name));
    end
end
%this section focuses on removing the extracted image files from
%extract_folder after the processing. As a result, it helps to prevent
%duplicate processing (assuming the script is run multiple times)


if isempty(dir(fullfile(extract_folder, '*')))
    rmdir(extract_folder, 's');
end
%this section removes "extract_folder" if it does not have files after
%processing the script. As a result, there is removal of unnecessary empty
%folders


imwrite(uint8(rescale(depthMap, 0, 255)), 'fixed_depth_map.png');
%this section helps to save depthMap as 8 bit grayscale image. It makes
%sure that the pixel values are scaled b/w 0 & 255 (which is what is used
%for 8 bit imges)
%As a result, the output image keeps depth info visually while also being
%compatible w/ the standard image formats
%https://www.mathworks.com/help/matlab/ref/imwrite.html
%https://www.mathworks.com/help/matlab/ref/rescale.html
%https://www.mathworks.com/help/matlab/ref/uint8.html


save('fixed_point_cloud.mat', 'P');
%saves 3-D point cloud as .mat file which could be used in another
%project/task
%saves variable P into the "fixed_point_cloud.mat"
% P = [X(:), Y(:), depthMap(:)]
%https://www.mathworks.com/help/matlab/ref/save.html