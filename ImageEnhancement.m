close all;
clear all;
clc;

%%% Underwater White Balance %%%

%% Load the image and split channels. 

rgbImage=double(imread('C:\Users\lenovo\Downloads\img.jpg'))/255; % Load the image and convert it to double format, scaling to the range [0, 1]

grayImage = rgb2gray(rgbImage); % Convert the RGB image to grayscale

Ir = rgbImage(:,:,1); % Extract the individual color channels (Red, Green, Blue) from the RGB image
Ig = rgbImage(:,:,2);
Ib = rgbImage(:,:,3);

Ir_mean = mean(Ir, 'all'); % Calculate the mean intensity for each color channel
Ig_mean = mean(Ig, 'all');
Ib_mean = mean(Ib, 'all');

%% Color compensation
alpha = 0.1; % Define a compensation factor (alpha) for color channels
Irc = Ir + alpha*(Ig_mean - Ir_mean); % Apply compensation to the Red channel (Irc)
alpha = 0; % 0 does not compensates blue channel. 

Ibc = Ib + alpha*(Ig_mean - Ib_mean);

%% White Balance
% Concatenate the compensated channels to form a color-corrected image (I)
I = cat(3, Irc, Ig, Ibc);
I_lin = rgb2lin(I); % Convert the color-corrected image to linear RGB space
percentiles = 5; % Define a percentage for calculating image illuminant
illuminant = illumgray(I_lin,percentiles); % Estimate the illuminant using the linear RGB image
I_lin = chromadapt(I_lin,illuminant,'ColorSpace','linear-rgb'); % Apply chromatic adaptation to correct color imbalances
Iwb = lin2rgb(I_lin); % Convert the linear RGB image back to RGB space (Iwb - White Balanced Image)


%%% Multi-Scale fusion. 

%% Gamma Correction
Igamma = imadjust(Iwb,[],[],2); % applies gamma correction to the white-balanced image, each pixel raide to power 2


%% image sharpening
sigma = 20; % Set the standard deviation for the Gaussian filter
Igauss = Iwb; % Initialize the blurred image as the white-balanced image
N = 30; % Number of iterations for the sharpening process
for iter=1: N 
   Igauss =  imgaussfilt(Igauss,sigma); % Apply Gaussian filtering to the blurred image
   Igauss = min(Iwb, Igauss); % Ensure the sharpened image does not exceed the original intensity
end

gain = 1; % Set the gain for the sharpening process  
Norm = (Iwb-gain*Igauss); % Calculate the normalized difference between the white-balanced image and the blurred image
% Apply histogram equalization to enhance contrast in each color channel separately
for n = 1:3
   Norm(:,:,n) = histeq(Norm(:,:,n)); 
end
Isharp = (Iwb + Norm)/2;  % Combine the normalized difference and the original image to obtain the sharpened image


%% weights calculation

% Lapacian contrast weight % Convert the sharpened and gamma-corrected images to CIELAB color space
Isharp_lab = rgb2lab(Isharp);
Igamma_lab = rgb2lab(Igamma);

% input1
R1 = double(Isharp_lab(:, :, 1)) / 255; % Extract the L* channel from the CIELAB representation and normalize it
% calculate laplacian contrast weight
WC1 = sqrt((((Isharp(:,:,1)) - (R1)).^2 + ...
            ((Isharp(:,:,2)) - (R1)).^2 + ...
            ((Isharp(:,:,3)) - (R1)).^2) / 3);
% calculate the saliency weight
WS1 = saliency_detection(Isharp);
WS1 = WS1/max(WS1,[],'all');
% calculate the saturation weight

WSAT1 = sqrt(1/3*((Isharp(:,:,1)-R1).^2+(Isharp(:,:,2)-R1).^2+(Isharp(:,:,3)-R1).^2)); % Calculate the saturation weight for input1


%figure('name', 'Image 1 weights');
%imshow([WC1 , WS1, WSAT1]);


% input2
R2 = double(Igamma_lab(:, :, 1)) / 255;
% calculate laplacian contrast weight
WC2 = sqrt((((Igamma(:,:,1)) - (R2)).^2 + ...
            ((Igamma(:,:,2)) - (R2)).^2 + ...
            ((Igamma(:,:,3)) - (R2)).^2) / 3);
% calculate the saliency weight
WS2 = saliency_detection(Igamma);
WS2 = WS2/max(WS2,[],'all');

% calculate the saturation weight
WSAT2 = sqrt(1/3*((Igamma(:,:,1)-R1).^2+(Igamma(:,:,2)-R1).^2+(Igamma(:,:,3)-R1).^2));


% calculate the normalized weight
W1 = (WC1 + WS1 + WSAT1+0.1) ./ ...
     (WC1 + WS1 + WSAT1 + WC2 + WS2 + WSAT2+0.2);
W2 = (WC2 + WS2 + WSAT2+0.1) ./ ...
     (WC1 + WS1 + WSAT1 + WC2 + WS2 + WSAT2+0.2);
 
 
%% Naive fusion
R = W1.*Isharp+W2.*Igamma; %to combine pixel values from different images.


%% Multi scale fusion.
 img1 = Isharp;
 img2 = Igamma;

% calculate the gaussian pyramid
level = 10;
Weight1 = gaussian_pyramid(W1, level);
Weight2 = gaussian_pyramid(W2, level);

% calculate the laplacian pyramid
% input1
R1 = laplacian_pyramid(Isharp(:, :, 1), level);
G1 = laplacian_pyramid(Isharp(:, :, 2), level);    % to improve images particularly useful when images appear blurry or lack sharpness.
B1 = laplacian_pyramid(Isharp(:, :, 3), level);
% input2
R2 = laplacian_pyramid(Igamma(:, :, 1), level);
G2 = laplacian_pyramid(Igamma(:, :, 2), level);  % helps improve the overall brightness and contrast of an image
B2 = laplacian_pyramid(Igamma(:, :, 3), level);

% fusion
for k = 1 : level
   Rr{k} = Weight1{k} .* R1{k} + Weight2{k} .* R2{k};
   Rg{k} = Weight1{k} .* G1{k} + Weight2{k} .* G2{k};
   Rb{k} = Weight1{k} .* B1{k} + Weight2{k} .* B2{k};
end

% reconstruct & output
R = pyramid_reconstruct(Rr);
G = pyramid_reconstruct(Rg);
B = pyramid_reconstruct(Rb);
fusion = cat(3, R, G, B);

figure('name', 'Multi scale fusion'); % applying fusion at each scale, and then reconstructing the final fused image.
imshow([I, fusion])