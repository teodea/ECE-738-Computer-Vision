%Loading training data
%load will help w/ loading variables from a .mat file
%https://www.mathworks.com/help/matlab/ref/load.html
load('face_data.mat'); %Loads trainData, imgHeight, imgWidth


%Here, computing the mean face
%Take mean of each row (each pixel position) across all training images
%mean computes average along specified dimension
%https://www.mathworks.com/help/matlab/ref/mean.html
meanFace = mean(trainData, 2); %Average face (column vector)


%Subtracting mean face to center data
%Centering data around zero is important in PCA
%Matrix subtraction is an element-wise subtraction
%https://www.mathworks.com/help/matlab/ref/minus.html
A = trainData - meanFace;


%Performing PCA using Singular Value Decomposition (SVD)
%A = U*S*V', where U contains eigenfaces (principal directions)
%'econ' provides w/ a more efficient decomposition (faster, less memory)
%svd is the singular value decomposition
%https://www.mathworks.com/help/matlab/ref/svd.html
[U, S, ~] = svd(A, 'econ'); %U = eigenfaces, S = singular values


%Selecting top-k eigenfaces
%Taking first k eigenfaces (most variance)
%Indexing in MATLAB helps w/ selecting first k columns
%https://www.mathworks.com/help/matlab/math/matrix-indexing.html
k = 20;
eigenfaces = U(:, 1:k);


%Projecting  training data into eigenface space
%Projecting centered training data into reduced PCA space using dot product
%Matrix multiplication A'*B performs transpose & multiplication
%https://www.mathworks.com/help/matlab/ref/mtimes.html
trainCoeffs = eigenfaces' * A;


%Saving PCA model & projections
%save helps w/ saving variables to a .mat file
%https://www.mathworks.com/help/matlab/ref/save.html
save('eigenface_model.mat', ...
    'meanFace', 'eigenfaces', 'trainCoeffs', 'k', 'U', 'imgHeight', 'imgWidth');


%Visualizing top 9 eigenfaces
%Displaying eigenfaces by reshaping column vectors back to image form
%https://www.mathworks.com/help/matlab/ref/figure.html
%https://www.mathworks.com/help/matlab/ref/subplot.html
%https://www.mathworks.com/help/matlab/ref/imagesc.html
%https://www.mathworks.com/help/matlab/ref/reshape.html
%https://www.mathworks.com/help/matlab/ref/colormap.html
%https://www.mathworks.com/help/matlab/ref/axis.html
%https://www.mathworks.com/help/matlab/ref/title.html
%https://www.mathworks.com/help/matlab/ref/sgtitle.html
figure;
for i = 1:9
    subplot(3,3,i);
    imagesc(reshape(eigenfaces(:,i), imgHeight, imgWidth));
    colormap gray; axis off;
    title(['Eigenface ', num2str(i)]);
end
sgtitle('Top 9 eigenfaces');