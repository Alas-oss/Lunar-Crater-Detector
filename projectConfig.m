function cfg = projectConfig(body)
% Central settings. To add a new planet, add a case below.
if nargin < 1, body = "moon"; end
cfg.body = lower(string(body));

root = fileparts(mfilename('fullpath'));
cfg.root = root;
dataRoot = getenv("CRATER_DATA");
if isempty(dataRoot), dataRoot = fullfile(root, "data"); end
cfg.rawDir     = fullfile(dataRoot, cfg.body, "raw");
cfg.tileDir    = fullfile(dataRoot, cfg.body, "tiles");
cfg.modelDir   = fullfile(root, "models", cfg.body);
cfg.resultsDir = fullfile(root, "results", cfg.body);

cfg.tileSize   = 256;
cfg.classNames = ["background" "crater"];
cfg.labelIDs   = [0 1];
cfg.rimThickenPx = 1;

% Training settings (small values for a first CPU run)
cfg.trainSubset   = 400;
cfg.valSubset     = 100;
cfg.evalTiles     = 100;
cfg.encoderDepth  = 3;
cfg.firstFilters  = 16;
cfg.batchSize     = 8;
cfg.maxEpochs     = 2;
cfg.learnRate     = 1e-3;
cfg.checkpointDir = fullfile(cfg.modelDir, "checkpoints");

switch cfg.body
    case "moon"
        cfg.dataset   = "DeepMoon (LRO/Kaguya DEM)";
        cfg.inputType = "DEM";
    case "mars"
        error("Mars not configured yet. Add dataset details in projectConfig.m");
    otherwise
        error("Unknown body: %s", body);
end
end