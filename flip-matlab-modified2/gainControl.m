function [rComb] = gainControl(reference, visualAngle)
%GAINCONTROL Summary of this function goes here
%   Detailed explanation goes here
   %////////////////////

gray = rgb2gray(reference);

%clc; clear; close;
fq = 0.1:0.01:50; % fq: spatial frequency in cycle/degree, should be a scalar or a vector
L  = 100;         % L: display luminance in cd/m2
Ls = 200;         % Ls: surround luminance in cd/m2
X  = visualAngle;          % X: Field of view in degree
CSF_out = CSF(gray,L,Ls,X);    % calculate corresponding CSF values using the provided function


%calculate frequency filter
%[rows, columns] = size(gray);
%grayfft = fft2(gray);

%X = linspace(-columns/2, columns/2, columns);
%Y = linspace(-rows/2, rows/2, rows);
%[x, y] = meshgrid(X, Y);

%distanceImage = sqrt(x.^2 + y.^2);

%A = 2.6 * (0.0192 + 0.114*distanceImage) .* exp(-0.114*distanceImage ) .^ 1.1;

%filteredFFT = grayfft .* A;
%filteredSpatialDomainImage = ifft2(filteredFFT);


%imshow(filteredSpatialDomainImage, []);

%calculate CSF
normalizedCSF = CSF_out;
%normalizedCSF = normalize(CSF_out);

%figure; imshow(normalizedCSF);
%xlabel('Spatial frequency (cycle/degree)');
%ylabel('Contrast sensitivity');

wavelength = 4;
orientation = 0;
[mag1,~] = imgaborfilt(normalizedCSF,wavelength,orientation);
orientation = 90;
[mag2,~] = imgaborfilt(normalizedCSF,wavelength,orientation);
orientation = 180;
[mag3,~] = imgaborfilt(normalizedCSF,wavelength,orientation);
orientation = 270;
[mag4,~] = imgaborfilt(normalizedCSF,wavelength,orientation);

%figure; imshow(mag1);

%figure; imshow(phase);

%currently no sampling

p = 3;

excitatory1 = mag1.^p;
excitatory2 = mag2.^p;
excitatory3 = mag3.^p;
excitatory4 = mag4.^p;

%figure; imshow(excitatory1);
%figure; imshow(normalize(excitatory1));

q = 2;

inhibatory1 = mag1.^q;
inhibatory2 = mag2.^q;
inhibatory3 = mag3.^q;
inhibatory4 = mag4.^q;







% pooling
magComb = inhibatory1 + inhibatory2 + inhibatory3 + inhibatory4;
%figure; imshow(magComb);
%figure; imshow(normalize(magComb));


% divisive gain control
b = 4;

r1 = excitatory1./(b^2 + magComb);
r2 = excitatory2./(b^2 + magComb);
r3 = excitatory3./(b^2 + magComb);
r4 = excitatory4./(b^2 + magComb);
%figure; imshow(r1);
%figure; imshow(r1./10);
%figure; imshow(r1./100);


rComb = r1 + r2 + r3 + r4;

%////////////////////
end

