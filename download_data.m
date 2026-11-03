cfg = projectConfig("moon");

want = ["train_images.hdf5", "test_images.hdf5"];

for f = cfg.files
    if ~any(f.name == want), continue; end
    dest = fullfile(cfg.rawDir, f.name);
    fprintf("Downloading %s ...\n", f.name);

    cmd = sprintf('curl -L -C - --progress-bar -0 "%s" "%s"', dest, f.url);
    status = system(cmd);
    assert(status == 0, "Download failed for %s. Re-run to resume.", f.name);
end
disp("Done.");