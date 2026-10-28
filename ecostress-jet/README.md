# ECOSTRESS JET test inputs: tile 11SPS, 2026-10-02

Inputs for one run of the ECOSTRESS Collection 3 L3T/L4T JET processor
(https://github.com/ECOSTRESS-Collection-3/ECOv003-L3T-L4T-JET, checked at v1.18.0) on orbit 46739,
scene 001, tile 11SPS (Imperial Valley and Salton Sea, California), 2026-10-02 17:33 UTC. The official
V003 products for this scene are on LP DAAC, so a run can be compared with them. Release
`ecostress-jet-11sps-20261002`, made 2026-10-28.

## Files

| Archive | What it holds | Size (bytes) | sha256 |
|---|---|---|---|
| `ecostress-jet-11SPS-static-windows.tar.gz` | `L3T_L4T_static/` with the static maps cut to a window around the tile | 494,595 | `2c3cbd31e98243182bf967fb20daf5632f3c622a8aa5a54af6ac59574323e79b` |
| `ECOv003_L2T_LSTE_46739_001_11SPS_20261002T173304_02.tar.gz` | the L2T LSTE granule folder: 19 GeoTIFFs and its `.json` metadata | 83,651,924 | `82a94ec77fd32937d99f2096c221cea98a9f9c2dd88776e07997dc02be907303` |
| `ECOv003_L2T_STARS_11SPS_20261002_02.tar.gz` | the L2T STARS granule folder: 10 GeoTIFFs and its `.json` metadata | 32,851,259 | `3acb6f2280d8eddfc4030159371eb16190f3c47affd6dfdc341216b7dd11f5ad` |

Each archive unpacks to one folder. Each has a `.sha256` file next to it.

## The static folder

The run-config's static folder (`StaticAncillaryFileGroup`, `L3T_L4T_STATIC`) must hold these files. Any
file missing there, the code downloads whole and global: about 32 GB of forest height, 3.8 GB of
SoilGrids and the global clumping index, which needs an Earthdata login. Folder and file names are the
ones the code looks for:

```
L3T_L4T_static/
  GEDI_download/Forest_height_2019.vrt                  (points to the window next to it)
  GEDI_download/Forest_height_2019_NAM_11SPS_window.tif
  SoilGrids_download/sol_watercontent.33kPa_usda.4b1c_m_250m_b0..0cm_1950..2017_v0.1.tif
  SoilGrids_download/sol_watercontent.1500kPa_usda.3c2a1a_m_250m_b0..0cm_1950..2017_v0.1.tif
  MODISCI_download/global_clumping_index.tif
```

The code only checks that each file exists, and an existing forest height VRT is used as is. The
windows cover lon -116.05 to -114.65, lat 32.30 to 33.55 (tile 11SPS plus about 0.1 degree), so they
serve **this tile only**. They were cut with `stage_static.sh` (in this folder) using GDAL `/vsicurl/`
from the same public files the code downloads, keeping each source's grid and values:

- Forest canopy height 2019, North America region: https://glad.geog.umd.edu/Potapov/Forest_height_2019/Forest_height_2019_NAM.tif
  (Potapov et al. 2021, Remote Sensing of Environment 253, 112165; UMD GLAD).
- SoilGrids field capacity (33 kPa) and wilting point (1500 kPa), 0 cm: https://zenodo.org/record/2784001
  (Hengl and Gupta 2019; license as stated on the Zenodo record).
- MODIS global clumping index: https://daac.ornl.gov/daacdata/global_vegetation/Global_Clumping_Index/data/global_clumping_index.tif
  (He et al. 2012; ORNL DAAC, doi:10.3334/ORNLDAAC/1531).

## The L2T granules

Unchanged copies of the official LP DAAC V003 granules, one folder per granule as the run-config
generator expects:

- ECO_L2T_LSTE.003 `ECOv003_L2T_LSTE_46739_001_11SPS_20261002T173304_02`
- ECO_L2T_STARS.003 `ECOv003_L2T_STARS_11SPS_20261002_02`

Both are from https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/ (Earthdata login), found by
granule name in Earthdata Search or CMR. The `.json` file in each folder is required: the processor reads
the STARS granule's metadata from it. The CMR-STAC items for these granules list the GeoTIFFs and
browse images but not the `.json`, so a folder built from a STAC item alone is not enough.

## Running it

```
generate_L3T_L4T_JET_runconfig(L2T_LSTE_filename=<LSTE folder>, L2T_STARS_filename=<STARS folder>,
                               working_directory=<work>, static_directory=<.../L3T_L4T_static>)
ECOv003-L3T-L4T-JET <runconfig.xml>
```

The processor downloads 12 GEOS-5 FP files itself (about 0.9 GB, public, no login) from
https://portal.nccs.nasa.gov/datashare/gmao/geos-fp/das/Y2026/M10/D02/. It also needs the GDAL
command-line tools.

## What a run on these inputs shows

With these inputs and windows made the same way, v1.18.0 ran to exit code 0 on 4 cores in about
10 minutes, peak 5.6 GiB, and wrote L3T JET, L3T ETAUX, L4T ESI and L4T WUE. Against the official V003
granules for the scene (made by v1.13.0), all 29 layers have the same grid and no-data mask, and daily
evapotranspiration agrees to r = 0.999997 (mean absolute difference 0.0011 mm/day). The archives above
were rebuilt on 2026-10-28 with the same script and sources; that rebuild was not rerun through the
processor.
