features = load("features.mat").features;
location = features.Location;
metric = features.Metric;

% - for a given feature location and metric:
%   returns True iff there is no feature in the surrounding 3x3 area with a
%   greater metric
% - not incredibly efficient (O(n^2), n = num features), but since n is not 
%   too large, it runs quite fast anyways
function [keep_feature] = is_max_feature(location, metric, x, y, m)
    for i=1:length(location)    
        if abs(location(i,1)-x) <= 3 && abs(location(i,2)-y) <= 3
            % note this handles the duplicate case (only throws out if
            % strictly less than)
            if m < metric(i)                  
                    keep_feature = false;
                    return
            end
        end
    end
    keep_feature = true;
end

% obviously will need to store the kept features when actually using
% currently just counting number of kept features
count = 0;
for i=1:size(location, 1)
    x = location(i,1);
    y = location(i,2);
    m = metric(i);
    if is_max_feature(location, metric, x, y, m)
        count = count + 1;
    end
end
disp("Total features before non-maximum suppression:")
disp(length(location))
disp("Total features after non-maximum suppression:")
disp(count)
disp("Number of features removed:")
disp(length(location) - count)


