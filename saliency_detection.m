function sm = saliency_detection(img) % Function to perform saliency detection on an input image.

gfrgb = imfilter(img, fspecial('gaussian', 3, 3), 'symmetric', 'conv');

cform = makecform('srgb2lab');
lab = applycform(gfrgb,cform);
% Convert the smoothed image from the sRGB color space to the CIE Lab color space.
l = double(lab(:,:,1)); lm = mean(mean(l));
a = double(lab(:,:,2)); am = mean(mean(a));
b = double(lab(:,:,3)); bm = mean(mean(b));
% Calculate saliency map using color deviation
sm = (l-lm).^2 + (a-am).^2 + (b-bm).^2;
