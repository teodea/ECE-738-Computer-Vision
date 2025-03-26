%Loading preprocessed test data & PCA model
%Loading variables from .mat files
%https://www.mathworks.com/help/matlab/ref/load.html
load('face_data.mat'); %Contains testDataT1, testDataT2
load('eigenface_model.mat'); %Contains meanFace, eigenfaces, trainCoeffs, k


%Defining the inline function to project test data into eigenface space
%https://www.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
projectTest = @(data) eigenfaces' * (data - meanFace);


%Project test datasets (T1 & T2) into PCA space
%Matrix subtraction + multiplication: Shifting & projecting test data
%https://www.mathworks.com/help/matlab/matlab_prog/matrix-operations.html
testCoeffsT1 = projectTest(testDataT1);
testCoeffsT2 = projectTest(testDataT2);


%Threshold for nearest-neighbor recognition
%Distances below this threshold are considered known faces
threshold = 3000; %This is an empirical value and can be changed to the one that provides the best performance


%Evaluating accuracy on T1
correctT1 = 0;
for i = 1:size(testCoeffsT1, 2)
    
    %vecnorm computes Euclidean distance (2-norm) b/w vectors
    %https://www.mathworks.com/help/matlab/ref/vecnorm.html
    dists = vecnorm(trainCoeffs - testCoeffsT1(:, i), 2, 1);
    
    %min helps w/ finding minimum distance & index of best match
    %https://www.mathworks.com/help/matlab/ref/min.html
    [minDist, idx] = min(dists);
    
    %If the distance is below threshold, it would be counted as recognized
    %correctly
    if minDist < threshold
        correctT1 = correctT1 + 1;
    end
end


%Evaluating accuracy on T2
correctT2 = 0;
for i = 1:size(testCoeffsT2, 2)
    
    %Computing distances to all training projections
    dists = vecnorm(trainCoeffs - testCoeffsT2(:, i), 2, 1);
    
    %Minimum distance to training set
    minDist = min(dists);
    
    %If the distance is above threshold, it'd be rejected as unknown
    if minDist > threshold
        correctT2 = correctT2 + 1;
    end
end


%Reporting classification accuracy for both test sets
%fprintf: Print formatted text to Command Window
%https://www.mathworks.com/help/matlab/ref/fprintf.html
fprintf('T1 Accuracy (Face Recognition): %.2f%%\n', 100 * correctT1 / size(testCoeffsT1, 2));
fprintf('T2 Accuracy (Non-Face Rejection): %.2f%%\n', 100 * correctT2 / size(testCoeffsT2, 2));