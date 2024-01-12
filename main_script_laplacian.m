img = imread('C:\Users\lenovo\Downloads\img.jpg');  % Replace 'your_image_path.jpg' with the actual image path

% Convert the image to grayscale if it's a color image
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Choose the number of pyramid levels
pyramid_levels = 4;

% Call the laplacian_pyramid function
pyramid = laplacian_pyramid(img, pyramid_levels);

% Display the original image and the pyramid levels
figure;

subplot(pyramid_levels+1, 2, 1);
imshow(img);
title('Original Image');

for i = 1 : pyramid_levels
    subplot(pyramid_levels+1, 2, i*2 + 1);
    imshow(pyramid{i});
    title(['Level ' num2str(i)]);
end

% Display the difference of Gaussians (DoG)
for i = 1 : pyramid_levels - 1
    subplot(pyramid_levels+1, 2, i*2 + 2);
    imshow(pyramid{i} - imresize(pyramid{i+1}, size(pyramid{i})));
    title(['DoG ' num2str(i)]);
end
