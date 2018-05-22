function thePopup = initParameterChoice(obj, value)

% list of parameters 
popup = {{'SSPS','SSJT','SSTP','LATX','LONX'}, ...
  {'SSJT','SSTP','SSPS','LATX','LONX'}, ...
  {'SPDC','CNDC','SSPS_STD','FLOW','PRES','LATX','LONX','SSPS','SSJT','SSTP','FLU2'}};

% build the popup from data read in file
p = obj.nc.Variables;
thePopup = [];
for v = popup{value}
  if isfield(p, v)
    thePopup = [thePopup v]; %#ok<AGROW>
  end
end


