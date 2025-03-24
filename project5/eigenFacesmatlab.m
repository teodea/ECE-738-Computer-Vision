%%
N=50; % image size
M=4;% number faces

%% mic1
mic1 = imread('mic1.JPG','jpg');
mic1=rgb2gray(mic1);
mic1=imresize(mic1,[N N] );
figure(1),imshow(mic1,'Initialmagnification','fit');;title('mic1')


% shelly1
shelly1 = imread('shelly1.JPG','jpg');
shelly1=rgb2gray(shelly1);
shelly1=imresize(shelly1,[N N] );
figure(2),imshow(shelly1,'Initialmagnification','fit');;title('shelly1')


%% linoy1
linoy1 = imread('linoy1.JPG','jpg');
linoy1=rgb2gray(linoy1);
linoy1=imresize(linoy1,[N N] );
figure(3),imshow(linoy1,'Initialmagnification','fit');;title('linoy1')


%% libi1
libi1 = imread('libi4.JPG','jpg');
libi1=rgb2gray(libi1);
libi1=imresize(libi1,[N N] );
figure(4),imshow(libi1,'Initialmagnification','fit');;title('libi1')

%% extra face
extraface1 = imread('extraface.JPG','jpg');
extraface1=rgb2gray(extraface1);
extraface1=imresize(extraface1,[N N] );
figure(5),imshow(extraface1,'Initialmagnification','fit');;title('extraface1')

%% m_gr.jpg
extraface2 = imread('m_gr.JPG','jpg');
extraface2=rgb2gray(extraface2);
extraface2=imresize(extraface2,[N N] );
figure(6),imshow(extraface2,'Initialmagnification','fit');;title('extraface2')


%% store
st.names = {'mic','shelly','linoy','libi','exface1','exface2'};
st.data{1} = mic1;
st.data{2} = shelly1;
st.data{3} = linoy1;
st.data{4} = libi1;
st.data{5} = extraface1;
st.data{6} = extraface2;

z  = [mic1  shelly1  linoy1 ;     libi1  extraface1 extraface2];
figure(6),imshow(z,'Initialmagnification','fit');;title('z')



save classFile st;



clear all, close all;
load classFile;
M=6;N=50;
avImg=zeros(N);
z  = [ st.data{1}  st.data{2}    st.data{3}; st.data{4}     st.data{5}  st.data{6}];
figure(1),imshow(z,'Initialmagnification','fit');;title('z org')
%% compute mean
for k=1:M
    st.data{k} = im2single(st.data{k});
    avImg   =avImg  + (1/M)*st.data{k};
end

figure(2),imshow(avImg,'Initialmagnification','fit');title('average')

%% normalize (remove mean)
for k=1:M
    st.dataAvg{k}  = st.data{k} -avImg;
end

z  = [ st.dataAvg{1}  st.dataAvg{2}   st.dataAvg{5}  ; st.dataAvg{3}     st.dataAvg{4}  st.dataAvg{6}];
figure(3),imshow(z,'Initialmagnification','fit');;title('z average')


%% generate A = [ img1(:)  img2(:) ...  imgM(:) ];
A = zeros(N*N,M);% (N*N)*M   2500*4
for k=1:M
    A(:,k) = st.dataAvg{k}(:);
end
% covariance matrix small dimension (transposed)
C = A'*A;
figure(4),imagesc(C);title('covariance')

%% eigen vectros  in small dimension
[   Veigvec,Deigval ]  = eig(C);% v M*M e M*M only diagonal 4 eigen values
% eigan face in large dimension  A*veigvec is eigen vector of Clarge
Vlarge = A*Veigvec;% 2500*M*M*M  =2500 *M
% reshape to eigen face
eigenfaces=[];
for k=1:M
    c  = Vlarge(:,k);
    eigenfaces{k} = reshape(c,N,N);
end
x=diag(Deigval);
[xc,xci]=sort(x,'descend');% largest eigenval
z  = [ eigenfaces{xci(1)}  eigenfaces{xci(2)}   eigenfaces{xci(3)} ; eigenfaces{xci(4)}     eigenfaces{xci(5)}   eigenfaces{xci(6)}];
figure(5),imshow(z,'Initialmagnification','fit');;title('eigenfaces')

%% weights
nsel=5% select  eigen faces
for mi=1:M  % image number
  for k=1:nsel   % eigen face for coeff number
    wi(mi,k) =   sum(A(:,mi).* eigenfaces{xci(k)}(:)) ;
  end
end

%% classify new img  mic   
% folder work C:\Users\michaels.DSI\Desktop\faces\class\
testFaceMic = imread('100_1807.jpg','jpg');
testFaceMic  =rgb2gray(testFaceMic);
testFaceMic = imresize(testFaceMic,[N N]);
testFaceMic   =  im2single(testFaceMic);
%testFaceMic =  st.data{1}; test
figure(6), imshow(testFaceMic,'Initialmagnification','fit'); title('test face michael')
Aface = testFaceMic(:)-avImg(:); % normilized face
for(tt=1:nsel)
  wface(tt)  =  sum(Aface.* eigenfaces{xci(tt)}(:)) ;
end


% compute distance
for mi=1:M  
    fsumcur=0;
    for(tt=1:nsel)
        fsumcur = fsumcur + (wface(tt) -wi(mi,tt)).^2;
    end
    diffWeights(mi) =   sqrt( fsumcur);
end
% mic classified as 5 ..


%% classify new img  linoy
testFaceLinoy = imread('100_2120.jpg','jpg');
testFaceLinoy  =rgb2gray(testFaceLinoy);
testFaceLinoy = imresize(testFaceLinoy,[N N]);
testFaceLinoy   =  im2single(testFaceLinoy);
figure(7), imshow(testFaceLinoy,'Initialmagnification','fit'); title('test face linoy')
Aface = testFaceLinoy(:)-avImg(:);
for(tt=1:nsel)
  wface(tt)  =  sum(Aface.* eigenfaces{xci(tt)}(:)) ;
end


% compute distance
for mi=1:M  
    fsumcur=0;
    for(tt=1:nsel)
        fsumcur = fsumcur + (wface(tt) -wi(mi,tt)).^2;
    end
    diffWeights(mi) =   sqrt( fsumcur);
end
% linoy classified as libi


%% libi3.jpg
testFaceLibi = imread('libi3.jpg','jpg');
testFaceLibi  =rgb2gray(testFaceLibi);
testFaceLibi = imresize(testFaceLibi,[N N]);
testFaceLibi   =  im2single(testFaceLibi);
figure(8), imshow(testFaceLibi,'Initialmagnification','fit'); title('test face testFaceLibi')
Aface = testFaceLibi(:)-avImg(:);
wface=[];
for(tt=1:nsel)
  wface(tt)  =  sum(Aface.* eigenfaces{xci(tt)}(:)) ;
end


% compute distance
for mi=1:M  
    fsumcur=0;
    for(tt=1:nsel)
        fsumcur = fsumcur + (wface(tt) -wi(mi,tt)).^2;
    end
    diffWeights(mi) =   sqrt( fsumcur);
end
diffWeights  =diffWeights.';