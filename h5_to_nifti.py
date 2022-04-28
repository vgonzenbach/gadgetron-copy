import nibabel as nib
import numpy as np
import h5py
import os
import sys
from pathlib import Path
# import itertools

reference_img = nib.load(sys.argv[2])
f = h5py.File(sys.argv[1], "r")
for key in f.keys():
    group = f[key]
    for k in group.keys():
        for v in group[k].values():
            if os.path.basename(v.name) == 'data':
                # dest = np.array([])
                # v.read_direct(dest)
                # print(dest)
                #print(np.shape(v.value))
                reshaped = v[0, 0, :, :]
                #print(np.shape(reshaped))
                reordered = np.transpose(reshaped, axes=(0,1,2))
                flipped = np.flip(reordered, axis=2)
                out = nib.Nifti1Image(flipped, affine=reference_img.affine, header=reference_img.header.copy())
                fn = sys.argv[3]
                out.to_filename(fn)
                # order of dimensions to try
                # for order in itertools.permutations([0,1,2]):
                #     # range(3), range(3), range(3) are which dimensions to reverse
                #     for dims2rev in [np.unique(item, axis=0) for item in itertools.product(range(3), range(3), range(3))]:
                #     #itertools.product(range(3), range(3), range(3)):
                #         reordered = np.transpose(reshaped, axes=order)
                #         print(np.shape(reordered))
                #         flipped = np.flip(reordered, axis=np.unique(dims2rev))
                #         out = nib.Nifti1Image(flipped, affine=reference_img.affine, header=reference_img.header.copy())
                #         # out = nib.Nifti1Image(reshaped, None, header=reference_img.header.copy())
                #         fn = str(order).replace(" ", "")+"-"+str(dims2rev).replace(" ", "")+'.nii.gz'
                #         out.to_filename('./tries/' + fn)
                #         print(fn, reference_img.header == out.header)
# "(0,1,2)-[2].nii.gz" is the one
