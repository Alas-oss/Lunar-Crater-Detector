function cfg = projcectConfig(body)

if nargin < 1, body = "moon"; end
cfg.body = lower(string(body));

root = fileparts(mfilename('fullpath'));
cfg.root = root;
cfg.rawDir = fullfile(root, "data", cfg.body, "raw");
cfg.tileDir = fullfile(root, "data", cfg.body, "tiles");
cfg.modelDir = fullfile(root, "models", cfg.body);
cfg.resultsDit = fullfile(root, "results", cfg.body);

cfg.tileSize = 256;
cfg.classNames = ["background", "crater"];
cfg.labelIDs = [0 1];

switch cfg.body
    case "moon"
        cfg.dataset = "DeepMoon (LRO/Kaguya DEM)";
        cfg.inputType - "DEM";
        base = "https://zenodo.org/record/1133969/files/";
        cfg.files = struct( ...
            "name", {"dev_images.hdf5","train_images.hdf5","test_images.hdf5"}, ...
            "url",  {base+"dev_images.hdf5?download=1", ...
                     base+"train_images.hdf5?download=1", ...
                     base+"test_images.hdf5?download=1"});
    case "mars"
        % placeholder for future datasets
        error("Mars not configured yet. Add dataset details in projectConfig.m")
    otherwise 
        error("Unknown body: %s", body);
    
end 
end