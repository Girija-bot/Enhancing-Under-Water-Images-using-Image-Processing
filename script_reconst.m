
% Load an example image
img = imread('C:\Users\lenovo\Downloads\img.jpg');  % Replace 'your_image_path.jpg' with the actual image path

% Convert the image to grayscale if it's a color image
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Call the laplacian_pyramid function
pyramid = laplacian_pyramid(img, pyramid_levels);

% Reconstruct the image from the Laplacian pyramid
reconstructed_image = pyramid_reconstruct(pyramid);

% Display the original image, pyramid levels, and reconstructed image
% Set larger figure size
figure('Position', [100, 100, 2100, 2300]);

subplot(pyramid_levels+2, 2, 1);
imshow(img);
title('Original Image');

% Display the reconstructed image
subplot(pyramid_levels+2, 2, (pyramid_levels+1)*2 - 1);
imshow(reconstructed_image);
title('Reconstructed Image');
