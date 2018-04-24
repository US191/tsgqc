function [theDate, theTime, lat, lon, sst, sss, sssStd, cond, condRaw, sog, cog, flow] =...
  decodeficlabview( fid, DELIMITER, ColNo, paraName )
%
% Fonction qui permet de lire les fichiers au format LabView
% La fonction :
% - lit les lignes incompletes
% - elimine les lignes d'entetes qui peuvent se trouver a differents
%   endroits du fichier
%
%   ATTENTION : Je fais l'hypothese que la premiere ligne du fichier
%               est une ligne d'entete
%
% input
%   fid ........... Numero logique du fichier a decoder
%   DELIMITER ..... caractere separant chaque parametre a decoder sur
%                   une ligne
%
% output
%   date .......... Dates - Cellule
%   time .......... Heure - Cellule
%   lat  .......... Latitude - Tableau de double
%   lon  .......... Longitude - Tableau de double
%   sst  .......... Temperature - Tableau de double
%   sss  .......... Salinite - Tableau de double
%   cond .......... Conductivite - Tableau de double
%   condRaw ....... Conductivite brute - tableau de chaine de caracteres
%   sog  .......... Vitesse du navire - Tableau de double
%   cog  .......... Cap du navire - Tableau de double
%   flow .......... Mesure de debit de l'alimentation du TSG
%   pres .......... Mesure de pression dans le TSG
%
% Mofication
% 23/01/2006    Initialisation de condRaw modifié
%                        Avant      condRaw = NaN*ones(nblig, 1);
%                        Maintenant condRaw = char(blanks(1)*ones(nblig,1));
%
% Fonction mere :       readTsgDataLabview
% Focntions appelees :  GPStodegdec
% -------------------------------------------------------------------

% Le nombre d'elements de l'entete determine le nombre de chaine a lire.
% Je cree ici la chaine de caractere decrivant le format utilise par
% textscan. Modifie par jg avec repmat
% --------------------------------------------------------------
theFormat = repmat(' %s', 1, size(paraName,2));

% textscan permet de lire a peu pres tout, memes les lignes
% incompletes, plus courtes.
% Par contre les données lues sont enregistrees dans une
% Cellule de cellule
% ATTENTION :
%   dans le cas de lignes incompletes textscan n'utilise pas
%   enptyValue mais une chaine de caracteres vide
% -----------------------------------------------------------
data = textscan(fid, theFormat, 'delimiter', DELIMITER, 'emptyValue', NaN);

% Remplace les chaines de caracteres vides par des NaN
% ----------------------------------------------------
for icell = 1:length( data )
  vide = find( strcmp( data{icell}, '' ) == 1);
  for j = 1 : length(vide)
    data{icell}{vide(j)} = 'NaN';
  end
end

% Selectionne les numeros des lignes qui ne sont pas des entetes
% ATTENTION
% Je fais l'hypothese que la premiere ligne du fichier est une ligne
% d'entete
% ------------------------------------------------------------------
%theDate  = char( data{ColNo.Date} );
ient = strcmp( data{1}, data{1}{1}  );
ient = find(ient == 0);

% Initialisation
% --------------
nblig = length(ient);
theDate  = cell(nblig, 1);
theTime  = cell(nblig, 1);
lat   = NaN*ones(nblig, 1);
lon   = NaN*ones(nblig, 1);
sst   = NaN*ones(nblig, 1);
sss   = NaN*ones(nblig, 1);
sssStd  = NaN*ones(nblig, 1);
cond  = NaN*ones(nblig, 1);
condRaw = char(blanks(1)*ones(nblig,1));
sog   = NaN*ones(nblig, 1);
cog   = NaN*ones(nblig, 1);
flow  = NaN*ones(nblig, 1);

% Selection des parametres utiles au programme et conversion
% La date et l'heure sont stockes dans des cellules
% ----------------------------------------------------------
if ColNo.Date ~= 0
  A = data(ColNo.Date);
  B = char( A{1}(ient) );
  % test if string is date
  exp = '(\d+/\d+/\d+)';
  match = regexp(A{1}(ient), exp, 'ONCE');
  theDate = cellstr( B );
  for i=1 : nblig
    if isempty(match{i})
      theDate{i} = 'NaN';
    end
  end
end
if ColNo.Time ~= 0
  A = data(ColNo.Time);
  B = char( A{1}(ient) );
  % test if string is time with optional AM or PM at the end
  exp = '(\d+:\d+:\d+(\w+)?)';
  match = regexp(A{1}(ient), exp, 'ONCE');
  theTime = cellstr( B );
  for i=1 : nblig
    if isempty(match{i})
      theTime{i} = 'NaN';
    end
  end
end
if ColNo.Lat ~=0
  % Test si latitude en degre decimal ou degre minute
  % --------------------------------------------------
  A = data{ColNo.Lat};
  match = regexp(A(ient),'(\d+\W\d+.\d+\s+\w)', 'ONCE');
  lat   = str2num( char(data{ColNo.Lat}{ient}) );
  
  % lat est vide si les latitudes sont en degres minutes.
  % Conversion en degre decimal
  % -----------------------------------------------------
  if isempty(lat)
    theLat = cellstr(char(data{ColNo.Lat}{ient}));
    for i=1 : nblig
      if isempty(match{i})
        theLat{i} = '  °  .    ';
      end
    end
    lat = GPStodegdec(theLat ) ;
  end
  
end

if ColNo.Lon ~= 0
  A = data{ColNo.Lon};
  match = regexp(A(ient),'(\d+\W\d+.\d+\s+\w)', 'ONCE');
  lon   = str2num( char(data{ColNo.Lon}{ient}) );
  
  % lon est vide si les latitudes sont en degres minutes.
  % Conversion en degre decimal
  % -----------------------------------------------------
  if isempty(lon)
        theLon = cellstr(char(data{ColNo.Lon}{ient}));
    for i=1 : nblig
      if isempty(match{i})
        theLon{i} = '   °  .    ';
      end
    end
    lon = GPStodegdec( theLon );
  end
end

if ColNo.Temp ~= 0
  sst   = str2num( char(data{ColNo.Temp}{ient}) );
end
if ColNo.Sal ~= 0
  sss   = str2num( char(data{ColNo.Sal}{ient}) );
end
if ColNo.SalStd ~= 0
  sssStd = str2num( char(data{ColNo.SalStd}{ient}) );
end
if ColNo.Cond ~= 0
  cond  = str2num( char(data{ColNo.Cond}{ient}) );
end
if ColNo.Raw ~= 0
  condRaw = char( data{ColNo.Raw}{ient} );
end
if ColNo.Sog ~= 0
  sog   = str2num( char(data{ColNo.Sog}{ient}) );
end
if ColNo.Cog ~= 0
  cog   = str2num( char(data{ColNo.Cog}{ient}) );
end
if ColNo.AD1 ~= 0
  flow   = str2num( char(data{ColNo.AD1}{ient}) );
end