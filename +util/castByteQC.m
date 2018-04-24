function [tabOut] = castByteQC( code, tabIn )
%
% Routine filling an array with 'code' of type byte
%
% QC code are of type Byte in the NetCdf File
% Tab storing th QC code must be of type Byte.
%
% $Id: castByteQC.m 584 2010-06-01 15:12:37Z jgrelet $


 tabOut = int8(code) * int8( ones(size(tabIn) ));
 
end
