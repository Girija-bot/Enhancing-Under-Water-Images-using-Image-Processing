function out = gaussian_pyramid(img, level)
h = 1/16* [1, 4, 6, 4, 1]; % creates a 1D Gaussian filter smoothing
filt = h'*h; %computes the 2D filter
out{1} = imfilter(img, filt, 'replicate', 'conv'); %image by replicating the border pixels and convolution
temp_img = img;
for i = 2 : level
    temp_img = temp_img(1 : 2 : end, 1 : 2 : end); % selects every other pixel along each dimension, effectively reducing the image size by half
    out{i} = imfilter(temp_img, filt, 'replicate', 'conv'); % downsampling
end