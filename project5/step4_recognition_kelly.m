%Loading preprocessed image data & PCA components
%https://www.mathworks.com/help/matlab/ref/load.html
load('face_data.mat');
load('eigenface_model.mat', 'meanFace', 'U');  % Load mean face and full U (all eigenfaces from SVD)


%Defining range of k (the number of top eigenfaces to use)
%Here the program tests w/ k = 5, 10, 15, ..., 30
kValues = 5:5:30;


%Pre-allocating accuracy vectors for plotting
%zeros helps w/ creating arrays of zeros
%https://www.mathworks.com/help/matlab/ref/zeros.html
accT1 = zeros(size(kValues));
accT2 = zeros(size(kValues));


%Setting recognition threshold (which is used in distance comparisons)
threshold = 3000;


%Looping over different values of k (number of eigenfaces)
%length helps w/ returning the number of elements in array
%https://www.mathworks.com/help/matlab/ref/length.html
for idx = 1:length(kValues)
    k = kValues(idx);


    %Selecting top-k eigenfaces
    %https://www.mathworks.com/help/matlab/math/matrix-indexing.html
    eigenfaces = U(:, 1:k);                     
    

    %Projecting training data into eigenface space
    %https://www.mathworks.com/help/matlab/ref/mtimes.html
    trainCoeffs = eigenfaces' * (trainData - meanFace);
    

    %Projecting test data (T1 & T2)
    testCoeffsT1 = eigenfaces' * (testDataT1 - meanFace);
    testCoeffsT2 = eigenfaces' * (testDataT2 - meanFace);


    %Evaluating accuracy on T1 (known faces)
    correctT1 = 0;
    for i = 1:size(testCoeffsT1, 2) %Looping all T1 test images
        %vecnorm helps w/ computing 2-norm (Euclidean distance) for each training face
        %https://www.mathworks.com/help/matlab/ref/vecnorm.html
        dists = vecnorm(trainCoeffs - testCoeffsT1(:, i), 2, 1);
        
        %min helps w/ obtaining smallest distance (nearest neighbor)
        %https://www.mathworks.com/help/matlab/ref/min.html
        if min(dists) < threshold
            correctT1 = correctT1 + 1;
        end
    end


    %Evaluating accuracy on T2 (unknown faces or non-faces)
    correctT2 = 0;
    for i = 1:size(testCoeffsT2, 2)
        dists = vecnorm(trainCoeffs - testCoeffsT2(:, i), 2, 1);
        if min(dists) > threshold
            correctT2 = correctT2 + 1;
        end
    end


    %Computing accuracy (%) for current value of k
    accT1(idx) = correctT1 / size(testCoeffsT1, 2) * 100;
    accT2(idx) = correctT2 / size(testCoeffsT2, 2) * 100;
end


%Plotting accuracy vs. number of eigenfaces
%https://www.mathworks.com/help/matlab/ref/figure.html
%https://www.mathworks.com/help/matlab/ref/plot.html
%https://www.mathworks.com/help/matlab/ref/xlabel.html  
%https://www.mathworks.com/help/matlab/ref/ylabel.html  
%https://www.mathworks.com/help/matlab/ref/title.html  
%https://www.mathworks.com/help/matlab/ref/legend.html  
%https://www.mathworks.com/help/matlab/ref/grid.html  
figure;
plot(kValues, accT1, '-o', 'LineWidth', 2); hold on;
plot(kValues, accT2, '-x', 'LineWidth', 2);
xlabel('Number of Eigenfaces (k)');
ylabel('Accuracy (%)');
legend('T1: Face Recognition', 'T2: Non-Face Rejection');
title('Performance vs. Number of Eigenfaces');
grid on;