function [centers, r_estimated] = findcircularobjects(A, radiusRange, sensitivity)
%IMFINDCIRCLES Find circles using Circular Hough Transform.
%   CENTERS = IMFINDCIRCLES(A, RADIUS) finds circles with approximately the
%   specified RADIUS, in pixels, in the input image A. A can be a
%   grayscale, RGB or binary image. CENTERS is a P-by-2 matrix with
%   X-coordinates of the circle centers in the first column and the
%   Y-coordinates in the second column. CENTERS is sorted based on the
%   circle strengths.
%
%   Parameters include:
%
%   'Sensitivity '  - Specifies the sensitivity factor in the range [0 1]
%                     for finding circles. A high sensitivity value leads
%                     to detecting more circles, including weak or
%                     partially obscured ones, at the risk of a higher
%                     false detection rate.
%
%   Example
%   ---------
%   % Find and display the five strongest circles in the image
%         A = imread('coins.png');
%         % Display the original image
%         imshow(A)
% 
%         % Find all the circles with radius >= 15 and radius <= 30
%         [centers, radii, metric] = imfindcircles(A,[15 30]);
% 
%         % Retain the five strongest circles according to metric values
%         centersStrong5 = centers(1:5,:);
%         radiiStrong5 = radii(1:5);
%         metricStrong5 = metric(1:5);
% 
%         % Draw the circle perimeter for the five strongest circles
%         viscircles(centersStrong5, radiiStrong5,'Color','b');
%


%% Calculate the accumulator array
[accumMatrix, ~] = computeaccumulator(A, radiusRange);

%% Find the centers
accumThresh = 1 - sensitivity;
[centers, metric] = findcirclecenter(accumMatrix, accumThresh);

%% Retain circles with metric value greater than threshold corresponding to AccumulatorThreshold 
idx2Keep = find(metric >= accumThresh);
centers = centers(idx2Keep,:);


%% Calculate radii
r_estimated = phasecoding(centers, accumMatrix, radiusRange); 

end
