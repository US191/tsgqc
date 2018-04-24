function  OutData = GPStodegdec( InData )
%
% Cette fonction permet de convertir des mesures GPS
% au format 25°13.34N en degre decimal.
% InData = {'25°13.34N', '15', '45°34.56S'};

% Dans cette premiere partie j'extraie du format GPS
% les degre, les minutes et l'hemisphere.

% Look ahead from current position and test if ° is found.
% L'option ONCE ne conserve qu'une occurence. Au lieu de
% creer des cellules de cellules. On ne cree qu'une cellule
% de string. Plus facile a gerer.
% --------------------------------------------------------
[v1 v2 v3 deg v5 v6] = regexp(InData, '\w*(?=°)', 'once');
  
% Look ahead from current position and test if . is found.
% --------------------------------------------------------
[v1 v2 v3 min v5 v6] = regexp(InData, '(?<=°)\d*', 'once');

% Look ahead from current position and test if numbers are found
% --------------------------------------------------------
[v1 v2 v3 sec v5 v6] = regexp(InData, '(?<=\.)\d*', 'once');

% Find any alphabetic character
% -----------------------------
[v1 v2 v3 NSEW v5 v6] = regexp(InData, '[A-Z]', 'once');


% Remplir les cellules vides par des NaN
% --------------------------------------
IsEmpty = find( strcmp( deg, '') == 1 );
deg(IsEmpty, 1) = {'NaN'};
min(IsEmpty, 1) = {'NaN'};
sec(IsEmpty, 1) = {'NaN'};
NSEW(IsEmpty, 1) = {'NaN'};

% noNaN = find( strcmp( deg, 'NaN') == 0 );

[m n] = size(deg);
degre = NaN*ones(m,n);
minute = NaN*ones(m,n);
seconde = NaN*ones(m,n);

% Conversion en numerique et en degre decimal
% -------------------------------------------
degre = str2double( deg );
minute = str2double( min ) / 60;
seconde = str2double( sec )* .6 / 3600;

OutData = degre + minute + seconde;

% Determination du signe
% ----------------------
IsNegative = find(strcmp(NSEW, 'S') == 1);
if ~isempty( IsNegative )
  OutData( IsNegative ) = -OutData( IsNegative ); 
end
IsNegative = find(strcmp(NSEW, 'W') == 1);
if ~isempty( IsNegative )
  OutData( IsNegative ) = -OutData( IsNegative ); 
end

