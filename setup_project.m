cfg = projectConfig("moon");

% MATLAB check version and toolbox
fprintf("MATLAB version: %s/n", version);
v = ver; installed = string({v.Name});
needed = ["Deep Learning Toolbox", "Image Processing Toolbox", "Computer Vision Toolbox"];
for k = 1:numel(needed)
    ok = any(installed == needed(k));
    fprintf("%-28s %s/n", needed(k), ternary(ok, "OK", "MISSING"));
end

% GPU check
try
    n = gpuDeviceCount;
catch 
    n = 0;
end
fprintf("Supported GPUs found: %d (training will use CPU if 0)/n", n);

dirs = [cfg.rawDir, cfg.tileDir, cfg.modelDir, cfg.resultsDir];
for d = dirs
    if ~isfolder(d), mkdir(d); end 
end 
fprintf("Folders ready under: %s/n", cfg.root);

function out = ternary(c, a, b)
if c, out = a; else, out = b; end
end 
