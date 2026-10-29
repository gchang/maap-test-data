# OPERA tropo: HRES sample trimmed to the model inputs

Input for one quick run of OPERA's tropospheric zenith delay software (https://github.com/opera-adt/tropo; checked with https://github.com/gchang/opera-tropo at tag `v1.0.0.post1`). Release `opera-tropo-hres-sample-20240215T12`, made 2026-10-29.

## File

| File | What it holds | Size (bytes) | sha256 |
|---|---|---|---|
| `opera-tropo-hres-sample-20240215T12-zqtlnsp.nc` | ECMWF HRES model-level fields `z`, `t`, `q`, `lnsp` for 2024-02-15 12:00 UTC, 137 levels, 25.06 to 34.97 N, 80.02 to 90.00 E (142 x 143 cells, the Ganges plain to Tibet) | 4,517,120 | `31714c6587039f2b9ab1628ecbd7b10121c9b6e569f80a480b660515782a1043` |

The file has a `.sha256` file next to it.

## How it was made

It is the repository's test fixture `tests/data/test_dataset.nc` at tag `v1.0.0` (42,735,191 bytes, sha256 `49babf832ced543254d1cf1a05c6107f09e9d82555697947b646415b1f2579d1`) with only the four raw model fields kept:

```
import xarray as xr
xr.open_dataset("test_dataset.nc")[["z", "t", "q", "lnsp"]].to_netcdf("out.nc", engine="h5netcdf")
```

The fixture also holds intermediate fields (`p`, `geop`, `ght`, `hgt`, `e`), and `opera_tropo` accepts an input only when its variables are exactly `z`, `t`, `q` and `lnsp` (`checks.check_coords_and_variables`), as real HRES inputs are. Values are not changed.

## Running it

```
opera_tropo config -i opera-tropo-hres-sample-20240215T12-zqtlnsp.nc -o output -c $PWD/runconfig.yaml
opera_tropo run $PWD/runconfig.yaml
```

Give `-c` an absolute path: a relative one stops in `cli/config.py`.

## What a run on it shows

From a fresh clone of https://github.com/gchang/opera-tropo at tag `v1.0.0.post1`, with the environment from its `conda-env.yml` (101 s) and `pip install --no-deps -e .`, on 4 cores with no other inputs: `opera_tropo config` exit 0, `opera_tropo run` exit 0 in 10.5 s at 0.44 GB peak, writing one `OPERA_L4_TROPO-ZENITH_20240215T120000Z_<production time>_HRES_v1.0.nc` (5.1 MB) with `wet_delay` and `hydrostatic_delay` (2026-10-29). An earlier run on the same trimmed input matched the official ASF granule `OPERA_L4_TROPO-ZENITH_20240215T120000Z_20250924T034559Z_HRES_v1.0` (CMR `G3758130453-ASF`) over this box to within 1.3 mm, with 98.6% of wet and 99.2% of hydrostatic delay cells identical.

## Sources and license

The fixture comes from the opera-adt/tropo repository (Apache License 2.0; JPL/Caltech). The data are ECMWF HRES forecast fields as distributed in that repository's test data.
