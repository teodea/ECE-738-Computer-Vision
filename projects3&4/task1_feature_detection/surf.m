function [features] = surf(path, number_of_strongest_features, display_features)
    I_RGB = imread(path);
    I_GRAY = rgb2gray(I_RGB);
    features = detectSURFFeatures(I_GRAY);
    if display_features
        imshow(I_RGB);
        hold on;
        plot(features.selectStrongest(number_of_strongest_features));
    end
end