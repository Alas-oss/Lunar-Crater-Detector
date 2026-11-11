cfg = projectConfig("moon");
S   = load(fullfile(cfg.modelDir, "unet_" + cfg.body + ".mat"));
net = S.net;

[imgDir, lblDir] = splitFolders(cfg, "test");
imgFiles = dir(fullfile(imgDir, "*.png"));
n = min(cfg.evalTiles, numel(imgFiles));

tp = 0; fp = 0; fn = 0;
for k = 1:n
    I = im2single(imread(fullfile(imgDir, imgFiles(k).name)));  I = I(:,:,1);
    T = imread(fullfile(lblDir, imgFiles(k).name)) > 0;
    C = semanticseg(I, net);
    P = (C == "crater");
    tp = tp + nnz(P & T);   fp = fp + nnz(P & ~T);   fn = fn + nnz(~P & T);
end
precision = tp / (tp + fp);  recall = tp / (tp + fn);
iou = tp / (tp + fp + fn);   f1 = 2*precision*recall / (precision + recall);
fprintf("Tiles scored: %d\n", n);
fprintf("Crater IoU %.3f | Precision %.3f | Recall %.3f | F1 %.3f\n", iou, precision, recall, f1);

if ~isfolder(cfg.resultsDir), mkdir(cfg.resultsDir); end
fig = figure("Visible", "off"); tiledlayout(4, 4, "TileSpacing", "compact");
for k = 1:4
    I = imread(fullfile(imgDir, imgFiles(k).name));
    T = imread(fullfile(lblDir, imgFiles(k).name)) > 0;
    C = semanticseg(im2single(I(:,:,1)), net);
    nexttile; imshow(I);                                                title("Input");
    nexttile; imshow(labeloverlay(I, T, Colormap=[1, 0, 0]));             title("Truth");
    nexttile; imshow(labeloverlay(I, C == "crater", Colormap=[0, 1, 0])); title("Prediction");
    nexttile; imshow(labeloverlay(I, (C=="crater") & ~T, Colormap=[1, 1, 0])); title("False pos.");
end
exportgraphics(fig, fullfile(cfg.resultsDir, "predictions.png"));
disp("Saved predictions.png in the results folder.");