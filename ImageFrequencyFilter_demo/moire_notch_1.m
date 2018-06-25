%% Moire Pattern Filtering using Notch Frequency Filters - Ex.1
% Medical Radiograph of a skull
%
% Author: Tilemachos S. Doganis
%
% This script demonstrates the removal of Moire pattern from an X-Ray image
% of a skull, using Notch Filters on the image spectrum.
%
% Initially, the 2D DFT of the image is calculated. On its visualization,
% one can distinguish that two symmetrical pairs of patches stand out from
% the usual DFT shape, and assume that they correspond to the Moire
% pattern, which has a periodic form.
% 
% An effective way of removing them is using Notch Filters,
% which cancel out a circular area on the spectrum. Their frequency
% response has the form of a gaussian distribution, so by aligning the
% center and variance of the response to the corresponding properties of
% the Moire pattern patch, the noise can be effectively removed without
% affecting the rest of the spectrum.
%
% This process is followed once for each patch, then by multiplicating the
% four frequency responses a composite filter is formed, which, when applied
% to the image spectrum, removes the frequency components that correspond
% to the Moire pattern.
%

close all
clear
clc
%% Load image
x = imread('radiograph_1.jpg');
[N1, N2] = size(x);
X = fftshift(fft2(x));
figure(1)
subplot(2,2,1), imshow(x), title('Original Image')
subplot(2,2,2), imshow(log(abs(X)+1e-20),[]), title('Original Image Spectrum')

% Subtract DFT mean
mu = mean2(X);
X = X-mu;

%% Design Composite Notch Filter
% Notch Coordinates (-8,48),(8,-47),(-16,90),(16,-90)
[u,v] = meshgrid(-floor(N2/2):floor(N2/2),-floor(N1/2):floor(N1/2));
sigma1 = 40; % Inner notch standard deviation
sigma2 = 20; % Outer notch standard deviation

% Notch 1 Coordinates
wx1 = -8;
wy1 = 48;

% Notch 2 Coordinates
wx2 = 8;
wy2 = -47;

% Notch 3 Coordinates
wx3 = -16;
wy3 = 90;

% Notch 4 Coordinates
wx4 = 16;
wy4 = -90;

% Composite Notch Filter Frequency Response
H_n = 1 - exp(-( (u-wx1).^2 + (v-wy1).^2) /sigma1^2);        % 1st Notch Filter
H_n = H_n.*(1 - exp(-( (u-wx2).^2 + (v-wy2).^2) /sigma1^2)); % 2nd Notch Filter
H_n = H_n.*(1 - exp(-( (u-wx3).^2 + (v-wy3).^2) /sigma2^2)); % 3rd Notch Filter
H_n = H_n.*(1 - exp(-( (u-wx4).^2 + (v-wy4).^2) /sigma2^2)); % 4th Notch Filter

figure(2)
subplot(2,1,1), imshow(H_n,[]), title('Composite Notch Filter Frequency Response')
subplot(2,1,2), mesh(H_n)

%% Apply Composite Notch Filter
Y = X.*H_n;
Y = Y + mu;                    % Re-add DFT mean
y = real(ifft2(ifftshift(Y))); % Inverse DFT

figure(1)
subplot(2,2,4), imshow(log(abs(Y)+1e-20),[]), title('Filtered Spectrum')
subplot(2,2,3), imshow(y,[]), title('Filtered Image')
