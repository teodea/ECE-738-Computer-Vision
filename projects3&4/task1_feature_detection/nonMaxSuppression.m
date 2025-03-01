function keptFeatures = nonMaxSuppression(features, pixel_area)
    location = features.Location;
    metric = features.Metric;
    keep = true(size(location, 1), 1); % initializing to keep all initially
    
    % - for a given feature location and metric:
    %   returns True iff there is no feature in the surrounding 3x3 area with a
    %   greater metric
    % - not incredibly efficient (O(n^2), n = num features), but since n is not 
    %   too large, it runs quite fast anyways
    function [keep_feature] = is_max_feature(location, metric, x, y, m)
        keep_feature = true;
        for i=1:size(location,1)    
            if abs(location(i,1)-x) <= pixel_area && abs(location(i,2)-y) <= pixel_area
                % note this handles the duplicate case (only throws out if
                % strictly less than)
                if m < metric(i)                  
                        keep_feature = false;
                        return
                end
            end
        end
    end
    
    for i=1:size(location, 1)
        if keep(i)  % only check if still considered to be kept
            x = location(i,1);
            y = location(i,2);
            m = metric(i);
            keep(i) = is_max_feature(location, metric, x, y, m);
        end
    end

    keptFeatures = features(keep);

    disp("Total features before non-maximum suppression:")
    disp(length(location))
    disp("Total features after non-maximum suppression:")
    disp(sum(keep))
    disp("Number of features removed:")
    disp(length(location) - sum(keep))
end


