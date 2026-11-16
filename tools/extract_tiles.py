import os
import h5py 
import numpy as np
from PIL import Image

N_TRAIN, N_VAL, N_TEST = 3000, 500, 500
OUT = "/content/tiles"
splits = [("train", "/content/raw/train_images.hdf5", 0, N_TRAIN),
          ("val", "/content/raw/train_images.hdf5", N_TRAIN, N_VAL),
          ("test", "/content/raw/test_images.hdf5", 0, N_TEST)]
CHUNK = 250

for name, path, start, n in splits:
    os.makedirs(f"{OUT}/{name}/images", exist_ok=True)
    os.makedirs(f"{OUT}/{name}/masks", exist_ok=True)
    with h5py.File(path, "r") as f:
        X, Y = f["input_images"], f["target_masks"]
        assert X.shape[1:] == (256, 256), f"Unexpected shape {X.shape}"
        assert X.shape[0] >= start + n, "Not enough tiles; lower the counts"
        count = empty = 0
        for c0 in range(0, n, CHUNK):
            c = min(CHUNK, n - c0)
            imgs = X[start + c0 : start + c0 + c]
            msks = Y[start + c0 : start + c0 + c]
            for k in range(c):
                im = imgs[k].astype(np.float64)
                lo, hi = im.min(), im.max()
                im = (im - lo) / (hi - lo) if hi > lo else np.zeros_like(im)
                I = np.round(255 * im).astype(np.uint8)
                M = (msks[k] > 0).astype(np.uint8)
                count += 1
                fn = f"tile_{count:05d}.png"
                Image.fromarray(I).save(f"{OUT}/{name}/images/{fn}")
                Image.fromarray(M).save(f"{OUT}/{name}/masks/{fn}")
                empty += int(M.sum() == 0)
        print(f"{name}: {count} tiles written ({empty} with no craters)")