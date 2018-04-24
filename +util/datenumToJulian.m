function julian = datenumToJulian(dateNum)

% datenumToJulian -- Convert Matlab Julian Day to datenum.
%  datenumToJjulian(theDateNum) converts theDateNum (Matlab
%   datenum) to its equivalent Julian day with days since
%   1950-01-01 00:00:00.  

% $Id: datenumToJulian.m 92 2008-01-09 11:10:40Z jgrelet $
 


if nargin < 1, help(mfilename), return, end

origin = datenum(1950, 1, 1);

result = dateNum - origin;

if nargout > 0
	julian = result;
else
	disp(result)
end

