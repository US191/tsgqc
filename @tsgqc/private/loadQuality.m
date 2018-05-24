function loadQuality(obj)

% read quality structure from +tsgqc/@dynaload file
tmp = load(strcat('+tsgqc',filesep,'@dynaload',filesep,'quality.mat'));
% addprop(obj.nc, 'Quality');
obj.qc = tmp.qc;

% initialize default active QC
obj.activeQc.code  = obj.qc.NO_CONTROL.code;
obj.activeQc.color = obj.qc.NO_CONTROL.color;

