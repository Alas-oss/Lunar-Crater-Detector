cfg = projectConfig("moon");
badSplit = strings(0);  badName = strings(0);
for s = ["train" "val" "test"]
    imgFiles = dir(fullfile(cfg.tileDir, s, "images", "*.png"));
    for k = 1:numel(imgFiles)
        nm = string(imgFiles(k).name);
        ok = false;
        try
            I = imread(fullfile(cfg.tileDir, s, "images", nm));
            M = imread(fullfile(cfg.tileDir, s, "masks",  nm));
            ok = isequal(size(I,[1 2]), [cfg.tileSize cfg.tileSize]) && ...
                 isequal(size(M,[1 2]), [cfg.tileSize cfg.tileSize]);
        catch
        end
        if ~ok
            badSplit(end+1) = s;  badName(end+1) = nm; %#ok<SAGROW>
        end
    end
end
fprintf("Bad tile pairs: %d\n", numel(badName));
if numel(badName) > 50
    disp("More than 50 bad pairs: nothing deleted. Tell me before continuing.");
elseif numel(badName) > 0
    for k = 1:numel(badName)
        delete(fullfile(cfg.tileDir, badSplit(k), "images", badName(k)));
        delete(fullfile(cfg.tileDir, badSplit(k), "masks",  badName(k)));
        fprintf("Removed %s/%s\n", badSplit(k), badName(k));
    end
end