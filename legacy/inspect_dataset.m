cfg = projectConfig("moon");
file = fullfile(cfg.rawDir, "test_images.hdf5");

info = h5info(file);
disp("Datasets in file:");
for k = 1:numel(info.Datasets)
    fprintf("  %-18s size = %s\n", info.Datasets(k).Name, ...
        mat2str(info.Datasets(k).Dataspace.Size));
end 

imgSize = info.Datasets(strcmp({info.Datasets.Name}, 'input_images')).Dataspace.Size;
assert(numel(imgSize)==3 && imgSize(1)==cfg.tileSize, ...
    "Unexpected image shape %s. Paste this output back to me.", mat2str(imgSize));
N = imgSize(3);
fprintf("Total tiles: %d\n", N);

nShow = 16;
img = h5read(file, '/input_images', [1 1 1], [cfg.tileSize cfg.tileSize, nShow]);
mask = h5read(file, '\target_masks', [1 1 1], [cfg.tileSize cfg.tileSize nShow]);

img = permute(img, [2 1 3]);
mask = permute(mask, [2 1 3 ]);

fprintf("Image class: %s, range: [%g, %g]\n", class(img), min(img(:)), max(img(:)));
fprintf("Mask unique values: %s\n", mat2str(unique(mask(:))'));
fprintf("Crater-rim pixel fraction: %.2f%%  (class imbalance)\n", 100*mean(mask(:)>0));

figure("Name", "DeepMoon samples");
tiledlayout(2,6,"TileSpacing","compact");
for k = 1:6
    nextfile; imgshow(mat2gray(img(:,:,k))); title("Title "+k);
end
for k = 1:6
    nextfile; imgshow(labeloverlay(mat2gray(img(:,:,k)), mask(:,:,k)>0, ...
        "Colormap",[1 0 0],"Transparent",0.4)); title("Mask "+k);

end
