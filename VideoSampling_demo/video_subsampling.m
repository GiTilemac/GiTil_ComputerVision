%% A simple demonstration on the effects of undersampling a periodic video.
% 
% Author: Tilemachos S. Doganis
%
% The function loads a periodic video in .gif form, with period N, then samples it at
% two different rates: n_1 = n * N and n_2 = n * (N-1).
% As is visualized below, the first sampling rate leads to the same frame 
% repeating itself for every period, resulting in a "Time Freeze" Effect. 
% The second sampling rate, which is a bit smaller, results in a "delay"
% when choosing a sample in each period, leading to the reversal of the frame sequence
% When visualized, it looks as if the video plays backwards.
%
% Test gif source: https://media.giphy.com/media/JnMoHKeNyQP1m/giphy.gif
%

function [] = video_subsampling(filename, N_c)
    %% File loading and parameter initialization
    % Test image is 'fan.gif'
    if nargin == 0
        filename = 'fan.gif';
    end
    
    gif_info = mmfileinfo(filename);                     % Image information object
    v_read = vision.VideoFileReader(filename);           % Open file in video reader
    N = v_read.info.VideoFrameRate * gif_info.Duration;  % Multiply FPS with duration for frame period

    % Store frames into array A
    A = ones(v_read.info.VideoSize(2),v_read.info.VideoSize(1),3,N);
    for i=1:N
        A(:,:,:,i) = step(v_read);
    end
    
    % Default number of loop cycles    
    if nargin == 1
        N_c = 25; 
    end

    %% Original frame signal
    % The original signal is repeated over N_c cycles to enable a clearer
    % visualization, as well as variations in the sampling rate afterwards
    % The signal is, essentially, the frame number sequence
    x0 = repmat(1:N, [1 N_c]);

    % Visualiziation
    figure(1)
    for i = 1:N_c
        imshow(A(:,:,:,x0(i))), title(['Frame ' num2str(x0(i))])
        pause(0.2)
    end

    %% Signal sampled at original frequency (Time Freeze Effect)
    x1_end = N_c*N-(N-1);  % Last position before index is out of bounds
    x1 = x0(1:N:x1_end);   % Sampling x(n) -> x_1(n_1) with n_1 = n * N
    % Visualiziation
    figure(2)
    for i = 1:numel(x1)
        imshow(A(:,:,:,x1(i))), title(['Frozen Frame ' num2str(x1(i))])
        pause(0.2)
    end

    %% Signal sampled at lower frequency than original (Time Reversal Effect)
    % Note that in order for the time reversal effect to be successfully
    % visualized, sampling starts at the Nth sample
    x2_end = floor((N_c*(N-1)-N)/(N-1))*(N-1); % Last position before index is out of bounds
    x2 = x0(N:N-1:x2_end);                     % Sampling x(n) -> x_2(n_2) with n_2 = n * (N-1)

    % Visualiziation
    figure(3)
    for i = 1:numel(x2)
        imshow(A(:,:,:,x2(i))), title(['Reversed Frame ' num2str(x2(i))])
        pause(0.2)
    end

    %% Frame sequence visualization
    figure(4), hold on
    stem(x0,'b'), stem(1:N:x1_end,x1,'g'), stem(N:N-1:x2_end,x2,'r')
    title('Frame sequences')
    legend('Original','Time Freeze','Time Reversal')
end