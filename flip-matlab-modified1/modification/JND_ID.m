% AKSHAY GORE
% https://www.codewrk.com/
% admin@codewrk.com; mycodeworklab.gmail.com #WSN #matlab #leach # image processing





function [JND]=JND_ID(I,lambda)
%close all;clc;
%% Initialize
if nargin<1
    I=imread('Ori/Mandrill.bmp');%test input image
end
if nargin<2
    lambda=0.8;%strength of the structural component, the smaller the value is, the smoother the structural component
end

I=double(I);
bg=func_bg(I); % Average background luminance
%% Calculating JNDl: luminance adaptation
T0=17;
GAMMA=3/128;
JNDl=GAMMA*(bg-127)+3;
JNDl(bg<=127)=T0*(1-sqrt(bg(bg<=127)/127))+3;
%% Image decomposition
% Call W.T. Yin's code
I_s = Graph_anisoTV_L1_v2(uint8(I),lambda,4,2);clc;I_s=double(I_s);% structural component
I_t=double(I)-double(I_s);%textural component
% figure,imshow(I,[]);figure,imshow(I_s,[]);figure,imshow(I_t,[]);
Gm_e= func_Gm(I_s); % contrast for edge
Gm_t= func_Gm(I_t); % contrast for texture
%% Calculating JNDt: texture/edge masking
LANDA = 1/2;
alpha = 0.0001*bg+0.115;
belta = LANDA-0.01*bg;
% alpha = 0.117;
% belta = 0;
JNDt_e = min(max(Gm_e.*alpha + belta,0),50);% edge masking,clipped to [0 10]
JNDt_t = min(max(Gm_t.*alpha + belta,0),50);% texture masking,clipped to [0 10]
We=0.7;Wt=1.4;% weighting parameter
JNDt=We*JNDt_e+Wt*JNDt_t;% overall contrast masking
%% overall JND value
C_TG = 0.3;% overlapping parameter
JND=JNDl+JNDt-C_TG*min(JNDl,JNDt);% JND map
% figure,imshow(JND,[]);% Display the JND map
end



%% Calculate background luminance
function output=func_bg(input)
Mask=[1 1 1 1 1
      1 2 2 2 1
      1 2 0 2 1
      1 2 2 2 1
      1 1 1 1 1];
output = filter2(Mask,input)/32;
end
%% Calculate contrast of the image
function Gm=func_Gm(input)
G1=[0  0  0  0  0
    1  3  8  3  1
    0  0  0  0  0
   -1 -3 -8 -3 -1
    0  0  0  0  0];

G2=[0 0  1  0  0
    0 8  3  0  0
    1 3  0 -3 -1
    0 0 -3 -8  0
    0 0 -1  0  0];

G3=[0  0  1 0 0
    0  0  3 8 0
   -1 -3  0 3 1
    0 -8 -3 0 0
    0  0 -1 0 0];

G4=[0 1 0 -1 0
    0 3 0 -3 0
    0 8 0 -8 0
    0 3 0 -3 0
    0 1 0 -1 0];
[H,W]=size(input);
grad=zeros(H,W,4);
grad(:,:,1) = filter2(G1,input)/16;
grad(:,:,2) = filter2(G2,input)/16;
grad(:,:,3) = filter2(G3,input)/16;
grad(:,:,4) = filter2(G4,input)/16;
Gm = max(abs(grad),[],3);
end