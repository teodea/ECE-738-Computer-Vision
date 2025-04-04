% Set size of images
width = 640;
height = 480;

% Load training set
train_dir = 'DataSet/Training';
files = dir(fullfile(train_dir, '*.jpg'));
num_training_images = length(files);

% Vectorize images
X_train = zeros(width*height*3, num_training_images);

for i = 1:num_training_images
    img = imread(fullfile(train_dir, files(i).name));
    X_train(:, i) = double(img(:));
end

% Normalize to center data
mean_face = mean(X_train, 2);
X_train_centered = X_train - mean_face;

% Compute PCA
[coeff, score, latent] = pca(X_train_centered');

% Choosing K
percentange_of_variance_to_retain = 0.95;

total_variance = sum(latent);

n = length(latent);
cumulative_variance = zeros(n, 1);
cumulative_variance(1) = latent(1);
for i = 2:n
    cumulative_variance(i) = cumulative_variance(i-1) + latent(i);
end

K = 0;
for i = 1:n
    if cumulative_variance(i) / total_variance >= percentange_of_variance_to_retain
        K = i;
        break;
    end
end

% Define eigenface space
eigenfaces = coeff(:, 1:K);

% Project training set onto eigenface space
proj_train = eigenfaces' * X_train_centered;

% Load testing set
test_dir_T1 = 'DataSet/Testing/T1';
files_T1 = dir(fullfile(test_dir_T1, '*.jpg'));
num_images_T1 = length(files_T1);
num_selected_T1 = round(num_images_T1 / 2);
rand_indices_T1 = randperm(num_images_T1, num_selected_T1);
selected_files_T1 = files_T1(rand_indices_T1);

test_dir_T2 = 'DataSet/Testing/T2';
files_T2 = dir(fullfile(test_dir_T2, '*.jpg'));
num_images_T2 = length(files_T2);
num_selected_T2 = round(num_images_T2 / 2);
rand_indices_T2 = randperm(num_images_T2, num_selected_T2);
selected_files_T2 = files_T2(rand_indices_T2);

combined_selected_files = [selected_files_T1; selected_files_T2];

% Vectorize images
X_test = zeros(width*height*3, length(combined_selected_files));

for i = 1:length(combined_selected_files)
    img = imread(fullfile(combined_selected_files(i).folder, combined_selected_files(i).name));
    X_test(:, i) = double(img(:));
end

% Normalize to center data
X_test_centered = X_test - mean_face;

% Project testing set onto eigenface space
proj_test = eigenfaces' * X_test_centered;

% Calculate error
X_new = eigenfaces * proj_test + mean_face;
error = norm(X_test - X_new);

% Set threshold
threshold = 15000;

% Check if each image is a picture
for i = 1:size(X_test_centered, 2)
    x = X_test_centered(:, i);  
    a = eigenfaces' * x;      
    x_new = eigenfaces * a + mean_face; 
    error = norm((x + mean_face) - x_new); 
    
    filename = combined_selected_files(i).name;
    original_test_img = reshape(x + mean_face, height, width, 3);

    if error < threshold
        distances = vecnorm(proj_train - a, 2, 1);
        [best_match_value, best_match_index] = min(distances);

        matched_img = reshape(X_train(:, best_match_index), height, width, 3);

        figure;
        subplot(1,2,1);
        imshow(uint8(original_test_img));
        title(['Test Image: ', filename]);

        subplot(1,2,2);
        imshow(uint8(matched_img));
        title(['Predicted Match: Train #', num2str(best_match_index)]);
    else
        figure;
        imshow(uint8(original_test_img));
        title(['NOT a face: ', filename]);
    end
end

