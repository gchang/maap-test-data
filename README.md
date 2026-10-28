# Test inputs for science algorithms

Small input files for checking that an algorithm builds and runs from start to finish, for cases where the author's own example is too long to run as a quick test or cannot be made without special access. Each dataset has its own folder with a README that says exactly how the file was made, what differs from the author's own example, and what a run on it shows. The data files themselves are attached to this repository's releases, one release per dataset, so the repository stays small.

| Dataset | Algorithm | Release | What it is |
|---|---|---|---|
| [cardamom](cardamom/README.md) | [CARDAMOM](https://github.com/CARDAMOM-framework/CARDAMOM) | `cardamom-demo-20k` | The author's demo input with the MCMC shortened from 500,000 to 20,000 iterations (about an hour instead of 16 to 20 hours) |
| [gedi-wsci-fusion](gedi-wsci-fusion/README.md) | [GEDI-WSCI-Fusion](https://github.com/tiagodc/GEDI-WSCI-Fusion) | `gedi-wsci-fusion-amapa-2021q3` | The 7-layer input stack for one 2474 tile window (Amapa, Brazil, 2021-Q3), rebuilt from public data as a stand-in for the Earth Engine export the repository documents |
| [ecostress-jet](ecostress-jet/README.md) | [ECOv003-L3T-L4T-JET](https://github.com/ECOSTRESS-Collection-3/ECOv003-L3T-L4T-JET) | `ecostress-jet-11sps-20261002` | The L2T LSTE and STARS input granules for one scene (tile 11SPS, 2026-10-02) and the static maps cut to that tile, so a run needs no 36 GB of global downloads |
| [ecostress-c2-jet](ecostress-c2-jet/README.md) | [ECOv002-L3T-L4T-JET](https://github.com/ECOSTRESS-Collection-2/ECOv002-L3T-L4T-JET) | `ecostress-c2-jet-11sps-20241022` | The Collection 2 L2T LSTE and STARS input granules for the repository's example scene (tile 11SPS, 2024-10-22); use with the static windows of `ecostress-jet-11sps-20261002` |
| [lisf](lisf/README.md) | [LISF](https://github.com/NASA-LIS/LISF) | `lisf-step2-20170101-20170103` | Step 2 of the LISF public testcase (Noah-3.6 open loop on the southern Great Plains domain) cut to 2017-01-01 to 2017-01-03, with the step 1 parameter file and 50 NLDAS-2 hourly forcing files, so a run takes seconds and needs no network |

These are generated or derived files, not official data products. Each README gives the license of the code or data it comes from.
