%% Laplacian Pyramid Construction
%
% Author: Tilemachos S. Doganis
%
% 1. Copy ancillary matrices from Gaussian Pyramid cell.
% Downsampling matrices are transposed and used as Upsampling matrices.
% 
% 2. Assign top level of Gaussian Pyramid to the top level of the
% Laplacian Pyramid.
% 
% 3. Calculate each level of the Laplacian pyramid as the difference
% between the corresponding Gaussian pyramid level and the expansion
% of the level immediately above.
% 
function [ L ] = gen_laplPyr( G )
    levels = numel(G);
    L = cell(levels,1);
    L{1} = struct('Uc',G{1}.Dc',...
                  'Tc',2*G{1}.Tc,... Multiply by 2 to preserve value range
                  'Ur',G{1}.Dr',...
                  'Tr',2*G{1}.Tr); % Multiply by 2 to preserve value range
    L{levels} = G{levels}; % Final level of Laplacian is final level of Gaussian
    
    % Top-down construction of Laplacian Pyramid: L_i = G_i - expand{G_(i+1)}
    for i = (levels-1):-1:2
        [M1,N1,~] = size(G{i+1});
        [M2,N2,~] = size(G{i});
        L{i} = 0.5 + ... Add 0.5 to ensure positive value range
                G{i} - mypyr_expand(G{i+1},L{1}.Uc(1:M2,1:M1),...
                                          L{1}.Ur(1:N1,1:N2),...
                                          L{1}.Tc(1:M2,1:M2),...
                                          L{1}.Tr(1:N2,1:N2));                           
    end
end