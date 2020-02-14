function [centers, r_estimated] = findcircularobjects(A, radiusRange, sensitivity)
%IMFINDCIRCLES Find circles using Circular Hough Transform.
%   CENTERS = IMFINDCIRCLES(A, RADIUS) finds circles with approximately the
%   specified RADIUS, in pixels, in the input image A. A can be a
%   grayscale, RGB or binary image. CENTERS is a P-by-2 matrix with
%   X-coordinates of the circle centers in the first column and the
%   Y-coordinates in the second column. CENTERS is sorted based on the
%   circle strengths.
%
%   [CENTERS, RADII] = IMFINDCIRCLES(A, RADIUS_RANGE) finds circles with
%   radii in the search range specified by RADIUS_RANGE. RADIUS_RANGE is a
%   two-element vector [MIN_RADIUS MAX_RADIUS], where MIN_RADIUS and
%   MAX_RADIUS have integer values. The estimated radii, in pixels, for the
%   circles are returned in the column vector RADII.
%
%   [CENTERS, RADII, METRIC] = IMFINDCIRCLES(A, RADIUS_RANGE) also
%   returns the magnitude of the accumulator array peak associated with
%   each circle in the column vector METRIC. CENTERS and RADII are
%   sorted in descending order of their corresponding METRIC values.
% 
%   [CENTERS, RADII, METRIC] = IMFINDCIRCLES(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   finds circles using name-value pairs to control aspects of the Circular 
%   Hough Transform. Parameter names can be abbreviated.
%
%   Parameters include:
%
%   'ObjectPolarity' - Specifies the polarity of the circular object with
%                      respect to the background. Available options are:
%
%           'bright'     : The object is brighter than the background. (Default)
%           'dark'       : The object is darker than the background.
% 
%   'Method' - Specifies the technique used for computing the accumulator
%              array. Available options are:
%
%           'PhaseCode'  : Atherton and Kerbyson's Phase Coding method.
%                         (Default)
%           'TwoStage'   : The method used in Two-stage Circular Hough
%                          Transform.
% 
%   'Sensitivity '  - Specifies the sensitivity factor in the range [0 1]
%                     for finding circles. A high sensitivity value leads
%                     to detecting more circles, including weak or
%                     partially obscured ones, at the risk of a higher
%                     false detection rate. Default value: 0.85
%
%
%   Notes
%   -----
%   1.  Binary images (must be logical matrix) undergo additional pre-processing 
%       to improve the accuracy of the result. RGB images are converted to
%       grayscale using RGB2GRAY before they are processed.
%   2.  Accuracy is limited for very small radius values, e.g. Rmin <= 5.   
%   3.  The radius estimation step for Phase Coding method is typically
%       faster than that of the Two-Stage method.
%   4.  Both Phase Coding and Two-Stage methods in IMFINDCIRCLES are limited 
%       in their ability to detect concentric circles. The results for
%       concentric circles may vary based on the input image.
%   5.  IMFINDCIRCLES does not find circles with centers outside the image
%       domain.
%
%   Class Support
%   -------------
%   Input image A can be uint8, uint16, int16, double, single or logical,
%   and must be nonsparse. The output variables CENTERS, RADII, and METRIC
%   are of class double.
%
%   Example 1
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
%   Example 2
%   ---------
%   % Find both bright and dark circles in the image
%         I = imread('circlesBrightDark.png');
%         imshow(I)
% 
%         Rmin = 30;
%         Rmax = 65;
% 
%         % Find all the bright circles in the image
%         [centersBright, radiiBright] = imfindcircles(I,[Rmin Rmax], ...
%                                       'ObjectPolarity','bright');
% 
%         % Find all the dark circles in the image
%         [centersDark, radiiDark] = imfindcircles(I, [Rmin Rmax], ...
%                                       'ObjectPolarity','dark');
% 
%         % Plot bright circles in blue
%         viscircles(centersBright, radiiBright,'Color','b');
% 
%         % Plot dark circles in dashed red boundaries
%         viscircles(centersDark, radiiDark);
%

centers = [];
r_estimated = [];

%% Warn if the minimum radius is too small
if (radiusRange(1) <= 5)
    warning(message('images:imfindcircles:warnForSmallRadius', upper(mfilename)))
end

%% Compute the accumulator array
[accumMatrix, gradientImg] = computeaccumulator(A, radiusRange, 'Method','phasecode','ObjectPolarity', ...
                        'bright','EdgeThreshold',[]);

%% Check if the accumulator array is all-zero
if (~any(accumMatrix(:)))
    return;
end                    

%% Estimate the centers
accumThresh = 1 - sensitivity;
[centers, metric] = findcirclecenter(accumMatrix, accumThresh);

if (isempty(centers)) % If no centers are found, no further processing is necessary
    return;
end

%% Retain circles with metric value greater than threshold corresponding to AccumulatorThreshold 
idx2Keep = find(metric >= accumThresh);
centers = centers(idx2Keep,:);

if (isempty(centers)) % If no centers are retained, no further processing is necessary
    centers = []; % Make it 0x0 empty
    return;
end

%% Estimate radii
if (nargout > 1)
    if (length(radiusRange) == 1)
        r_estimated = repmat(radiusRange,size(centers,1),1);
    else
        r_estimated = phasecoding(centers, accumMatrix, radiusRange);                
    end    
end
end
