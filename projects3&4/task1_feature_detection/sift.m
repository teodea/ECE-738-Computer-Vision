path = '../images/ReconstructionData/L_rectified_stereoU1.jpg';
I_RGB = imread(path);
% sift only works on grayscale, but can still use x,y coords 
I_GRAY = rgb2gray(I_RGB);
features = detectSIFTFeatures(I_GRAY);
imshow(I_RGB);
hold on;
plot(features.selectStrongest(100))
