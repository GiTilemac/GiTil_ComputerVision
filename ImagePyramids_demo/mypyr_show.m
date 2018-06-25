%% Image Pyramid Visualization
%
% Visualizes an image pyramid stored in cell form
%
% Source: https://stackoverflow.com/a/27002718
%
function [] = mypyr_show( P )
    newP = P{2};
    M = size(newP,1);
    for i = 3:numel(P)
        [m,n,c] = size(P{i});
        P{i} = cat(1,repmat(zeros(1,n,c),[M-m,1]),P{i});
        newP = cat(2,newP,P{i});
    end
    figure,imshow(newP)
end