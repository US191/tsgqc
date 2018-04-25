function save(self, varargin)
% tsgqc.dynaload.save
% it's a wrapper on tsgqc.dynaload.write method
%
% $Id: save.m 203 2013-01-22 15:15:17Z jgrelet $

% uses the comma-separated list syntax varargin{:} to pass the optional
% parameters to write
% ---------------------------------------------------------------------
write(self, varargin{:});



