%% Moire Pattern Filtering using Reject Butterworth Frequency Filters - Ex.2
% Medical Radiograph of a leg bone
%
% Author: Tilemachos S. Doganis
%
% This script demonstrates the removal of Moire pattern from an X-Ray image
% of a leg bone, using Reject Butterworth Filters on the image spectrum.
%
% Initially, the 2D DFT of the image is calculated. On its visualization,
% one can distinguish that a symmetrical pair of patches stands out from
% the usual DFT shape, and assume that it corresponds to the Moire
% pattern, which has a periodic form.
% 
% One potential way of removing it is using Reject Butterworth Filters,
% which cancel out a ring-shaped area on the spectrum. These filters are
% designed with such a filter response so as to include the Moire pattern 
% pair in their Reject zone. They are initially designed as the combination
% of a low-pass and a high-pass Butterworth filter that collectively form a
% band-pass filter that includes the desired regions, then reversed to form
% a reject (band-cut) filter. Class 8 Butterworth filters were deemed
% effective enough for this case.
%
% When the Butterworth filter is applied to the image spectrum, it removes
% the frequency components that correspond to the Moire pattern.
%
% A downside is that, because of the ring shape of the Butterworth filters,
% besides the Moire pattern regions, a variety of other useful frequencies
% are removed. On the other hand, notch filters can tackle this problem
% more effectively.
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

%% Design Band-cut Butterworth filter
% Band ranges 30-40
[u,v] = meshgrid(-floor(N2/2):floor(N2/2),-floor(N1/2):floor(N1/2));
k = 8;    % Class 8
wcl = 40; % Outer Circle Range
wch = 20; % Inner Circle Range

% Filter Frequency Response
H_l = 1./(1+(sqrt(u.^2+v.^2)./wcl).^(2*k)); % Low-pass Component
H_h = 1./(1+(wch./sqrt(u.^2+v.^2)).^(2*k)); % High-pass Component
H = 1-H_h.*H_l; % Reject = 1 - Band-pass

figure(2)
subplot(1,2,1), imshow(H,[]), title('Bandcut Butterworth Filter Transfer Function')
subplot(1,2,2), mesh(H)

%% Apply Filter
Y = X.*H;
y = real(ifft2(ifftshift(Y))); % IDFT

%% Plot Final Results
figure(1)
subplot(1,4,4), imshow(log(abs(Y)+1e-20),[]), title('Filtered Image Spectrum')
subplot(1,4,2), imshow(y,[]), title('Filtered Image')
