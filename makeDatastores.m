function [dsTrain, dsVal] = makeDatastores(cfg)
dsTrain = buildSplit(cfg, "train", cfg.trainSubset, true);
dsVal   = buildSplit(cfg, "val",   cfg.valSubset,   false);
end

function ds = buildSplit(cfg, split, nWanted, augment)
[imgDir, lblDir] = splitFolders(cfg, split);
imds = imageDatastore(imgDir);
pxds = pixelLabelDatastore(lblDir, cfg.classNames, cfg.labelIDs);
assert(numel(imds.Files) == numel(pxds.Files), ...
    "Image and label counts differ in %s", split);

n = numel(imds.Files);
if nWanted < n
    rng(0);
    idx  = sort(randperm(n, nWanted));
    imds = subset(imds, idx);
    pxds = subset(pxds, idx);
end

ds = combine(imds, pxds);
if augment
    ds = transform(ds, @augmentPair);
else
    ds = transform(ds, @preparePair);
end
end

function out = preparePair(data)
out = {im2single(data{1}(:,:,1)), data{2}};
end

function out = augmentPair(data)
img = im2single(data{1}(:,:,1));
lbl = data{2};
if rand > 0.5, img = fliplr(img); lbl = fliplr(lbl); end
if rand > 0.5, img = flipud(img); lbl = flipud(lbl); end
k = randi(4) - 1;
img = rot90(img, k);  lbl = rot90(lbl, k);
out = {img, lbl};
end