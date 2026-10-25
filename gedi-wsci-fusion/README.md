# GEDI WSCI Fusion test input: Amapá, Brazil, 2021 Q3

A small input stack for `wsci_fusion.py predict` (https://github.com/tiagodc/GEDI-WSCI-Fusion, tested at
`main` 53e2c25), built 2026-10-25. It holds layers 1 to 7 of the model input for one quarter over a
coastal forest and wetland area in Amapá, Brazil. The predict step adds layers 8 to 10 (coordinates)
itself.

**This is a public-data stand-in, not the Earth Engine export the repository documents.** The model was
trained on, and the official product was made from, Google Earth Engine exports (repository README,
"Input stack"). I do not have Earth Engine access, so I rebuilt the same seven layers from public,
anonymous sources with my own processing (`build_stack.py`, next to this folder). The values are close
to, but not the same as, what the Earth Engine export would give, so predictions from this stack match
the official product closely but not exactly (see "Check against the official product").

## Files

| File | Bands (in order) | Units | Size (bytes) | sha256 |
|---|---|---|---|---|
| `dem.tif` | 1 elevation | m | 3,700,492 | `156ef18fdc599dc0c2c0dfe50380d6b5dc9cb77a4460456c49562c223214c25b` |
| `palsar_2021.tif` | 2 HH, 3 HV, 4 local incidence angle | DN (uint16 values stored as float), degrees | 9,230,882 | `b2bffca164ce67defe0fe2a151c96a4f38170a57d658464948afab9e3f9fce56` |
| `s1_2021-07-01-to-2021-10-01.tif` | 5 VV, 6 VH, 7 ellipsoid incidence angle | sigma0 dB, degrees | 16,505,682 | `65c5a89ec93bec4835353b385b06922513da2abe00765b9baf286b170329706b` |

The archive `gedi-wsci-fusion-amapa-2021q3-inputs.tar.gz` holds the three files and this README in one
folder, `gedi-wsci-fusion-amapa-2021q3-inputs/`. Its own checksum is in
`gedi-wsci-fusion-amapa-2021q3-inputs.tar.gz.sha256`, published next to it.

All three files share one grid:

- **Area**: about 0.29 x 0.29 degrees, W -50.820028, S 0.379817, E -50.529872, N 0.670198 (requested
  as `--bbox -50.82 0.38 -50.53 0.67`, then snapped outward to the grid).
- **Quarter**: 2021 Q3, 2021-07-01 to 2021-10-01 (end date exclusive), paired with the 2021 PALSAR-2
  mosaic, as the repository's "Temporal pairing" rule says. 2021 is the latest year with a PALSAR-2
  mosaic on Planetary Computer.
- **Grid**: EPSG:4326, 1292 x 1293 px, pixel size 2.2457866777844e-4 degrees (about 25 m), aligned to the
  pixel lattice of the official ORNL DAAC product `GEDI_L4C_WSCI_Fusion_2474` (origin -51.000139789,
  1.000103751, read from tile `GEDI_L4C_WSCI_FUSION_00N051W_01N050W_20210701_20211001.tif`). So each
  pixel lines up one to one with the official tile.
- **Format**: GeoTIFF, float32, tiled, deflate, no-data NaN, band descriptions set. The model treats
  NaN as 0 (no data).
- **Coverage**: every layer is complete except VH, which is NaN on 6.9% of pixels (open sea, where the
  backscatter is below the noise floor). The DEM is about 0 m over the sea.
- **Value ranges** (median): elevation 9.4 m (-2.2 to 45.3), HH 5650 DN, HV 2693 DN, PALSAR-2 angle 31
  degrees (5 to 74), VV -8.65 dB, VH -14.62 dB, Sentinel-1 angle 39.8 degrees (38.6 to 40.9).

## Where each layer comes from, and what was done to it

| Layers | Repository's source (Earth Engine) | Source used here | Processing in `build_stack.py` |
|---|---|---|---|
| 1 | `COPERNICUS/DEM/GLO30` | Copernicus DEM GLO-30 Cloud Optimized GeoTIFFs on AWS Open Data (`copernicus-dem-30m` bucket, tile `Copernicus_DSM_COG_10_N00_00_W051_00_DEM`) | Range read, nearest neighbor onto the grid. Expected to be the same as the Earth Engine layer. |
| 2 to 4 | `JAXA/ALOS/PALSAR/YEARLY/SAR_EPOCH` (README: mosaic v2.5) | JAXA Global PALSAR-2 yearly mosaic on Microsoft Planetary Computer (`alos-palsar-mosaic`, 2021, tile `N01W051_21`, files `sl_HH`, `sl_HV`, `linci`; path `v200`) | Range read, nearest neighbor onto the grid, DN values kept as they are. Possibly a different mosaic version than v2.5. |
| 5 to 7 | `COPERNICUS/S1_GRD` (ESA SNAP: border noise removal, thermal noise removal, calibration, Range-Doppler terrain correction), mean of the quarter's ascending and descending scenes | Sentinel-1 IW GRD (dual pol VV+VH) Cloud Optimized GeoTIFFs and annotation XML on Microsoft Planetary Computer (`sentinel-1-grd`) | For each scene: read a window around the area; sigma0 calibration with the calibration LUT; thermal noise removal with the range and azimuth noise LUTs; incidence angle from the geolocation grid; geocoding with the GRD ground control points (thin-plate spline); bilinear onto the grid; then the mean of the dB values over all scenes (like an Earth Engine `ImageCollection.mean()`). |

Known differences from the Earth Engine layers, all in layers 5 to 7:

- No terrain correction. The area is 0 to 45 m above sea level and flat, so the effect should be small.
- No border noise removal.
- 11 scenes, all descending (relative orbit 68); there is no ascending coverage of this area in the
  quarter. ASF lists a 12th scene, `S1B_IW_GRDH_1SDV_20210804T090501_20210804T090521_028094_0359FD_0C0B`,
  which Planetary Computer does not have.
- Sea pixels below the noise floor are NaN in VH here.

Sentinel-1 scenes used (Planetary Computer item ids):

```
S1A_IW_GRDH_1SDV_20210705T090533_20210705T090558_038640_048F41
S1A_IW_GRDH_1SDV_20210717T090534_20210717T090559_038815_04947E
S1A_IW_GRDH_1SDV_20210729T090535_20210729T090600_038990_0499AF
S1A_IW_GRDH_1SDV_20210810T090535_20210810T090600_039165_049F6A
S1B_IW_GRDH_1SDV_20210816T090502_20210816T090522_028269_035F6D
S1A_IW_GRDH_1SDV_20210822T090536_20210822T090601_039340_04A56D
S1B_IW_GRDH_1SDV_20210828T090503_20210828T090522_028444_0364E1
S1A_IW_GRDH_1SDV_20210903T090537_20210903T090602_039515_04AB70
S1B_IW_GRDH_1SDV_20210909T090503_20210909T090523_028619_036A5B
S1B_IW_GRDH_1SDV_20210921T090504_20210921T090523_028794_036FB7
S1A_IW_GRDH_1SDV_20210927T090538_20210927T090603_039865_04B765
```

## How to rebuild it

`build_stack.py` needs Python with numpy and rasterio (the repository's `environment.yml` is enough) and
outbound HTTPS to `copernicus-dem-30m.s3.amazonaws.com`, `planetarycomputer.microsoft.com`
(STAC search and SAS tokens, no account needed), `pceo.blob.core.windows.net` and
`sentinel1euwest.blob.core.windows.net`. It reads only the parts of each file it needs.

```
python -I build_stack.py --bbox -50.82 0.38 -50.53 0.67 --year 2021 --quarter 3 --out-dir data
```

This took 4 min 40 s on 2 cores with 2.1 GB peak memory (most of it the 11 Sentinel-1 scenes). These
files come from a second build on 2026-10-25; it gave the same layer medians and the same check result
as the first build, whose files were not kept, so the bytes could not be compared. A rebuild is not
guaranteed to be byte-identical later: the providers can reprocess or add scenes, and GDAL or PROJ
versions can change resampling slightly. Compare against the sha256 values above.

## How to run predict on it

From the root of a clone of the repository (the default weights path is relative to the working
directory), with the three files in `../data`:

```
cd GEDI-WSCI-Fusion
python wsci_fusion.py predict -i ../data/dem.tif ../data/palsar_2021.tif ../data/s1_2021-07-01-to-2021-10-01.tif -o ../out/wsci_2021Q3.tif
```

The order of `-i` matters: the bands are stacked in the order given (DEM, PALSAR-2, Sentinel-1). No
network is needed. On CPU with 2 cores it took 3 min 49 s and 2.36 GB peak memory, and printed one
block line and `## wrote ../out/wsci_2021Q3.tif`, exit status 0. The output is a 4-band float32
GeoTIFF (mean WSCI, aleatoric std, epistemic std, fraction of valid predictors), no-data -9999; the
outer 40 px are empty by design.

Environment used: Python 3.14.9, PyTorch 2.14.1 (CPU), numpy 2.5.4, rasterio 1.5.2 (GDAL 3.13.3), all
from conda-forge through `environment.yml`.

## Check against the official product

`compare_official.py` (next to this folder) reads the official tile
`GEDI_L4C_WSCI_FUSION_00N051W_01N050W_20210701_20211001.tif` (ORNL DAAC, DOI 10.3334/ORNLDAAC/2474,
Earthdata login needed) onto the same grid and compares the pixels valid in both (1,366,097; the
official product also masks water).

| Band | Ours mean | Official mean | Bias | RMSE | r | Within 0.25 / 0.5 |
|---|---|---|---|---|---|---|
| mean WSCI | 9.056 | 9.080 | -0.024 | 0.233 | 0.976 | 79.4% / 94.9% |
| aleatoric std | 0.568 | 0.526 | +0.043 | 0.093 | 0.875 | 97.7% / 100% |
| epistemic std | 0.101 | 0.088 | +0.014 | 0.073 | 0.396 | 99.2% / 99.9% |
| valid fraction | 1.000 | 0.998 | +0.002 | 0.026 | 0.411 | 99.3% / 100% |

This matches the first test of 2026-10-25 (r 0.976, RMSE 0.233, bias -0.024 for mean WSCI).

`predict` uses Monte Carlo dropout and sets no random seed, so two runs on the same stack differ a
little: in our tests by RMSE 0.060 and r 0.998 for mean WSCI (the repository README reports 0.066 and
0.998). Bands 2 to 4 may therefore differ in the third decimal from the table above, and outputs are
not byte-identical between runs; `--no-mc` gives deterministic means but no epistemic band. The rest
of the difference (RMSE about 0.23 against the authors' 0.075 with their Earth Engine stack) comes from
these stand-in inputs, not from the code. Expect r near 0.976 and RMSE near 0.23 for mean WSCI.

## Licenses and terms of the source data

These files are derived from the three datasets below. Anyone redistributing them should keep this
section with them. (Checked 2026-10-25 from the providers' pages; I am not a lawyer, so read the linked
terms before relying on this.)

- **Copernicus DEM GLO-30** (layer 1): free license for the general public worldwide, under the ESA
  user license for the Copernicus DEM
  (https://dataspace.copernicus.eu/explore-data/data-collections/copernicus-contributing-missions/collections-description/COP-DEM;
  AWS Open Data registry: https://registry.opendata.aws/copernicus-dem/). Because the data were
  resampled here, the notice for modified data applies: "produced using Copernicus WorldDEM-30 © DLR
  e.V. 2010-2014 and © Airbus Defence and Space GmbH 2014-2018 provided under COPERNICUS by the European
  Union and ESA; all rights reserved".
- **JAXA Global PALSAR-2/PALSAR yearly mosaic** (layers 2 to 4): free of charge under JAXA's "Terms of
  Use of Research Data" (https://earth.jaxa.jp/policy/en.html, the license link in Planetary
  Computer's `alos-palsar-mosaic` collection). JAXA retains ownership, publications must acknowledge
  it, and images must show "©JAXA". Credit: "JAXA Global PALSAR-2/PALSAR/JERS-1 Mosaic" (©JAXA).
  *Uncertain*: I could not load the terms page itself on 2026-10-25, and the pages I could read do not
  say whether redistributing derived rasters like this one is allowed. Confirm that before hosting
  these files publicly.
- **Copernicus Sentinel-1** (layers 5 to 7): Copernicus Sentinel data are free, full and open under
  the Sentinel data legal notice
  (https://sentinel.esa.int/documents/247904/690755/Sentinel_Data_Legal_Notice, the license link in
  Planetary Computer's `sentinel-1-grd` collection), which allows reproduction, distribution,
  adaptation and modification. Credit for processed data: "Contains modified Copernicus Sentinel data
  2021". (The notice page did not resolve from here on 2026-10-25; this is its long-standing wording.)

The model, weights and code are the repository's (MIT license, Copyright 2026 University of Maryland);
this folder holds only input data.
