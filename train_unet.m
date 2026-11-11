cfg = projectConfig("moon");
if ~isfolder(cfg.modelDir),      mkdir(cfg.modelDir);      end
if ~isfolder(cfg.checkpointDir), mkdir(cfg.checkpointDir); end
rng(0);

[dsTrain, dsVal] = makeDatastores(cfg);

wFile = fullfile(cfg.modelDir, "class_weights.mat");
if isfile(wFile)
    load(wFile, "classWeights");
else
    [~, lblDir] = splitFolders(cfg, "train");
    tbl  = countEachLabel(pixelLabelDatastore(lblDir, cfg.classNames, cfg.labelIDs));
    freq = tbl.PixelCount ./ tbl.ImagePixelCount;
    classWeights = median(freq) ./ freq;
    save(wFile, "classWeights");
end
fprintf("Class weights (background, crater): %s\n", mat2str(classWeights(:)', 4));

lgraph = buildUNet(cfg, classWeights);

options = trainingOptions("adam", ...
    InitialLearnRate     = cfg.learnRate, ...
    MaxEpochs            = cfg.maxEpochs, ...
    MiniBatchSize        = cfg.batchSize, ...
    Shuffle              = "every-epoch", ...
    ValidationData       = dsVal, ...
    ValidationFrequency  = 50, ...
    OutputNetwork        = "best-validation-loss", ...
    CheckpointPath       = cfg.checkpointDir, ...
    ExecutionEnvironment = "cpu", ...
    Plots                = "none", ...
    Verbose              = true);

net = trainNetwork(dsTrain, lgraph, options);
save(fullfile(cfg.modelDir, "unet_" + cfg.body + ".mat"), "net");
disp("Training finished and model saved.");