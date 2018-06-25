%% Moire Pattern Filtering using Reject Butterworth Frequency Filters - Ex.1
% Medical Radiograph of a skull
%
% Author: Tilemachos S. Doganis
%
% This script demonstrates the removal of Moire pattern from an X-Ray image
% of a skull, using Reject Butterworth Filters on the image spectrum.
%
% Initially, the 2D DFT of the image is calculated. On its visualization,
% one can distinguish that two symmetrical pairs of patches stand out from
% the usual DFT shape, and assume that they correspond to the Moire
% pattern, which has a periodic form.
% 
% One potential way of removing them is using Reject Butterworth Filters,
% which cancel out a ring-shaped area on the spectrum. These filters are
% designed with such a filter response so as to include both pairs in their
% Reject zone. They are initially designed as the combination of a low-pass
% and a high-pass Butterworth filter that collectively form a band-pass
% filter that includes the desired regions, then reversed to form a
% reject (band-cut) filter. Class 5 Butterworth filters were deemed
% effective enough for this case.
%
% This process is followed once for each pair, then by multiplicating the
% two frequency responses a composite filter is formed, which, when applied
% to the image spectrum, removes the frequency components that correspond
% to the Moire pattern.
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
x = imread('radiograph_1.jpg');
[N1, N2] = size(x);
X = fftshift(fft2(x));
figure(1)
subplot(2,2,1), imshow(x), title('Original Image')
subplot(2,2,2), imshow(log(abs(X)+1e-20),[]), title('Image Spectrum')

%% Design Reject Butterworth filter for inner area
% Band range 35-65
[u,v] = meshgrid(-floor(N2/2):floor(N2/2),-floor(N1/2):floor(N1/2));
k = 5;    % Class 5
wcl = 65; % Outer circle range
wch = 35; % Inner circle range

% Reject Butterworth Filters Frequency Response
H_l = 1./(1+(sqrt(u.^2+v.^2)./wcl).^(2*k)); % Low-pass component
H_h = 1./(1+(wch./sqrt(u.^2+v.^2)).^(2*k)); % High-pass component
H = 1-H_h.*H_l; % Reject = 1 - Band-pass

%% Design Reject Butterworth filter for outer area
% Band range 70-120
wcl = 120; % Outer circle range
wch = 70;  % Inner circle range

% Reject Butterworth Filters Frequency Response
H_l = 1./(1+(sqrt(u.^2+v.^2)./wcl).^(2*k)); % Low-pass component
H_h = 1./(1+(wch./sqrt(u.^2+v.^2)).^(2*k)); % High-pass component
H = H.*(1-H_h.*H_l); % Reject = 1 - Band-pass

% Plot Butterworth Filter Transfer Function
figure(2)
subplot(2,1,1), imshow(H,[]), title('Bandcut Butterworth Filter Transfer Function')
subplot(2,1,2), mesh(H)

%% Apply Filter
Y = X.*H;
y = real(ifft2(ifftshift(Y))); % IDFT

%% Plot Final Results
figure(1)
subplot(2,2,4), imshow(log(abs(Y)+1e-20),[]), title('Filtered Image Spectrum')
subplot(2,2,3), imshow(y,[]), title('Filtered Image')
