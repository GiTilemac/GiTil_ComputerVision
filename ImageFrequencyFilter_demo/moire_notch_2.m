%% Moire Pattern Filtering using Notch Frequency Filters - Ex.2
% Medical Radiograph of a leg bone
%
% Author: Tilemachos S. Doganis
%
% This script demonstrates the removal of Moire pattern from an X-Ray image
% of a leg bone, using Notch Filters on the image spectrum.
%
% Initially, the 2D DFT of the image is calculated. On its visualization,
% one can distinguish that a symmetrical pair of patches stands out from
% the usual DFT shape, and assume that it corresponds to the Moire
% pattern, which has a periodic form.
% 
% An effective way of removing them is using Notch Filters,
% which cancel out a circular area on the spectrum. Their frequency
% response has the form of a gaussian distribution, so by aligning the
% center and variance of the response to the corresponding properties of
% the Moire pattern patch, the noise can be effectively removed without
% affecting the rest of the spectrum.
%
% This process is followed once for each patch, then by multiplicating both
% frequency responses a composite filter is formed, which, when applied
% to the image spectrum, removes the frequency components that correspond
% to the Moire pattern.
%

close all
clear
clc
%% Load image
x = imread('radiograph_2.jpg');
[N1, N2] = size(x);
X = fftshift(fft2(x));
figure(1)
subplot(1,4,1), imshow(x,[]), title('Original Image')
subplot(1,4,3), imshow(log(abs(X)+1e-20),[]), title('Original Image Spectrum')

% Subtract DFT mean
mu = mean2(X);
X = X-mu;

%% Design Composite Notch filter
% Notch Coordinates (-32,4),(35,-3)
[u,v] = meshgrid(-floor(N2/2):floor(N2/2),-floor(N1/2):floor(N1/2));

% Notch standard deviation
sigma = 10; 

% Notch 1 coordinates
wx1 = -32;
wy1 = 4;

% Notch 2 coordinates
wx2 = 35;
wy2 = -3;

% Composite Notch Filter Frequency Response
H_n = 1 - exp(-( (u-wx1).^2 + (v-wy1).^2) /sigma^2);        % 1st Notch Filter
H_n = H_n.*(1 - exp(-( (u-wx2).^2 + (v-wy2).^2) /sigma^2)); % 2nd Notch Filter

figure(2)
subplot(1,2,1), imshow(H_n,[]), title('Composite Notch Filter Frequency Response')
subplot(1,2,2), mesh(H_n)

%% Apply Composite Notch Filter
Y = X.*H_n;
Y = Y + mu;                    % Re-add DFT mean
y = real(ifft2(ifftshift(Y))); % Inverse DFT

figure(1)
subplot(1,4,4), imshow(log(abs(Y)+1e-20),[]), title('Filtered Spectrum')
subplot(1,4,2), imshow(y,[]), title('Filtered Image')