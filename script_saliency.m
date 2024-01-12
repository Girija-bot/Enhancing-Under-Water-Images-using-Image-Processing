% Load the image
img = imread('C:\Users\lenovo\Downloads\img.jpg');  % Replace with the path to your image

% Perform saliency detection
saliency_map = saliency_detection(img);

% Display the original image and the saliency map
figure;
subplot(1, 2, 1);
imshow(img);
title('Original Image');

subplot(1, 2, 2);
imshow(saliency_map, []);
title('Saliency Map');
