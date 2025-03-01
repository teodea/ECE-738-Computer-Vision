function combinedFeatures = mergeFeatures(siftFeatures, surfFeatures, harrisFeatures)
    locations = [siftFeatures.Location; surfFeatures.Location; harrisFeatures.Location];
    metrics = [siftFeatures.Metric; surfFeatures.Metric; harrisFeatures.Metric];

    combinedFeatures = cornerPoints(locations, 'Metric', metrics);
end