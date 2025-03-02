image_path = '../images/ReconstructionData/L_rectified_stereoU1.jpg';
number_of_strongest_features = 500;
display_features = false;
pixel_area = 3;

% note that number_of_strongest_features is only used to display features
% when display_features= true, therefore the features are always saved
% fully
sift_features = sift(image_path, number_of_strongest_features, display_features);
surf_features = surf(image_path, number_of_strongest_features, display_features);
harris_features = harris(image_path, number_of_strongest_features, display_features);

combined_features = mergeFeatures(sift_features, surf_features, harris_features);

keptFeatures = nonMaxSuppression(combined_features, pixel_area);

imshow(imread(image_path));
hold on;
plot(combined_features.selectStrongest(number_of_strongest_features));