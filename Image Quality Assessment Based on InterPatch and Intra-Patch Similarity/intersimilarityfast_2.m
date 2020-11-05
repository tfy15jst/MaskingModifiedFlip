% AKSHAY GORE
% https://www.codewrk.com/
% admin@codewrk.com; mycodeworklab.gmail.com #WSN #matlab #leach # image processing



function miters = intersimilarityfast_2(image1,image2) 
% Try to fast implementation of inter
%% config
margin = 9; %  marginal cardinal number to be remove
patch_size = 9; % patch size
neigboer_radius = 3;  % radius of neigboer
fwindows = ones(patch_size,patch_size)/(patch_size*patch_size);
% P = 0.03;
K = 1e-4;
L = 255;
H = (0.1*L)^2;
[M1 N1] = size(image1); % size of compared imagesen
offset = (3*margin-1)/2; % offset to the original 
M = M1 - (3*margin-1); % size of compared regions
N = N1 - (3*margin-1); % 
if (patch_size > margin) || (neigboer_radius > margin)
    error('patch_size or neigboer_radius should not be larger than margin!!!!');
end
numelnp = 8*neigboer_radius; % numel of neighbourhood patches

imagemean1 = filter2(fwindows, image1, 'same');
imagemean2 = filter2(fwindows, image2, 'same');
lmu1_sq = imagemean1.*imagemean1; %  mean(X)^2 
lmu2_sq = imagemean2.*imagemean2; %  mean(Y)^2 

lsigma1_sq = filter2(fwindows, image1.*image1, 'same')- lmu1_sq; % var(X) = mean(X^2) - mean(X)^2;
lsigma2_sq = filter2(fwindows, image2.*image2, 'same')- lmu2_sq; % var(Y) = mean(Y^2) - mean(Y)^2;

sindex = [-1*neigboer_radius*ones(2*neigboer_radius+1,1) (-1*neigboer_radius:neigboer_radius)']; % the top row
sindex = [sindex; neigboer_radius*ones(2*neigboer_radius+1,1) (-1*neigboer_radius:neigboer_radius)']; % the bottom row
sindex = [sindex; (1-neigboer_radius:neigboer_radius-1)' -1*neigboer_radius*ones(2*neigboer_radius-1,1)]; % the left column
sindex = [sindex; (1-neigboer_radius:neigboer_radius-1)' neigboer_radius*ones(2*neigboer_radius-1,1)]; % the right column

diffpatch_1 = zeros(M1,N1,numelnp);
diffpatch_2 = diffpatch_1;
%% 
for ii = 1:numelnp
    % translate image
    tform = maketform('affine',[1 0 0; 0 1 0; -1*sindex(ii,2) -1*sindex(ii,1) 1]);  
    tversion1 =  imtransform(image1,tform,'XData',[1 N1],'YData',[1 M1]);
    tversion2 = imtransform(image2,tform,'XData',[1 N1],'YData',[1 M1]);     
    % for image1
    diffpixel_1 = (image1 - tversion1).^2; % diffence of pixels
    diffpatch_flag = filter2(fwindows, diffpixel_1, 'same'); % diffence of patch
    diffpatch_1(:,:,ii) = (diffpatch_flag + H)./(max(lsigma1_sq,lmu1_sq) + H);
    % for image2
    diffpixel_2 = (image2 - tversion2).^2; % diffence of pixels
    diffpatch_flag = filter2(fwindows, diffpixel_2, 'same'); % diffence of patch window
    diffpatch_2(:,:,ii) = (diffpatch_flag + H)./(max(lsigma2_sq,lmu2_sq) + H);
end
NS1 = diffpatch_1(1+offset:M+offset,1+offset:N+offset,:); % remove margin   
NS2 = diffpatch_2(1+offset:M+offset,1+offset:N+offset,:); % remove margin
NS1_m = mean(NS1,3);
NS2_m = mean(NS2,3);
NS1_m_M = repmat(NS1_m,[1,1,numelnp]);
NS2_m_M = repmat(NS2_m,[1,1,numelnp]);
C12 = (NS1-NS1_m_M).*(NS2-NS2_m_M); % minus mean
C11 = (NS1-NS1_m_M).*(NS1-NS1_m_M);
C22 = (NS2-NS2_m_M).*(NS2-NS2_m_M);
miters = (sum(C12,3) + K)./( sqrt((sum(C11,3)+K).*(sum(C22,3)+K)));
miters = (1 + miters)./2;
