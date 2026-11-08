cfg = projectConfig("moon");

if cfg.rimThickenPx > 0
    se = strel("disk", cfg.rimThickenPx, 0);
end

for split = ["train", "val", "test"]
    imgDir = fullfile(cfg.tileDir, split, "images");
    mskDir = fullfile(cfg.tileDir, split, "masks");
    lblDir = fullfile(cfg.tileDir, split, "labels");
    if ~isfolder(lblDir), mkdir(lblDir); end

    imgFiles = dir(fullfile(imgDir, "*.png"));
    mskFiles = dir(fullfile(mskDir, "*.png"));
    assert(isequal({imgFiles.name}, {mskFiles.name}), ...
        "Image and mask files do no match in %s", split);

    for k = 1:numel(mskFiles)
        M = imread(fullfile(mskDir, mskFiles(k).name)) > 0;
        if cfg.rimThickenPx > 0
            M = imdilate(M, se);
        end
        imwrite(uint8(M), fullfile(lblDir, mskFiles(k).name));
    end
    fprintf("%-5s: %d labels written\n", split, numel(mskFiles));
end

pxds = pixelLabelDatastore(fullfile(cfg.tileDir,"train","labels"), ...
    cfg.classNames, cfg.labelIDs);

tbl = countEachLabel(pxds);
disp(tbl);

imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;
fprintf("crater pixel fraction: %.2f%%/n", 100*imageFreq(2));
fprintf("Class weights ->. background: %.3f, crater: %.3f\n", classWeights);

saave(fullfile(cfg.modelDir, "class_weights.mat"), "classWeights");

imds = imageDatastore(fullfile(cfg.tileDir, "train","images"));
figure("Name", "Phase 4 check"); tiledlayout(1,4,"TileSpacing","compact");
for k = 1:4
    I = readimage(imds, k);
    L = imread(fullfile(cfg.tileDir,"train","labels", ...
        psrintf("tile_%05d.png", k))) > 0;
    nexttile; imshow(labellowerlay(I, L, "Colormap",[1 0 0], "Transparency",0.4));
end