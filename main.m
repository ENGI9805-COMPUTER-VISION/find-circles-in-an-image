%% Load  image
clear all;
clc;
img = imread(fullfile('input', 'im1.png'));  % already grayscale
%% Find edges
img = img(:,:,1);

gaussianFilter = fspecial('gaussian',20, 10);
img_filted = imfilter(img, gaussianFilter,'symmetric');

filted_edges = edge(img_filted, 'Canny');
figure();
subplot(121);
imshow(filted_edges);
title('Edges found in filted image');
img_edges = edge(img, 'Canny');
subplot(122);
imshow(img_edges);
title('Edges found in original image')
% Since the original image here does not have any noise,
% so it is not necessary to use Gaussian filter to decrease the noise
% first. And actually, using Gaussian filter first in this case will
% result in a worse edge image
% imwrite(img_filted, fullfile('output', 'ps1-3-a-1.png'));  % save as output/ps1-1-a-1.png
% imwrite(filted_edges, fullfile('output', 'ps1-3-b-1.png')); 
% imwrite(img_edges, fullfile('output', 'ps1-3-b-2.png')); 


%% Find Circles (Use hough transform for circles)
[centers, radii] = find_circles(filted_edges, [20,100]);
hough_circles_draw(img, centers, radii);