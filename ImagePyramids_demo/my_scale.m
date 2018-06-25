%% Custom Image Scaling Function
%
% Author: Tilemachos S. Doganis
%
% This function implements the scale transform using the affine 2D
% transform model.
%
function [ I_sc ] = my_scale( varargin )
    I = varargin{1};
    scalex = varargin{2};
    if nargin == 3
        scaley = varargin{3};
    else
        scaley = scalex;
    end
     
    A = [scalex    0     0;
         0      scaley   0;
         0         0     1];
    stform = affine2d(A');
    I_sc = imwarp(I,stform,'cubic','FillValues',1.0);
end