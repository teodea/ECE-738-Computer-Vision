%Visualizing failure cases from T1


%Loading previously saved variables from .mat files
%https://www.mathworks.com/help/matlab/ref/load.html
load('face_data.mat');
load('eigenface_model.mat', 'meanFace', 'eigenfaces', 'trainCoeffs', 'k', 'imgHeight', 'imgWidth');


%Re-computing projections of test data into eigenface space
%Matrix subtraction + multiplication helps w/ projecting test faces to PCA space
%https://www.mathworks.com/help/matlab/matlab_prog/matrix-operations.html
testCoeffsT1 = eigenfaces' * (testDataT1 - meanFace);


%Setting distance threshold used to decide if a face is recognized
threshold = 3000;
failCount = 0; %Monitoring how many failures are visualized


%Creating a new figure window to show failed cases
%https://www.mathworks.com/help/matlab/ref/figure.html
figure;


%Looping over all test images in T1
for i = 1:size(testCoeffsT1, 2)
    

    %vecnorm helps w/ computing Euclidean (L2) distance b/w each test face & all training faces
    %https://www.mathworks.com/help/matlab/ref/vecnorm.html
    dists = vecnorm(trainCoeffs - testCoeffsT1(:, i), 2, 1);
    

    %Finding minimum distance (or best match)
    %https://www.mathworks.com/help/matlab/ref/min.html
    minDist = min(dists);


    %If best match is above threshold, test face was rejected incorectly
    if minDist > threshold
        failCount = failCount + 1;


        %https://www.mathworks.com/help/matlab/ref/subplot.html
        subplot(2, 5, failCount);


        %reshape helps w/ converting 1D column vector back into 2D image for display
        %imshow helps to show the grayscale image
        %https://www.mathworks.com/help/matlab/ref/reshape.html
        %https://www.mathworks.com/help/matlab/ref/imshow.html
        imshow(reshape(testDataT1(:, i), imgHeight, imgWidth), []);


        %https://www.mathworks.com/help/matlab/ref/title.html
        %https://www.mathworks.com/help/matlab/ref/sprintf.html
        title(sprintf('Failed Match #%d\nDist=%.0f', failCount, minDist));

        %Stopping after displaying 10 failure cases
        if failCount == 10
            break;
        end
    end
end


%https://www.mathworks.com/help/matlab/ref/sgtitle.html
sgtitle('T1 Failure Cases (Misclassified as Non-Face)');
