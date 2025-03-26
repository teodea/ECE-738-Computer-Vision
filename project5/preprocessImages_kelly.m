function dataMatrix = preprocessImages(imds, imgHeight, imgWidth)
%preprocessImages helps w/ converting a set of images into a matrix form
%Each column of the output matrix represents a flattened grayscale image


    %numel returns number of elements in the image datastore's file list
    %https://www.mathworks.com/help/matlab/ref/numel.html
    numImages = numel(imds.Files);  


    %Preallocate the output matrix [imgHeight*imgWidth x numImages]
    %Each column holds a flattened version of one image
    %zeros helps w/ creating an array of all zeros
    %https://www.mathworks.com/help/matlab/ref/zeros.html
    dataMatrix = zeros(imgHeight * imgWidth, numImages);  


    for i = 1:numImages
        %Read the ith image from the imageDatastore
        %readimage reads a specific image from a datastore
        %https://www.mathworks.com/help/matlab/ref/readimage.html
        img = readimage(imds, i);                       
    

        %This section resizes image to [imgHeight, imgWidth] to standardize size
        %imresize helps w/ resizing image to specified dimensions
        %https://www.mathworks.com/help/images/ref/imresize.html
        img = imresize(img, [imgHeight, imgWidth]);    


        %HEre, the program converts to grayscale if the image is RGB
        %rgb2gray converts RGB image to grayscale
        %https://www.mathworks.com/help/images/ref/rgb2gray.html
        if size(img, 3) == 3
            img = rgb2gray(img); %Converts color images to grayscale
        end
        

        %This section, flattens image to a column vector & stores in dataMatrix
        %img(:) reshapes the 2D image into a column vector (column-major order)
        %double(img(:)) converts pixel values to double precision
        %Colon operator is used for reshaping
        %https://www.mathworks.com/help/matlab/ref/colon.html
        %double helps w/ converting to double precision
        %https://www.mathworks.com/help/matlab/ref/double.html
        dataMatrix(:, i) = double(img(:));  
    end
end