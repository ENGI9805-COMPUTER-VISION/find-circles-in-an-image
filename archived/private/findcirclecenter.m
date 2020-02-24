function [centers, metric] = findcirclecenter(accumMatrix, suppThreshold)
%CHCENTERS Find circle center locations from the Circular Hough Transform accumulator array 
%   CENTERS = CHCENTERS(H, SUPRESSIONTHRESH, SIGMA) finds all the potential
%   circle center locations from the accumulator array H. CENTERS is a
%   P-by-2 matrix, where P is the number of circles found from the
%   accumulator array. CENTERS holds the x- and y-coordinates of the
%   centers. If H is complex the magnitude is H is used for locating the
%   circle centers. 
% 
%   SUPRESSIONTHRESH  Non-negative scalar Q in the range [0 1], 
%                     specifies the threshold for supressing local peaks in
%                     the Circular Hough Transform accumulator array. Any
%                     local maxima in the accumulator array with h-maxima
%                     value values lower than SUPRESSIONTHRESH is rejected.
%                     Fewer circles are detected as the value of Q
%                     increases.

medFiltSize = 5; % Size of the median filter
 
centers = [];
metric = [];
%% Use the magnitude - Accumulator array can be complex. 
accumMatrix = abs(accumMatrix);

%% Pre-process the accumulator array
if (min(size(accumMatrix)) > medFiltSize)
    Hd = medfilt2(accumMatrix, [medFiltSize medFiltSize]); % Apply median filtering only if the image is big enough.
else
    Hd = accumMatrix;
end
suppThreshold = max(suppThreshold - eps(suppThreshold), 0);
Hd = imhmax(Hd, suppThreshold);
bw = imregionalmax(Hd);
s = regionprops(bw,accumMatrix,'weightedcentroid'); % Weighted centroids of detected peaks.

%% Sort the centers based on their accumulator array value
if (~isempty(s))
    centers = reshape(cell2mat(struct2cell(s)),2,length(s))';
    % Remove centers which are NaN.
    [rNaN, ~] = find(isnan(centers));
    centers(rNaN,:) = [];
    
    if(~isempty(centers))
        metric = Hd(sub2ind(size(Hd),round(centers(:,2)),round(centers(:,1))));
        % Sort the centers in descending order of metric
        [metric,sortIdx] = sort(metric,1,'descend');
        centers = centers(sortIdx,:);
    end
end

end
