%This script loads training and testing images, converts them
%into standardized grayscale vector form, and saves them for PCA processing

%This is the initial preprocessing step for project 5. The purpose
%is to load, standardize, and vectorize the training and testing face
%images before applying PCA to help w/ recognizing and classifying faces



%This section below sets paths to training and testing folders
%We were provided 2 testing categories named T1 and T2; T1 contained faces
%from training, and T2 has unknown faces and/or non-faces. These 2 folders
%help w/ detecting whether the test image is a face, and also helps to
%recognize who the face belongs to (assuming that it comes from the
%training folder)
trainingFolder = 'C:\Users\knr20\Downloads\Computer Vision Project 5\DataSets\DataSet\Training';
testingFolders = { ...
    'C:\Users\knr20\Downloads\Computer Vision Project 5\DataSets\DataSet\Testing\T1', ...
    'C:\Users\knr20\Downloads\Computer Vision Project 5\DataSets\DataSet\Testing\T2'};


%In this project, all  images are resized to the same shape for
%vectorization purposes. These dimensions are based on the orinial
%eigenfaces dataset developed at AT&T lab in Cambridge. The dataset has 400
%grayscale face images and the image size is 112 rows x 92 columns
imgHeight = 112;    % Height in pixels
imgWidth = 92;      % Width in pixels


% Here the program loads images in the training folder, and handles various
%image formats. Useful for large datasets
%imageDatastore automatically handles large sets of images & allows easy reading
trainingImages = imageDatastore(trainingFolder, ...
    'FileExtensions', {'.jpg', '.jpeg', '.png', '.bmp'}, ... % Allow common formats
    'IncludeSubfolders', false);                              % Do not recurse into subfolders
%https://www.mathworks.com/help/matlab/ref/imagedatastore.html
%https://www.mathworks.com/help/matlab/ref/imageDatastore.read.html


%Converting training images to grayscale, resizing, and flattening into column vectors
%Custom helper function preprocessImages is used
%https://www.mathworks.com/help/images/ref/imresize.html
%https://www.mathworks.com/help/images/ref/rgb2gray.html
%https://www.mathworks.com/help/matlab/ref/reshape.html
%https://www.mathworks.com/help/matlab/ref/matlab.io.datastore.read.html
trainData = preprocessImages_kelly(trainingImages, imgHeight, imgWidth);



% Each test folder is processed separately, which assumes T1 & T2 represent different categories

% T1 test set
% imageDatastore: https://www.mathworks.com/help/matlab/ref/imagedatastore.html
% preprocessImages uses rgb2gray, imresize, reshape
testDataT1 = preprocessImages_kelly(imageDatastore(testingFolders{1}, ...
    'FileExtensions', {'.jpg', '.jpeg'}), imgHeight, imgWidth);


% T2 test set
testDataT2 = preprocessImages_kelly(imageDatastore(testingFolders{2}, ...
    'FileExtensions', {'.jpg', '.jpeg'}), imgHeight, imgWidth);


%Save preprocessed data to disk for future steps (PCA, recognition)
%https://www.mathworks.com/help/matlab/ref/save.html
save('face_data.mat', 'trainData', 'testDataT1', 'testDataT2', 'imgHeight', 'imgWidth');