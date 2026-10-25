# CARDAMOM short-chain demo input

`CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc` is the standard CARDAMOM demo input with a shorter MCMC run. I use it to check that a CARDAMOM build works from start to finish without waiting most of a day.

The site is the Soroe beech forest flux site in Denmark (55.486 N, 11.645 E), monthly from January 2001 to December 2018 (216 months). The model is DALEC 1100 with MCMC method 4 (DE-MCMC, 400 chains), and EDCs are on. The drivers are ERA5 meteorology. The file assimilates monthly LAI, biomass, snow cover, tower net carbon exchange (NBE), and sensible and latent heat.

- File: `CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc`, 68,989 bytes (NetCDF4)
- sha256: `597091bb7d55fdf2842aaa54ad6e6b5210262a397438cb7224562947c8288cba`

## Where it comes from

The file was generated with the CARDAMOM repository at https://github.com/CARDAMOM-framework/CARDAMOM, commit `1c0110d6fc09bb09fc1285e6af2f96b922cd684b` (main, 2026-10-22). It is the output of that repository's own demo generator, `PYTHON/check_fun/DEMO_CBF_NC_GENERATOR.py`, unmodified, which builds the file from the text files in `DATA/TEXT_FILE_DRIVERS/`. CARDAMOM is licensed under Apache-2.0 (`LICENSE` in that repository). Its README states: "Copyright (c) 2024 California Institute of Technology ("Caltech") and University of Washington. U.S. Government sponsorship acknowledged."

## What is different from the standard demo

Only the MCMC length. The `nITERATIONS` attribute of the `MCMCID` variable is 20,000 instead of the generator's 500,000. Every other setting is the generator's own (`nSAMPLES=10`, `nPRINT=1000`, `seed_number=0`, `nSAMPLES_EDC_SEARCH=400`), and so is every driver, observation and prior.

The full 500,000-iteration run takes 16 to 20 hours on one core. With 20,000 iterations the run finishes in about an hour: 65 minutes on one core of a Linux x86-64 machine (11 minutes for the EDC search, 54 minutes for the main chain), using about 30 MB of memory.

A chain this short is a smoke test, not a converged posterior. It shows that the code builds, reads the file, finds parameters that pass the EDCs, samples, and writes sensible output. The seasonal cycles fit the tower data well. However, quantities that need a long chain, such as the split between autotrophic and heterotrophic respiration, are not reliable. Do not use the results for science.

## How to reproduce it

You need a C compiler, netCDF-C (`nc-config`), and Python with numpy and netCDF4.

```bash
git clone https://github.com/CARDAMOM-framework/CARDAMOM
cd CARDAMOM
git checkout 1c0110d6fc09bb09fc1285e6af2f96b922cd684b
bash BASH/CARDAMOM_COMPILE.sh
python PYTHON/check_fun/DEMO_CBF_NC_GENERATOR.py      # writes CARDAMOM_DEMO_INPUT_FILE.cbf.nc here
cp CARDAMOM_DEMO_INPUT_FILE.cbf.nc CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc
python -c "
import netCDF4
with netCDF4.Dataset('CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc', 'a') as ds:
    ds['MCMCID'].nITERATIONS = 20000.0
"
sha256sum CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc
```

With conda-forge libnetcdf 4.10.1, hdf5 2.2.0 and netcdf4-python 1.7.4, these steps give exactly the sha256 above. With other library versions the bytes may differ, but the contents should be the same (compare with `ncdump`).

## How to run it

Build CARDAMOM as above, then run the model-data fusion and the forward run over the posterior:

```bash
C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc demo.cbr > mdf.log
C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe CARDAMOM_DEMO_INPUT_FILE_20k.cbf.nc demo.cbr demo.cbr.nc
```

`CARDAMOM_MDF.exe <file> <out>.cbr` writes the parameter samples to `<out>.cbr` (NetCDF, 4000 samples x 89 parameters) and a restart file `<out>.cbrSTART`. Start in a folder without an old `<out>.cbrSTART`, because MDF resumes from that file if it finds one. MDF writes about 17 MB of progress messages to stdout, so redirect it to a file. `CARDAMOM_RUN_MODEL.exe` then runs the model for every sample in a few seconds and writes all fluxes and pools to `demo.cbr.nc` (about 900 MB). It prints 64 lines saying that some parameters and fluxes have no defined abbreviation; these are harmless.

Both programs exit with 0 on success. A successful MDF run prints `Done with main MCMC` near the end of its log.
