#!/bin/bash
# Pre-stage the static ancillary data the JET PGE opens, cut to a window around
# Sentinel-2 tile 11SPS, under the exact file names and folders the code looks for,
# so the PGE finds them locally and never downloads the global files.
#
# usage: retry_stage_static.sh STATIC_DIR
#   STATIC_DIR is the run-config's StaticAncillaryFileGroup/L3T_L4T_STATIC folder.
#
# Folder and file names come from the code (C3: JET3/constants.py:28-31 via L3TL4TJETConfig.py:120-123;
# copied unchanged from verification/ecostress-c2-jet/retry_stage_static.sh):
#   GEDI_download/Forest_height_2019.vrt   gedi_canopy_height.py, GEDICanopyHeight.VRT: an existing
#                                          VRT that gdalinfo accepts is used as is
#   SoilGrids_download/<Zenodo basename>   soil_capacity_wilting.py, SoilGrids.FC/WP: only checks exists()
#   MODISCI_download/global_clumping_index.tif  MODISCI.py, MODISCI.download: only checks exists()
# Reads use the same public URLs the code would download, through GDAL /vsicurl/.
set -euo pipefail
static=$1
# Tile 11SPS (UTM 11N 600000..709760 E, 3590260..3700020 N) is lon -115.93..-114.75,
# lat 32.42..33.44. Pad by about 0.1 degree for resampling kernels.
W=-116.05; N=33.55; E=-114.65; S=32.30
win=(-projwin $W $N $E $S -projwin_srs EPSG:4326)
co=(-co TILED=YES -co COMPRESS=DEFLATE -co BIGTIFF=IF_SAFER)
export GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR CPL_VSIL_CURL_ALLOWED_EXTENSIONS=.tif \
       GDAL_HTTP_COOKIEFILE="$static/.gdal_cookies" GDAL_HTTP_COOKIEJAR="$static/.gdal_cookies" \
       GDAL_HTTP_MAX_RETRY=5 GDAL_HTTP_RETRY_DELAY=5

# 1. GEDI / GLAD 2019 forest canopy height. Only the NAM region covers this tile.
mkdir -p "$static/GEDI_download"
gdal_translate -q "${win[@]}" "${co[@]}" \
  /vsicurl/https://glad.geog.umd.edu/Potapov/Forest_height_2019/Forest_height_2019_NAM.tif \
  "$static/GEDI_download/Forest_height_2019_NAM_11SPS_window.tif"
(cd "$static/GEDI_download" && gdalbuildvrt -q Forest_height_2019.vrt Forest_height_2019_NAM_11SPS_window.tif)

# 2. SoilGrids field capacity (33 kPa) and wilting point (1500 kPa), Zenodo record 2784001.
mkdir -p "$static/SoilGrids_download"
for f in sol_watercontent.33kPa_usda.4b1c_m_250m_b0..0cm_1950..2017_v0.1.tif \
         sol_watercontent.1500kPa_usda.3c2a1a_m_250m_b0..0cm_1950..2017_v0.1.tif; do
  gdal_translate -q "${win[@]}" "${co[@]}" \
    "/vsicurl/https://zenodo.org/record/2784001/files/$f" "$static/SoilGrids_download/$f"
done

# 3. MODIS global clumping index, ORNL DAAC (Earthdata login via ~/.netrc, read by GDAL).
# This file is in MODIS sinusoidal, where a lat/lon box is not a rectangle, so the native
# window is computed from the box corners that give the extreme x and y (west edge at the
# south latitude, east edge at the north latitude).
mkdir -p "$static/MODISCI_download"
CI=/vsicurl/https://daac.ornl.gov/daacdata/global_vegetation/Global_Clumping_Index/data/global_clumping_index.tif
read -r cx0 cy0 cx1 cy1 < <(python -I -c "
from pyproj import Transformer
t = Transformer.from_crs('EPSG:4326', '+proj=sinu +R=6371007.181 +units=m', always_xy=True)
xs, ys = zip(*[t.transform(lo, la) for lo in ($W, $E) for la in ($S, $N)])
print(min(xs), max(ys), max(xs), min(ys))")
gdal_translate -q -projwin $cx0 $cy0 $cx1 $cy1 "${co[@]}" "$CI" \
  "$static/MODISCI_download/global_clumping_index.tif"
rm -f "$static/.gdal_cookies"

du -sh "$static"/*
