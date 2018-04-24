function nc = readGosudNetcdf(fileName)

% initialize netCDF instance from template
tmp = tsgqc.netcdf('+tsgqc\@dynaload\tsgqc_netcdf.csv');
% read netcdf file with tsgqc.netcdf toolbox
nc = tsgqc.netcdf(fileName);
addprop(nc, 'Quality');
nc.Quality = tmp.Quality;

