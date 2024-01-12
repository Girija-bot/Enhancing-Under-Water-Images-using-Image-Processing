function out = laplacian_pyramid(img, level)
h = 1/16* [1, 4, 6, 4, 1];  % Define a 1D Gaussian filter kernel
 
out{1} = img;
temp_img = img;  % Initialize a temporary variable to store the current image
for i = 2 : level % Downsample the temporary image by a factor of 2
    temp_img = temp_img(1 : 2 : end, 1 : 2 : end);
   
    out{i} = temp_img;
end
% Calculate the Difference of Gaussians (DoG) between consecutive levels
for i = 1 : level - 1
    [m, n] = size(out{i});  % Resize the next level to match the size of the current level
    out{i} = out{i} - imresize(out{i+1}, [m, n]); % Calculate the DoG by subtracting the resized next level from the current level
end