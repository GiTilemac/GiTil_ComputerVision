%% Gaussian Pyramid Construction
%
% Author: Tilemachos S. Doganis
%
function [ G ] = gen_gaussPyr( varargin )
% 
% Input: Original Image, Number of levels, Convolution kernel (Optional)
% Output: Gaussian Pyramid (cell)
%
% This function expresses the convolution and downsampling operating required to
% calculate each new level as ancillary matrices, in order to allow for reusability
% and potentially improve efficiency.
%
% 1. Call 'mypyr_reduce' to calculate the first pyramid level along with the
% corresponding Toeplitz and Downsampling matrices, which are stored in the
% first place of the pyramid cell structure 'G', with the original image stored
% in the second place.
% 
% 2. For all subsequent pyramid levels call 'mypyr_reduce' using the last level
% produced along with the corresponding submatrix of the ancillary matrices. 
%
% Construction algorithm based on:
% https://www.cs.toronto.edu/~mangas/teaching/320/slides/CSC320L10.pdf
%
	% Custom / default convolution kernel
    if (nargin == 4)
        h = fspecial('gaussian',[varargin{4} 1],varargin{3});
    else
        h = 1/16*[1;4;6;4;1]; 
    end
    I = varargin{1};
    levels = varargin{2};
    
    % Store downsample and Toeplitz matrices D and T
    G = cell(levels+1,1);               % Add a level to store matrices
    G{1} = struct('Dc','Dr','Tc','Tr'); 
    G{2} = I;                           %Bottom level is original image
    
    
    % Calculate D and T for first reduction, then use sub-matrices for the
    % rest
    [G{3},G{1}.Dc,G{1}.Dr,G{1}.Tc,G{1}.Tr] = mypyr_reduce(G{2},h);

    % Create Gaussian Pyramid bottom-up: G_i = reduce{G_(i-1)}
    % Use submatrices of D and T to reduce computation time
    for i = 3:levels
        [M,N,~] = size(G{i});
        G{i+1} = mypyr_reduce(G{i},h,...
            G{1}.Dc(1:ceil(M/2),1:M),...
            G{1}.Dr(1:N,1:ceil(N/2)),...
            G{1}.Tc(1:M,1:M),...
            G{1}.Tr(1:N,1:N));
    end
end