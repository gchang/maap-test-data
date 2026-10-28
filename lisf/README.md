# LISF public testcase step 2 (Noah-3.6 open loop): 2017-01-01 to 2017-01-03

Inputs for one short run of NASA LIS (https://github.com/NASA-LIS/LISF; checked with the build of
https://github.com/gchang/lisf at tag `lisf-public-7.8-f2b68e6.post1`, upstream `support/lisf-public-7.8` at
`f2b68e62`) with the Noah-3.6 land surface model in open loop, on the public testcase domain (0.25 degree,
28 x 22 cells, 34.4 to 39.6 N, 102.9 to 96.1 W, the southern Great Plains). It is step 2 of the LISF public
testcase walkthrough (`docs/public_testcase_walkthrough`, rev 3.0), cut from one year to 2017-01-01 00Z to
2017-01-03 00Z, so the run takes seconds and the walkthrough's own target outputs can be compared for the
same times. Release `lisf-step2-20170101-20170103`, made 2026-10-28.

## Files

| Archive | What it holds | Size (bytes) | sha256 |
|---|---|---|---|
| `lisf-testcase-step2-20170101-20170103.tar.gz` | one folder of the same name: `lis.config.short`, `README.txt` and `INPUT/` (parameter file, Noah-3.6 tables, output and forcing lists, 50 NLDAS-2 hourly files) | 84,365,739 | `2e772f30316a9b23a5b51f8b9003122cf47fe16e691861ec1547335fd28aff58` |

The archive has a `.sha256` file next to it. The NLDAS-2 files are 88 MB of the 89 MB unpacked; they are
already compressed netCDF-4 and are kept unchanged and whole-grid, because LIS's NLDAS-2 reader reads the
full CONUS grid.

```
lisf-testcase-step2-20170101-20170103/
  README.txt
  lis.config.short                                  the configuration, 1 x 1 processors
  INPUT/lis_input.nldas.noah36.d01.nc               domain and parameter file (step 1 LDT output)
  INPUT/forcing_variables.txt
  INPUT/NOAH36_OUTPUT_LIST.TBL
  INPUT/LS_PARAMETERS/noah36_parms/{GENPARM,SOILPARM,VEGPARM}.TBL
  INPUT/NLDAS2.FORCING/2017/{001,002,003}/NLDAS_FORA0125_H.A2017010D.HH00.020.nc
                                                    2017-01-01 00Z to 2017-01-03 01Z, 50 files
```

## The configuration

`lis.config.short` is the walkthrough's `lis.config.step2.noah36_ol` with four lines changed: the end date
(2018-01-01 to 2017-01-03 00Z), the output directory (`./run_step2` to `./OUTPUT`), the log file
(`./run_step2/lislog_ol` to `./OUTPUT/lislog`) and the parameter file path (`./run_step1/...` to
`./INPUT/...`). History output (6-hourly), restart output (`1mo`, plus the one LIS writes at the end of a
run) and every model option are as in the walkthrough. All paths are relative to the top folder.

The processor layout in the configuration must match the MPI process count: `Number of processors along x`
times `along y` is 1 x 1 here, so run with 1 process. To run with 4, change both to 2. With 4 processes and
the shipped 1 x 1 layout, LIS stops at once with `[ERR] Layout does not match the number of processors`
(`npex, npey, 1 x 1 != 4`).

## Sources

- `lis.config.short` (edited as above), `INPUT/forcing_variables.txt`, `INPUT/NOAH36_OUTPUT_LIST.TBL` and
  `INPUT/LS_PARAMETERS/`: from `walkthrough_step2.tar.gz` (67,664,153 bytes, sha256 `f02942d2...61f295`),
  https://portal.nccs.nasa.gov/lisdata_pub/Tutorials/Web_Version/ (NASA GSFC Hydrological Sciences
  Laboratory, LIS team). No separate license is stated with the tutorial files; LISF is released under the
  Apache License 2.0.
- `INPUT/lis_input.nldas.noah36.d01.nc`: a byte-identical copy of
  `target_step1/target_lis_input.nldas.noah36.d01.nc` from `walkthrough_step1.tar.gz` (same folder;
  sha256 of the file `4497bc5e09ee3f51eebc189135e4724041ebd64a93a8243aacd8118b14afb42d`), the walkthrough's
  reference output of LDT step 1, under the name LDT gives it. It replaces running LDT on the 3.8 GB step 1
  inputs. LDT built the same way reproduces it with 20 of 23 variables identical and SLOPE, ASPECT and TBOT
  equal to float rounding (2026-10-25 and 2026-10-28 checks).
- `INPUT/NLDAS2.FORCING/`: unchanged files of NLDAS Primary Forcing Data L4 Hourly 0.125 x 0.125 degree V2.0
  (`NLDAS_FORA0125_H.2.0`), NASA GES DISC, doi:10.5067/THUF4J1RLSYG, from
  https://hydro1.gesdisc.eosdis.nasa.gov/data/NLDAS/NLDAS_FORA0125_H.2.0/2017/ (download needs an Earthdata
  login). The files cite Xia et al. 2012, J. Geophys. Res., doi:10.1029/2011JD016048. NASA Earth science data
  are openly shared without restriction under NASA's Earth science data policy; cite the dataset DOI. The
  hours are the ones LIS reads for this period: `A20170101.0000` first, then one per hour up to
  `A20170103.0100`, which it reads at the last step (as in the walkthrough's target log).

## Running it

From the top folder, with a LIS executable built with MPI (the default `dmpar` build):

```
cd lisf-testcase-step2-20170101-20170103
mpirun -np 1 <path to LIS> -f lis.config.short
```

No network access is needed during the run.

## What a run on these inputs shows

LIS built from https://github.com/gchang/lisf tag `lisf-public-7.8-f2b68e6.post1` with its
`scripts/conda_build` route (GNU 12.4, MPICH 4.3.2), run on this archive unpacked into an empty folder,
with no network:

- `mpirun -np 1`: exit 0, 9.1 s, peak 77 MB. `mpirun -np 4` with the layout changed to 2 x 2: exit 0, 3.5 s,
  83 MB per process.
- Outputs, 1.6 MB in all: `OUTPUT/lislog.0000` (one per process) ending `LIS Run completed.`, eight 6-hourly
  history files `OUTPUT/SURFACEMODEL/201701/LIS_HIST_201701010600.d01.nc` to `LIS_HIST_201701030000.d01.nc`,
  and the restart `OUTPUT/SURFACEMODEL/201701/LIS_RST_NOAH36_201701030000.d01.nc`. LIS read all 50 forcing
  files and logged no errors.
- The 4-process run's 9 files have values identical to the 1-process run's (only file timestamps differ).
- Against the walkthrough's `target_step2/SURFACEMODEL/201701/` files for the same 8 times (pooled over all
  cells and layers): forcing Tair_f, Rainf_f, Snowf and LWdown_f identical, SWdown_f within 5e-5 W m-2;
  every model variable r = 1.000000;
  SoilMoist RMSE 3.3e-6 m3 m-3 (98 % of values identical), SoilTemp RMSE 0.0012 K, SWE RMSE 3.0e-6 kg m-2,
  Qle RMSE 0.011 W m-2, Qh RMSE 0.013 W m-2. Largest single-cell differences: Qg 0.92 W m-2, Qh 0.53 W m-2,
  Qle 0.41 W m-2, SoilTemp 0.076 K, SoilMoist 2.0e-4 m3 m-3. None of the files is bit-identical; the
  walkthrough says differences "should be small", and the targets were made on a different system.
