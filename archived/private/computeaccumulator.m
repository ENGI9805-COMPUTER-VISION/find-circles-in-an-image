function [accumMatrix, gradientImg] = computeaccumulator(A, radiusRange)
%CHACCUM Compute 2D accumulator array using Circular Hough Transform
%   H = CHACCUM(A, RADIUS) computes the 2D accumulator array H using
%   Circular Hough Transform for 2D grayscale input image A with the
%   specified radius. The size of H is the same as the input image A.
%
%   H = CHACCUM(A, RADIUS_RANGE) computes the composite accumulator array
%   with radii in the range specified by RADIUS_RANGE. RADIUS_RANGE is a
%   two-element vector [MIN_RADIUS MAX_RADIUS].
%

edgeThresh = [];

maxNumElemNHoodMat = 1e6; % Maximum number of elements in neighborhood matrix xc allowed, before memory chunking kicks in.


%% Get the input image in the correct format
A = getGrayImage(A);

%% Calculate gradient
[Gx,Gy,gradientImg] = imgradient(A);

%% Get edge pixels
[Ex, Ey] = getEdgePixels(gradientImg, edgeThresh);
idxE = sub2ind(size(gradientImg), Ey, Ex);

%% Identify different radii for votes
radiusRange = radiusRange(1):0.5:radiusRange(2);

RR = radiusRange;

%% Compute the weights for votes for different radii
lnR = log(radiusRange);
phi = ((lnR - lnR(1))/(lnR(end) - lnR(1))*2*pi) - pi; % Modified form of Log-coding from Eqn. 8 in [3]
Opca = exp(sqrt(-1)*phi);
w0 = Opca./(2*pi*radiusRange);

%% Computing the accumulator array

xcStep = floor(maxNumElemNHoodMat/length(RR));
lenE = length(Ex);
[M, N] = size(A);
accumMatrix = zeros(M,N);

for i = 1:xcStep:lenE
    Ex_chunk = Ex(i:min(i+xcStep-1,lenE));
    Ey_chunk = Ey(i:min(i+xcStep-1,lenE));
    idxE_chunk = idxE(i:min(i+xcStep-1,lenE));
    
    xc = bsxfun(@plus, Ex_chunk, bsxfun(@times, -RR, Gx(idxE_chunk)./gradientImg(idxE_chunk))); % Eqns. 10.3 & 10.4 from Machine Vision by E. R. Davies
    yc = bsxfun(@plus, Ey_chunk, bsxfun(@times, -RR, Gy(idxE_chunk)./gradientImg(idxE_chunk)));
    
    xc = round(xc);
    yc = round(yc);
    
    w = repmat(w0, size(xc, 1), 1);
    
    %% Determine which edge pixel votes are within the image domain
    % Record which candidate center positions are inside the image rectangle.
    [M, N] = size(A);
    inside = (xc >= 1) & (xc <= N) & (yc >= 1) & (yc < M);
    
    % Keep rows that have at least one candidate position inside the domain.
    rows_to_keep = any(inside, 2);
    xc = xc(rows_to_keep,:);
    yc = yc(rows_to_keep,:);
    w = w(rows_to_keep,:);
    inside = inside(rows_to_keep,:);
    
    %% Accumulate the votes in the parameter plane
    xc = xc(inside); yc = yc(inside);
    accumMatrix = accumMatrix + accumarray([yc(:), xc(:)], w(inside), [M, N]);
    clear xc yc w; % These are cleared to create memory space for the next loop. Otherwise out-of-memory at xc = bsxfun... in the next loop.
end

end

function [Gx, Gy, gradientImg] = imgradient(I)

hy = -fspecial('sobel');
hx = hy';

Gx = imfilter(I, hx, 'replicate','conv');
Gy = imfilter(I, hy, 'replicate','conv');

if nargout > 2
    gradientImg = hypot(Gx, Gy);
end
end


function [Ex, Ey] = getEdgePixels(gradientImg, edgeThresh)
Gmax = max(gradientImg(:));
if (isempty(edgeThresh))
    edgeThresh = graythresh(gradientImg/Gmax); % Default EdgeThreshold
end
t = Gmax * cast(edgeThresh,'like',gradientImg);
[Ey, Ex] = find(gradientImg > t);
end

function A = getGrayImage(A)

A = rgb2gray(A);
if (isinteger(A))
    A = im2single(A); % If A is an integer, cast it to floating-point
end

end
