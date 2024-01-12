% Load the image
img = imread('C:\Users\lenovo\Downloads\img.jpg');  % Replace with the path to your image

% Choose the desired number of pyramid levels
level = 5;

% Call the function to create the pyramid
pyramid = gaussian_pyramid(img, level);

% Display the original image
figure;
imshow(img);

% Display one level of the pyramid (e.g., the second level)
figure;
imshow(pyramid{2});
