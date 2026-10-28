# ECOSTRESS Collection 2 JET test inputs: tile 11SPS, 2024-10-22

Inputs for one run of the ECOSTRESS Collection 2 L3T/L4T JET processor
(https://github.com/ECOSTRESS-Collection-2/ECOv002-L3T-L4T-JET, checked at main a785b14, PGE v1.13.1) on
orbit 35698, scene 014, tile 11SPS (Imperial Valley and Salton Sea, California), 2024-10-22 18:36 UTC,
the scene of the repository's own example. The official V002 products for this scene are on LP DAAC
(ECO_L3T_JET, ECO_L3T_MET, ECO_L3T_SEB, ECO_L3T_SM, ECO_L4T_ESI, ECO_L4T_WUE), so a run can be compared with
them. Release `ecostress-c2-jet-11sps-20241022`, made 2026-10-28.

## Files

| Archive | What it holds | Size (bytes) | sha256 |
|---|---|---|---|
| `ECOv002_L2T_LSTE_35698_014_11SPS_20241022T183627_0713_01.tar.gz` | the L2T LSTE granule folder: 8 GeoTIFFs and its `.json` metadata | 15,997,456 | `3f78b984f1ec68211b9f4bbee31acb72a9d78dfe5f68ea11841dfa2b31212baf` |
| `ECOv002_L2T_STARS_11SPS_20241022_0713_01.tar.gz` | the L2T STARS granule folder: 4 GeoTIFFs and its `.json` metadata | 17,933,529 | `5221f3858f4474c12dc18b028595f2cd9e919272040cb849b9f28679ce902e4a` |

Each archive unpacks to one folder named after the granule, and has a `.sha256` file next to it. They are
unchanged copies of the official LP DAAC V002 granules (Earthdata login at the source), found by granule name
in Earthdata Search or CMR.

## Static folder

Use the static windows from the release `ecostress-jet-11sps-20261002` in this repository
(`ecostress-jet-11SPS-static-windows.tar.gz`, see [../ecostress-jet/README.md](../ecostress-jet/README.md)).
The Collection 2 processor looks for the same folders and file names (`GEDI_download/Forest_height_2019.vrt`,
the two `SoilGrids_download` files and `MODISCI_download/global_clumping_index.tif`) under the run-config's
static folder, and the windows were made the same way for the same tile. Pass the unpacked
`L3T_L4T_static` folder itself as the static directory. If any of those files is missing, the code
downloads the global files instead (about 36 GB, and the clumping index through `wget` with an Earthdata
password on the command line).

## Running it

Write a run-config with the repository's `generate_L3T_L4T_JET_runconfig` (L2T LSTE folder, L2T STARS folder,
working directory, static directory) and pass it to `ECOv002-L3T-L4T-JET <runconfig.xml>`. The processor
downloads 12 GEOS-5 FP files itself (public, no login) from
https://portal.nccs.nasa.gov/datashare/gmao/geos-fp/das/Y2024/M10/D22/, and needs the GDAL command-line tools.

## What a run on these inputs shows

With these inputs and the 11SPS windows, the processor ran to exit code 0 in about 7 to 11 minutes (most of
it the GEOS-5 FP download), peak about 5 to 6 GiB, and wrote all six products. Against the official V002
granules (made by PGE v1.12.4) every layer has the same grid and no-data mask, and daily evapotranspiration
agrees to r = 0.999 (mean absolute difference 0.0056 mm/day); BESS reads about 8% high in the newer code.
