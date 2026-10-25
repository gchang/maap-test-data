# Test inputs for science algorithms

Small input files for checking that an algorithm builds and runs from start to finish, for cases where the author's own example is too long to run as a quick test or cannot be made without special access. Each dataset has its own folder with a README that says exactly how the file was made, what differs from the author's own example, and what a run on it shows. The data files themselves are attached to this repository's releases, one release per dataset, so the repository stays small.

| Dataset | Algorithm | Release | What it is |
|---|---|---|---|
| [cardamom](cardamom/README.md) | [CARDAMOM](https://github.com/CARDAMOM-framework/CARDAMOM) | `cardamom-demo-20k` | The author's demo input with the MCMC shortened from 500,000 to 20,000 iterations (about an hour instead of 16 to 20 hours) |
| [gedi-wsci-fusion](gedi-wsci-fusion/README.md) | [GEDI-WSCI-Fusion](https://github.com/tiagodc/GEDI-WSCI-Fusion) | `gedi-wsci-fusion-amapa-2021q3` | The 7-layer input stack for one 2474 tile window (Amapa, Brazil, 2021-Q3), rebuilt from public data as a stand-in for the Earth Engine export the repository documents |

These are generated or derived files, not official data products. Each README gives the license of the code or data it comes from.
