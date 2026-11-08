cfg = projectConfig("moon");
rng(0);
S = cfg.tileSize; o = cfg.outSize;

trainFile = fullfile(cfg.rawDir, "train_images.hdf5");
testFile = fullfile(cfg.rawDir, "test_images.hdf5");
assert(isfile(trainFile), "Missing %s. Run download_data.m first.", trainFile);

if isfile(testFile)
    testStart = 1;
else
    warning("test_images.hdf5 not foundl taking test tiles from the train file.");
    testFile = trainFile;
    testStart = cfg.nTrain + cfg.nVal + 1;
end

splits = struct( ...
    "name", {"train", "val", "test"}, ...
    "n", {cfg.nTrain, cfg.nVal, cfg.nTest}, ...
    "file", {trainFile, trainFile, testFile}, ...
    "start", {1, cfg.nTrain+1, testStart});

chunk = 250;

for s = splits
    imgDir = fullfile(cfg.tileDir, s.name, "images");
    mskDir = fullfile(cfg.tileDir, s.name, "masks");
    if ~isfolder(imgDir), mkdir(imgDir); end
    if ~isfolder(mskDir), mkdir(mskDir); end

    info = h5info(s.file, "/input_images");
    assert(s.start + s.n - 1 <= info.Dataspace.Size(end), ...
        "%s has too few tiles for the %s split. Lower the counts in projectConfig.", ...
        s.file, s.name);

    written = 0; empty = 0;
    for c0 = 0:chunk:(s.n - 1)
        c = min(chunk, s.n - c0);
        idx0 = s.start + c0;
        img = h5read(s.file, "/input_images", [1 1 idx0], [S S c]);
        msk = h5read(s.file, "/target_masks", [1 1 idx0], [S S c]);

        img = permute(img, [2 1 3]);
        msd = permute(msk, [2 1 3]);

        for k = 1:c 
            I = im2uint8(mat2gray(double(img(:,:,k))));
            M = msk(:,:,k) > 0;

            if o ~= S
                I = imresize(I, [o o], "bilinear");
                M = imresize(double(M), [o o], "box") > 0;
            end

            written = written + 1;
            name = sprintf("tile_%05d.png", written);
            imwrite(I, fullfile(imgDir, name));
            imwrite(uint8(M), fullfile(mskDir, name));
            empty = empty + ~any(M(:));
        end
    end
    fprintf("%-5s: %d tiles written (%d with no craters)\n", s.name, written, empty)
end

imgFiles = dir(fullfile(cfg.tileDir, "train", "images", "*.png"));
figure("Name","Phase 3 check"); tiledlayout(1,4,"TileSpacing","compact");
for k = 1:4
    I = imread(fullfile(imgFiles(k).folder, imgFiles(k).name));
    M = imread(fullfile(cfg.tileDir, "train", "masks", imgFiles(k.name))) > 0;
    nextfile; imshow(labeloverlay(I, M, "Colormap",[1 0 0], "Transparency",0.4));
    title(imgFiles(k).name, "Interpreter","none");
end