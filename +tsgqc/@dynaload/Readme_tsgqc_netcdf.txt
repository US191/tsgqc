Instruction for tsgqc_netcdf.csv file generation

Edit or modify tsgqc_netcdf.xls file with Microsoft Excel. 
In the column dimension, check that each cell as simple parenthesis, 
use 'special past' to do it.

Load Excel file in memory and write it csv

>> d = tsgqc.dynaload('tsgqc_netcdf.xls')
d = 

  tsgqc.dynaload
  Package: tsgqc

    Filename:     '+tsgqc\@dynaload\tsgqc_netcdf.csv'
  MagicField:     'data__'
  AutoAccess:      false
        Echo:      true

  Dimensions    	 9  [struct]
  Variables     	68  [struct]
  Attributes    	36  [struct]
  Quality       	 9  [struct]


Save the csv file:

>> write(d,'tsgqc_netcdf.csv')

Create the quality.mat file:
>> qc=d.Quality
>> save('quality.mat','qc')


