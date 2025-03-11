function features = retrievingFeatures(image_path)

    addpath("../task1_feature_detection");

    number_of_strongest_features = 500;
    display_features = false;
    pixel_area = 3;

    sift_features = sift(image_path, number_of_strongest_features, display_features);
    surf_features = surf(image_path, number_of_strongest_features, display_features);
    harris_features = harris(image_path, number_of_strongest_features, display_features);
    
    combined_features = mergeFeatures(sift_features, surf_features, harris_features);

    features = nonMaxSuppression(combined_features, pixel_area);
end
