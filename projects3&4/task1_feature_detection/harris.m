function [features] = harris(path, number_of_strongest_features, display_features)
    I_RGB = imread(path);
    % sift only works on grayscale, but can still use x,y coords 
    I_GRAY = rgb2gray(I_RGB);
    features = detectHarrisFeatures(I_GRAY);
    if display_features
        imshow(I_RGB);
        hold on;
        plot(features.selectStrongest(number_of_strongest_features));
    end
end