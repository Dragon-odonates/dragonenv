# dragonenv
Research compendium for spatial data extraction over a regular grid at European scale

## General

This repository is structured as follow:

- :file_folder: &nbsp;`analyses/`: contains R scripts to extract spatial data;
- :file_folder: &nbsp;`data/`: contains raw and derived data;


## Usage

The analysis can be done at difference scales (5, 10 or 50km are supported). There are 4 sequential steps:  

1. simplify the grid from [EEA Reference grid](https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b)  
2. extract landcover information from Corine Land Cover
3. extract bioclimatic variables from CHELSA dataset
4. format environmental data 

```r
source("make.R")
```


## Raw dataset

The raw dataset is heavy and not hosted in Github but it can be downloaded:  

- [EEA Grid 50 km](https://sdi.eea.europa.eu/data/aac8379a-5c4e-445c-b2ef-23a6a2701ef0)
- [EEA Grid 10 km](https://sdi.eea.europa.eu/data/e834751f-19d1-4842-823d-e90e600c5993)
- [EEA Grid 5 km](https://sdi.eea.europa.eu/data/c56f5e2b-6e7f-4da7-a5b3-25a8c17ca717)
- [CORINE Land Cover 2018 raster 100 m](https://land.copernicus.eu/en/products/corine-land-cover/clc2018)
- [Chelsa Bio1 1981-2010 raster 1km](https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio1_1981-2010_V.2.1.tif)
- [Chelsa Bio4 1981-2010 raster 1km](https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio4_1981-2010_V.2.1.tif)
- [Chelsa Bio10 1981-2010 raster 1km](https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio10_1981-2010_V.2.1.tif)
- [Chelsa Bio12 1981-2010 raster 1km](https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio12_1981-2010_V.2.1.tif)
- [Chelsa Bio15 1981-2010 raster 1km](https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio15_1981-2010_V.2.1.tif)



## Reference

If you use this derived dataset, please cite the raw data sources:
   
> CORINE Land Cover 2018. European Union's Copernicus Land Monitoring Service information, https://doi.org/10.2909/960998c1-1870-4e82-8051-6485205ebbac

> European Environment Agency (2024).EEA reference grid for Europe (50km), Jun. 2024.
https://doi.org/10.2909/aac8379a-5c4e-445c-b2ef-23a6a2701ef0

> Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017).Climatologies at high resolution for the Earth land surface areas. Scientific Data. 4 170122. https://doi.org/10.1038/sdata.2017.122


