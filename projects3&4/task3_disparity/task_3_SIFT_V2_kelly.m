clc; clear; close all; % Clear workspace, command window, and close figures
%https://www.mathworks.com/help/matlab/ref/clc.html
%https://www.mathworks.com/help/matlab/ref/clear.html 
%https://www.mathworks.com/help/matlab/ref/close.html 


%this section helps w/ checking whether the output folder has been created or whether it needs to be created to store the disparity maps
output_folder = 'disparity_maps'; %Here the output folder is named as "disparity_maps"
if ~exist(output_folder, 'dir') %this line checks whether the folder exists
    mkdir(output_folder); %here the code creates a folder if it does not exist already (named "disparity_maps)
end
%https://www.mathworks.com/help/matlab/ref/exist.html
%https://www.mathworks.com/help/matlab/ref/mkdir.html


%on task 2, there was a section of the code that focused on creating a .mat
%file for matched feature files; the variable shown below,
%"matched_features_path", helps w/ loading the matched feature points
%extracted in task 2 (SIFT.) The matched feature points help w/
%calculating the initial disparity values. These values are then used as
%the input for the disparity growing algorithm
matched_features_path = 'C:\Users\knr20\Downloads\Project 3 & 4\matched_features';


%this section loads the rectified stereo image pairs
left_files = dir(fullfile('L_rectified', '*.JPG')); %Obtains list of left images
right_files = dir(fullfile('R_rectified', '*.JPG')); %Obtains list of right images
%dir() obtains all .JPG images in the left & right rectified image folders
%fullfile() makes sure of using the correct file path format regardless of
%the operating system
%https://www.mathworks.com/help/matlab/ref/dir.html 
%https://www.mathworks.com/help/matlab/ref/fullfile.html


%Similarly to task 1 and 2, this section checks whether the number of left
%image files matches the number of right image files
if length(left_files) ~= length(right_files)
    error('mismatch b/w number of left & right images'); %If there is an error, this line will appear on the command window & stops the program so it can be fixed
end
%https://www.mathworks.com/help/matlab/ref/error.html 


numPairs = length(left_files);
%In this section, numpairs helps w/ storing the total number of stereo
%image pairs by assessing the number of left images available
%left_files is a structure array which has metadata about the .JPG images
%in the "L_rectified" folder
%length(left_files) assesses the total number of images in the array (counts
%the number of left images)
%This value hwlps w/ assessing the number of stereo pairs that would be
%processed because stereo vision relies on the paired left & right images
%This is imporant in task 3 because to compute the disparity maps, the
%script would need to process all the stereo pairs
%numPais is in a foor loop to iterate trhough each of the stereo pairs. If
%there is an image missing, then the loop disfunction can cause issues in
%the disparity computation


disparity_maps = cell(numPairs, 1);
%This section helps w/ pre-allocating a cell array which stores disparity
%maps for each stereo pair. In other words, this creates an empty list for
%the disparity maps
%cell(numPairs, 1) creates an empty cell array w/ numPairs rows & 1 column;
%each cell stores a disparity map which is computed for each corresponding
%stereo image pair
%the reason why a cell array is used is because disparity maps can have
%different dimensions (different sizes) depending on image sizes. The cell
%array allows to store maps of varying sizes
%Each stereo pair produces a unique disparity map. As a result, these need
%to be stored
%Also, the final disparity maps are saved as .mat files for future use, if
%needed


for i = 1:numPairs
%On this section, the for loop iterates over each stereo image pair
%numPairs mentioned previously in the code, contains the total number of
%stereo pairs. As a result, the loop starts at i = 1 & increases until i =
%numPairs to help w/ processing all the available images. The loop
%processes one pair of left & right images on each iteration
%This helps to make sure that all the stereo images are processed one by
%one, and the disparity map generation is automated when looping through
%each stereo pair. Finally, if numPairs is incorrect, it would fail on this
%section (mismatched images)


    left_img = im2gray(imread(fullfile('L_rectified', left_files(i).name))); %Helps w/ loading the left image
    right_img = im2gray(imread(fullfile('R_rectified', right_files(i).name))); %Helps w/ loading the right image
    %fullfile('L_rectified', left_files(i).name) helps w/ building the file
    %path to the i-th left image; similar case for right image
    %imread loads the image into matlab as a matrix
    %The output would be a color/graycale image stored in the variable left_img
    %In this case, the image was change to grayscale using
    %im2gray(left_img) because feature detection & disparity estimation
    %work best on intensity values; similar case for the right image
    %section. The reason why I picked grayscale is b/c most feature
    %detection algorithms work better w/ intensity values than w/ RGB color
    %https://www.mathworks.com/help/matlab/ref/imread.html
    %https://www.mathworks.com/help/matlab/ref/im2gray.html 



    matched_features_file = fullfile(matched_features_path, ['matchedFeatures_' num2str(i) '.mat']);
    %this section helps w/ loading the matched feature points from task 2
    %(saved as .mat files) because the matched feature points are important
    %when computing disparity values (these help to create the
    %disparity maps)
    %matched_features_path contains the folder where the task 2 files .mat files are
    %located
    %['matchedFeatures_' num2str(i) '.mat'] helps w/ creating the filename
    %for i-th stereo pair (for example: matchedFeatures_1.mat)
    %num2str(i) helps w/ turing the index i (which is an integer) into a
    %string
    %fullfile() helps w/ creating the correct file path regardless of the
    %operating system used


    if exist(matched_features_file, 'file')
        %exist(matched_features_file, 'file') helps w/ checking whether the
        %.mat file exists, returning a 1 or a 0 (for exits or doesn't
        %exist), & avoids the script from trying to load any data that does
        %not exist


        load(matched_features_file, 'matchedPoints_left', 'matchedPoints_right'); %Helps w/ loading matched feature points
        %This section only loads the variables matchedPoints_left and
        %matchedPoints_right from the .mat file. These variables contain
        %SIFT feature matches that were obtained in task 2 (left &
        %right image, respectively)
        %this part is important because matched points are used
        %to compute the disparity section


    else
        warning(['Matched feature file not found: ', matched_features_file]); %Display warning if .mat file is missing
        continue; %skips current iteration if the file is missing, allowing me to continue processing other stereo pairs w/o stopping the script
    end
    %https://www.mathworks.com/help/matlab/ref/load.html
    %https://www.mathworks.com/help/matlab/ref/warning.html


    disparity_values = matchedPoints_left.Location(:,1) - matchedPoints_right.Location(:,1);
    %This section computes initial disparity values (d = x - x') for each
    %matched feature point
    %Disparity is the difference in x-coordinates of corresponding feature points
    %https://www.mathworks.com/help/vision/ref/matchfeatures.html
    %https://www.mathworks.com/help/vision/ug/stereo-vision.html


    disparity_map = nan(size(left_img)); 
    %This section helpw w/ creating an empty disparity map, which is the
    %same size as the left image
    %This section starts all values as NaN, or unknown disparity
    %the reason why disparity map is initialized w/ NaN values to
    %distinguish known & unknown disparity values
    %size(left_img) returns the dimentions (rows/columns) of the left image
    %nan() builds a matrix of the same size. However, it fills it w/ NaN
    %values b/c NaN is a placeholder for unknown disparity values
    %If we use a 0 instead, it would assume a disparity of 0 for unkown
    %regions (which would be incorrect). As a result, NaN makes it simpler
    %to see which pixels have a disparity value and which don't
    %https://www.mathworks.com/help/matlab/ref/nan.html


    for j = 1:length(disparity_values) %this line loops through matched feature points
        %disparity_values has the computed disparity values (d = x - x')
        %for each of the matched features
        x = round(matchedPoints_left.Location(j,1)); %Obtains x-coordinate from the matched points in the left image
        y = round(matchedPoints_left.Location(j,2)); %Obtains y-coordinate from the matched points in the right image
        %the reason why round() is used here is feature points are
        %generally detected w/ subpixel accuracy. Knowing that pixels are
        %discrete, round() would ensure integer pixel indices for storing
        %the disparity value
        if x > 0 && y > 0 && x <= size(left_img,2) && y <= size(left_img,1) %helps w/ ensuring (x,y) is a valid pixel location within the image bounds
        %w/o checking, the script may attempt to access an invalid pixel
        %location, which then causes an error
            disparity_map(y, x) = disparity_values(j); %Helps w/ assigning a disparity value
            %in other words, this line helps w/ storing the disparity value
            %at the correct pixel location in "disparity_map"
            %the map starts as NaN & only the pixels w/ matched features
            %will have disparity values
        end
    end
    %This section places the disparity values at their specific pixel
    %locations in the disparity map
    %this is importan b/c otherwise the disparity map remains empty (NaN)
    %also, not using round() could cause misaligned data and/or errors
    %finally, not checking the bouds could sotre values in pixels that do
    %not exist, which would also cause errors




    disparity_grown = disparity_map; %starts w/ initial disparity map
    for iter = 1:3  %number of growing iterations (or propagation steps)
        [rows, cols] = find(~isnan(disparity_grown)); %finds pixels w/ a known disparity value (not NaN). This gives row y & column x indices of konwn disparity pixels
    %this section starts w/ the initial disparity map, and does 3
    %iterations to help w/ propagating disparity values to unknown areas
    %(Nan) in the disparity map, helping to spread disparity values
    %gradually to the unknown areas
    %If this section is not completed, then the disparity map would
    %probably have values at the feature match locations, keeping the rest
    %of the image blank (NaN)
    %depth formation as a result, would not be complete and this could make
    %the reconstruction difficult eventually
    %https://www.mathworks.com/help/matlab/ref/find.html


        for k = 1:length(rows)
            x = cols(k); %column index (x)
            y = rows(k); %row index (y)
            d = disparity_grown(y, x); %disparity value
             %this section helps w/ iterating through the known disparity pixels
             %this area of the script helpw w/ propagating the known
             %disparity values, & also makes sure that disparity grows
             %outward (from known into unknown areas)


            %this section helps w/ exploring a 3x3 neighborhood around each
            %of the known disparity points
            for dx = -1:1 %dx = -1,0,1 (moves left, stays put, or moves right)
                for dy = -1:1 %dy = -1,0,1 (moves up, stays put, or moves down)
            %which means the script checks the 8 neighboring pixels aroung
            %the center pixel (x,y)
                    if dx == 0 && dy == 0
                        continue; %skips the center pixel because this is a known disparity point. In this case, the script is exploring the neighboring pixels
                    end
            %without this section, the specific feature matched points
            %would be the ones w/ disparity values only. As a result, there
            %wouldn't be any propagation
            %also, large NaN sections would remain in the disparity map.
            %The disparity values wouldn't spread to other areas, creating
            %an incomplete map
            %https://www.mathworks.com/help/images/ref/imfilter.html
            

                    %this section helps w/ giving disparity values to the
                    %neighboring pixels if they are NaN. It would make sure
                    %that the disparity info is also shared throughout the
                    %disparity map, which would then fill the NaN values
                    nx = x + dx; %neighbor x coordinate
                    ny = y + dy; %neighbor y coordinate
                    if nx > 0 && ny > 0 && nx <= size(left_img,2) && ny <= size(left_img,1) && isnan(disparity_grown(ny, nx)) %checking bounds & propagating disparity
                        disparity_grown(ny, nx) = d; %Assigning disparity value to neighbor
                    end
                end
            end
        end
    end


    %Here the disparity map is stored for the stereo pair (computed
    %disparity maps info could be used later)
    disparity_maps{i} = disparity_grown;


    %Visualization section
    figure;
    imagesc(disparity_grown); %display disparity map
    colormap jet; %jet colormap helps w/ improving visibility
    colorbar; %adding a color scale to help represent disparity values
    %https://www.mathworks.com/help/matlab/ref/imagesc.html
    %https://www.mathworks.com/help/matlab/ref/colormap.html
    %https://www.mathworks.com/help/matlab/ref/colorbar.html

    
    xlabel('Image width (pixels)');
    ylabel('Image height (pixels)');
    title(['Disparity map (grown) for image pair ', num2str(i)]);
    %https://www.mathworks.com/help/matlab/ref/xlabel.html
    %https://www.mathworks.com/help/matlab/ref/ylabel.html
    %https://www.mathworks.com/help/matlab/ref/title.html


    c = colorbar;
    c.Label.String = 'Disparity (pixels)'; %label for the disparity values
    %https://www.mathworks.com/help/matlab/ref/colorbar.html


    %Saving the figure
    saveas(gcf, fullfile(output_folder, ['DisparityMap_' num2str(i) '.png']));
    %https://www.mathworks.com/help/matlab/ref/saveas.html
end


%Saving the disparity maps
save(fullfile(output_folder, 'disparity_maps.mat'), 'disparity_maps');
%https://www.mathworks.com/help/matlab/ref/save.html


%%Additional notes
%A disparity map represents the difference in pixel positions b/w
%corresponding points in the left & right stereo images
%The disparity value tells how much an object moves b/w left & right
%image
%closer objects - higher disparity means they shift more
%farther objects - lower disparity means they shift less
%same depth - same disparity
%disparity formula: d = x - x'
%x = x coordinate of a feature in the left image
%x' = x coordinate of the same feature in the right image
%d = disparity (or difference in the x-coordinates)
%obtaining the disparity maps helps to estimate depth in a 3D scene