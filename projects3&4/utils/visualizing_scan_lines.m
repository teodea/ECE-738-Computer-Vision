% path to picture
L=imread('C:\Users\TeoDea\OneDrive\Desktop\UM\Master\ECE 738 - Computer Vision\ECE-738-Computer-Vision\projects3&4\images\ReconstructionData\L_rectified_stereoU1.jpg');
R=imread('C:\Users\TeoDea\OneDrive\Desktop\UM\Master\ECE 738 - Computer Vision\ECE-738-Computer-Vision\projects3&4\images\ReconstructionData\R_rectified_stereoU1.jpg');
imagesc([L R]);
[Nr,Nc,Nch]=size(L);
[x,y]=ginput(2);