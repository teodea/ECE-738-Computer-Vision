

% WARNING: We need to be careful. Many methods use columns per image instead of 
% rows for each image in the matrix A. This only affects the methods of calculation
% and when to use transpose vs not. Results are the same, we just need to be consistent

% STEPS:

% obtain training data

% convert to matrix A

% find average face vector (average over rows of A)

% normalize matrix A (subtract mean from each row) := A_norm

% compute covariance matrix C = A_norm^T*A_norm 
% commonly used instead is the smaller dimension, so C_small = A_norm*A_norm^T

% Get eigenvectors of C_small := V_small

% Use C_small eigenvectors to get eigenvectors of C (V = A_norm*V_small)
    % each is an eigenface

% select K best eigenfaces (largest), normalize each

% Project each training image to eigenspace
    % each image ~= w_1 * eig_1 + w_2 * eig_2 + ... + w_k * eig_k
    % we want to find w_1, w_2, ..., w_k for each image
    % for image i, to get the j-th weight, do:
        % w_ij = (v_j^T*A_norm[i])
            % note A_norm[i] is the i-th row of A
    % now, each face essentially is represented by a weight vector
%%%%%%%%%
% Classification:

% Project new image vector 't' into eigenface space (i.e. get each weight):
    % same as above
    % subtract the average face vector (from training data)
    % get the j-th weight (do for all j=1,2,..k):
        % w_j = (v_j^T*t)
    % For each face in the training set (specifically, the weight vector of each face):
        % compute euclidean distance
        % if minimum, update prediction
        % Here, can also have a threshold so that image without face is not misclassified
        

