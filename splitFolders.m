function [imgDir, lblDir] = splitFolders(cfg, split)
imgDir = fullfile(cfg.tileDir, split, "images");
lblDir = fullfile(cfg.tileDir, split, "labels");
if isempty(dir(fullfile(lblDir, "*.png")))
    lblDir = fullfile(cfg.tileDir, split, "masks");
end
end