%% Construction of Gaussian from Laplacian Pyramid
%
% Author: Tilemachos S. Doganis
%
function [ G ] = l2gPyr( L )
%
% Input: Laplacian Pyramid (cell)
% Output: Gaussian Pyramid (cell)
%
% 1. Anicllary matrices and the top level are copied from the Laplacian
% to the Gaussian pyramid.
% 
% 2. Gaussian pyramid levels are calculated by adding the corresponding
% Laplacian pyramid levels with the expansions of the immediately above
% Gaussian pyramid levels.
%
    levels = numel(L);
    G = cell(levels,1);
    
    %% Copy ancillary matrices and top level
    % Copy Downsampling and Convolution matrices
    G{1} = struct('Dc',L{1}.Uc',...
              'Tc',1/2*L{1}.Tc,...
              'Dr',L{1}.Ur',...
              'Tr',1/2*L{1}.Tr);
          
    % Top level of Laplacian pyramid coincides with top level of
    % corresponding Gaussian pyramid.
    G{levels} = L{levels};
    
    %% Top-down Gaussian Pyramid Construction
    % Construct Gaussian pyramid top-down by adding Laplacian levels to
    % expanded previous Gaussian pyramid levels:
    % G_i = L_i + expand{G_(i+1)}

    for i = (levels-1):-1:2
    [M1,N1,~] = size(G{i+1});
    [M2,N2,~] = size(L{i});
    G{i} = -0.5 + L{i} + mypyr_expand(G{i+1},L{1}.Uc(1:M2,1:M1),...
                                      L{1}.Ur(1:N1,1:N2),...
                                      L{1}.Tc(1:M2,1:M2),...
                                      L{1}.Tr(1:N2,1:N2));                           
    end
end