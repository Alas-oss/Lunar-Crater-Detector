function M = craters2mask(craters, imgSize, rimWidth)

if istable(craters), craters = craters{:,1:3}; end
if nargin < 3, rimWidth = 1; end

H = imgSize(1); W = imgSize(2);
M = false(H, W);
for i = 1:size(craters,1)
    x = craters(i,1); y = craters(i,2); r = craters(i,3);
    pad = r + rimWidth;
    cols = max(1, floor(x-pad)) : min(W, ceil(x+pad));
    rows = max(1, floor(y-pad)) : min(H, ceil(y+pad));
    if isempty(cols) || isempty(rows), continue; end
    [X, Y] = meshgrid(cols, rows);
    ring = abs(hypot(X - x, Y - y) - r) <= rimWidth/2;
    M(rows, cols) = M(rows, cols) | ring;

end
end
