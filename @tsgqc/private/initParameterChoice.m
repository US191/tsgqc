function thePopup = initParameterChoice(obj, value)
% initParameterChoice is called by readFile method

% list of parameters 
popup = {{'SSPS','SSJT','SSTP','LATX','LONX'}, ...
  {'SSJT','SSTP','SSPS','LATX','LONX'}, ...
  {'SPDC','CNDC','SSPS_STD','FLOW','PRES','LATX','LONX','FLU2'}};

% build the popup from only data read in file
p = obj.nc.Variables;
thePopup = [];
for v = popup{value}
  if isfield(p, v)
    thePopup = [thePopup v]; %#ok<AGROW>
  end
end


