% AKSHAY GORE
% https://www.codewrk.com/
% admin@codewrk.com; mycodeworklab.gmail.com #WSN #matlab #leach # image processing



function mitras = intrasimilarity(image1,image2) 
% This function is used to calculate the similarity map of two images (image1
% and image2, double) by comparing Intra-patch similarity.

%% Config and Check
patch_size = 9; % size of processed patch in intra-patch similarity
L =255; % dynamic range of the pixel values
multiple = 7; % multiple of JND to compare gradient orientation
% samll constant, << 1
% K1 = 0.01;
% K2 = 0.03; 
K3 = 0.05;%0.05 for TID、CISQ、LIVE
          %0.02 for IVC
K4 = 0.01; 
K5 = 0.1;%0.03 for TID、CISQ、LIVE
         % 0.1 for IVC
% gradient operator
% Scharr
Scharr_x = [1 0 -1;1 0 -1;1 0 -1]/3;
Scharr_y = Scharr_x';
%% Compare 1-order
C3 = (K3*2*L)^2;
C4 = K4*2;
image1_x = imfilter(image1, Scharr_x, 'replicate'); % 1-order derivative of image1 along with x-direction
image1_y = imfilter(image1, Scharr_y, 'replicate'); % 1-order derivative of image1 along with y-direction
image2_x = imfilter(image2, Scharr_x, 'replicate'); % 1-order derivative of image2 along with x-direction
image2_y = imfilter(image2, Scharr_y, 'replicate'); % 1-order derivative of image2 along with y-direction
image1_gradmag = sqrt(image1_x.^2 + image1_y.^2); % amplitude of image1's gradient 
image2_gradmag = sqrt(image2_x.^2 + image2_y.^2); % amplitude of image2's gradient
sgradmag = (2.*image1_gradmag.*image2_gradmag + C3)./(image1_gradmag.^2 + image2_gradmag.^2 + C3); % similarity of gradient amplitude
cosdiffang = (image1_x.*image2_x + image1_y.*image2_y + C4)./ (image1_gradmag.*image2_gradmag + C4); % cosine value of angular difference
% 只比较梯度大于JDN的像素的梯度方向
JND1 = JND_ID(image1);
JND2 = JND_ID(image2);
smallgrad = (image1_gradmag < multiple.*JND1) | (image2_gradmag < multiple.*JND2);%参考图像和测试图像只要一个小于JND就不在该像素位置比较梯度方向
cosdiff = max(abs(cosdiffang),smallgrad); % similarity of gradient orientation 区分大梯度和小梯度的下角度变化的差别
one_with_margin = sgradmag.*cosdiff;  % 1-order comparsion on gradient amplitude and orientation
one = one_with_margin((3*patch_size-1)/2+1:end-(3*patch_size-1)/2,(3*patch_size-1)/2+1:end-(3*patch_size-1)/2); % remove image margin
%% Compare 2-order
C5 = (K5*L)^2;
image1_xx = imfilter(image1_x, Scharr_x, 'replicate'); % Ixx
image1_xy = imfilter(image1_x, Scharr_y, 'replicate'); % Ixy
image1_yx = imfilter(image1_y, Scharr_x, 'replicate'); % Iyx
image1_yy = imfilter(image1_y, Scharr_y, 'replicate'); % Iyy
image1_xy = 0.5*image1_xy + 0.5*image1_yx; % Ixy
image2_xx = imfilter(image2_x, Scharr_x, 'replicate'); % Jxx
image2_xy = imfilter(image2_x, Scharr_y, 'replicate'); % Jxy
image2_yx = imfilter(image2_y, Scharr_x, 'replicate'); % Jyx
image2_yy = imfilter(image2_y, Scharr_y, 'replicate'); % Jyy
image2_xy = 0.5*image2_xy + 0.5*image2_yx; % Ixy
LSC1 = abs( (2.*image1_x.*image1_y.*image1_xy - image1_x.^2.*image1_yy - image1_y.^2.*image1_xx)./ ((image1_x.^2+image1_y.^2 ).^1.5+1e-3)); % level set curvature for image1
LSC2 = abs( (2.*image2_x.*image2_y.*image2_xy - image2_x.^2.*image2_yy - image2_y.^2.*image2_xx)./ ((image2_x.^2+image2_y.^2 ).^1.5+1e-3)); % level set curvature for image1
two_with_margin = (2.*LSC1.*LSC2 + C5)./(LSC1.*LSC1 + LSC2.*LSC2 + C5);
two = two_with_margin((3*patch_size-1)/2+1:end-(3*patch_size-1)/2,(3*patch_size-1)/2+1:end-(3*patch_size-1)/2); % remove image margin
%% integrate 0-, 1-, and 2- order similarity
region_2 = ((image1_gradmag > JND1)&(image2_gradmag > JND2))&((LSC1 < 1)|(LSC2 < 1)); %for TID and CISQ
region_2 =region_2((3*patch_size-1)/2+1:end-(3*patch_size-1)/2,(3*patch_size-1)/2+1:end-(3*patch_size-1)/2);
mitras = ~region_2.*one+region_2.*one.^0.5.*two.^0.5;



