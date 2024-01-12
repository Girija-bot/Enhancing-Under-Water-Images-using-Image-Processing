function out = pyramid_reconstruct(pyramid) % Function to reconstruct an image from a Laplacian pyramid.
level = length(pyramid); % Get the number of levels in the Laplacian pyramid
for i = level : -1 : 2 % Loop through the pyramid levels in reverse order (from the finest scale to the coarsest scale)
    
    [m, n] = size(pyramid{i - 1});  % Extract size information from the image at the current level - 1
    
    pyramid{i - 1} = pyramid{i - 1} + imresize(pyramid{i}, [m, n]); %the image from the next finer scale to matchsize current level
end
out = pyramid{1}; % The reconstructed image is the base image at the coarsest scale