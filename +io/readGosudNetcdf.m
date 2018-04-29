function nc = readGosudNetcdf(fileName)

% read netcdf file with tsgqc.netcdf toolbox
nc = tsgqc.netcdf(fileName);

% convert GOSUD julian Day to Matlab datenum.
nc.Variables.DAYD.data__ = util.julianToDatenum(nc.Variables.DAYD.data__);



