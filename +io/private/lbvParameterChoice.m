function [colParaNo, error] = lbvParameterChoice( header )
%
%function [colParaNo, error] = lbvParameterChoice( header )
%
% Display the parameters present in the header
% Build a GUI form to choose the parameters
%
% Input
% -----
% header .......... Header of the labview type file
%
% Output
% ------
% colParaNo .......... Column/line of the chosen parameter
% error .............. 1: OK ; -1 : an error occured

% Initialisation
% --------------
error     = -1;
colParaNo = [];
nHeader           = length( header );
indSelectedHeader = zeros(nHeader,1);

% Current and minimum FontSize
% ----------------------------
fontsize    = 11;
minFontsize = 5;

% Change default units to centimeters
% -----------------------------------
oldUnits = get(0, 'units' );
set(0, 'units', 'centimeters');

% Get the screen dimension in centimeters
% ---------------------------------------
screenSize =  get(0, 'screensize' );

% Pushbutton dimension in cm
% ---------------------------
pbHeight     = 0.8;
pbWidth      = 2.5;
nbPushbutton = 2;

% Set the left and bottom limit of the GUI
% ----------------------------------------
XBorder   = .5;
YBorder   = 1;

% Pre-selected parameter
% ----------------------
selectedPara    = { 'date';'time';'temp';'sal';'cond';'raw';'latdec';'londec';'ad1'};
% selectedPara    = { 'date';'time';'temp';'sal';'lat';'lon' };
nSelectedPara   = length( selectedPara );

% Get the order number of pre-selected parameter
% ----------------------------------------------
for i = 1:nSelectedPara
  x = strfind( header, char(selectedPara(i))  );

  % Look for the first not-empty cell
  % ---------------------------------
  for j = 1:nHeader
    if ~isempty(x{j})
      indSelectedHeader(j) = 1;
      break;
    end
  end
end

% Compute the size of the GUI depending on the number of UIcontrol
% If it does not fit into the PC screen, change the FontSize
% -------------------------------------------------------------------
figWidth = 2*screenSize(3);
while figWidth > screenSize(3) && fontsize > minFontsize

  % Determine the max size of the UIcontrol
  % ----------------------------------------
  hf = figure('Visible', 'off', 'Position', screenSize);
  for ipar = nHeader : -1 : 1

    h = uicontrol( 'Parent', hf, 'Style', 'checkbox', 'String', header(ipar), ...
      'Fontsize', fontsize, 'Units', 'centimeters', 'visible', 'off');

    % Get the dimension of the string in the Uicontrol
    % ------------------------------------------------
    extent = get(h, 'extent');
    cbWidth(ipar)  = extent(3);
    cbHeight(ipar) = extent(4);

    delete( h )
  end
  delete( hf )

  % Checkboxes dimension - + 0.5 : size of the checkbox
  % ---------------------------------------------------
  cbWidth     = max(cbWidth) + .5;
  cbHeight    = max(cbHeight);
  cbYinterval = .1;

  % Compute figure height using the number of UIcontrol +
  % the height of some pushbutton + the border height
  % -----------------------------------------------------
  nbCol     = 0;
  figHeight = 2*screenSize(4);
  while figHeight > screenSize(4)
    nbCol     = nbCol + 1;
    nbLine    = floor( nHeader / nbCol );
    figHeight = (cbYinterval + pbHeight) + ...
                 cbHeight*nbLine + cbYinterval*(nbLine+1) + YBorder*2;
  end

  % Compute figure height using the number of UIcontrol +
  % the height of some pushbutton
  % ---------------------------------------------------
  figHeight = (cbYinterval + pbHeight) + ...
               cbHeight*nbLine + cbYinterval*(nbLine+1);

  % Compute figure width using the number of UIcontrol +
  % border width
  % ---------------------------------------------------
  figWidth = cbWidth * nbCol + 2*XBorder;
  
  fontsize = fontsize -1;
  
end

% Compute figure width using the number of UIcontrol
% --------------------------------------------------
figWidth = cbWidth * nbCol;
figWidth = max( figWidth, nbPushbutton*pbWidth);

% Center the GUI
% --------------
XBorder = (screenSize(3) - figWidth)/2;
YBorder = (screenSize(4) - figHeight)/2;

% header Uicontrols in a new figure
% ---------------------------------
hParamFig = figure(...
  'Name', 'Parameters', ...
  'NumberTitle', 'off', ...
  'Resize', 'off', ...
  'Menubar','none', 'Toolbar', 'none', ...
  'Tag', 'TAG_LBV_CHOIX', ...
  'Visible','on',...
  'HandleVisibility', 'callback',...
  'Units', 'centimeters',...
  'Position',[XBorder, YBorder, figWidth, figHeight], ...
  'Color', get(0, 'DefaultUIControlBackgroundColor'));
 % 'WindowStyle', 'modal', ...

% Iterate from each element
% -------------------------
ipar   = 1;
x_left = .05;
for i = 1 : nbCol
  
  % Set the upper UIcontrol first
  % -----------------------------
  y_bottom = (pbHeight + cbYinterval) + ...
              cbHeight*(nbLine-1) + cbYinterval*(nbLine);
  for j = 1 : nbLine

    if ipar > nHeader
      break;
    end

    % display dynamically uicontrol
    % -----------------------------
    ui(ipar) = uicontrol(...
      'Parent', hParamFig, ...
      'Style', 'checkbox', ...
      'String', header(ipar), ...
      'Fontsize', fontsize, ...
      'Value', indSelectedHeader(ipar), ...
      'Tag', ['TAG_CHECK_BOX_' num2str(ipar)], ...
      'HandleVisibility', 'on',...
      'Units', 'centimeters', ...
      'Position', [x_left y_bottom cbWidth cbHeight ]);

    y_bottom = y_bottom - cbHeight - cbYinterval;
    ipar = ipar + 1;

  end
  x_left = x_left + cbWidth;
end

% CONTINUE PUSH BUTTON
% --------------------
uicontrol( ...
  'Parent', hParamFig, ...
  'Style','pushbutton',...
  'Fontsize', fontsize,...
  'String','Continue',...
  'Interruptible','off',...
  'BusyAction','cancel',...
  'Tag','PUSH_BUTTON',...
  'Units', 'centimeters', ...
  'Position',[.05, cbYinterval, pbWidth, pbHeight],...
  'Callback', @continueCallback);

% CANCEL PUSH BUTTON
% ------------------
uicontrol( ...
  'Parent', hParamFig, ...
  'Style','pushbutton',...
  'Fontsize', fontsize,...
  'String','Cancel',...
  'Interruptible','off',...
  'BusyAction','cancel',...
  'Tag','PUSH_BUTTON',...
  'Units', 'centimeters', ...
  'Position',[.05+pbWidth, cbYinterval, pbWidth, pbHeight],...
  'Callback', @cancelCallback);

set(0, 'units', oldUnits);

% stop execution until push-button Continue was press
% and hParamFig is deleted
% ---------------------------------------------------
uiwait(hParamFig);

%% Nested callback

  % -----------------------------------------------------------------------
  % Continue action, get uicontrol fields and populate tsg structure
  % -----------------------------------------------------------------------
  function continueCallback(obj, event)

    % Everything's ok
    % ---------------
    error = 1;
    
    % Get the values of the checkboxes
    % --------------------------------
    for i = 1 : nHeader
      indSelectedHeader(i) = get( ui(i), 'value');
    end

    for i = 1 : nSelectedPara
      x = strfind( header(indSelectedHeader == 1), char(selectedPara(i))  );

      % Look for the first not-empty cell
      % ---------------------------------
      n = 0;
      for j = 1:length(x)
        if ~isempty(x{j})
          n = n + 1;
        end
      end
      
      switch n
       
        case 0
          
          % Select automatically COND and RAW
          % ---------------------------------
          if strcmp( char(selectedPara(i)), 'cond' ) || ...
             strcmp( char(selectedPara(i)), 'raw' )

           x = strfind( header, char(selectedPara(i))  );
            for j = 1:length(x)
              if ~isempty(x{j})
                indSelectedHeader(j) = 1;
                set( ui(j), 'value', 1 );
              end
            end

          else

            msgbox( ['Choose a ' char(selectedPara(i))], 'modal' );
            error = -1;
            break;

          end
        
        case 1
          continue
          
        otherwise
          msgbox( ['Choose only ONE ' char(selectedPara(i))], 'modal' );
          error = -1;
          break;
      
      end
    end

    % If everything'ok. Close the GUI
    % -------------------------------
    if error == 1
      
      % Return the column/line number of the parameter
      % -----------------------------------------
      colParaNo = find( indSelectedHeader == 1 );
      
      % close windows (replace call to uiresume(hParamFig))
      % ----------------------------------------------------
      close(hParamFig);

      % flushes the event queue and updates the figure window
      % -----------------------------------------------------
      drawnow;
      
%      return
      
    end

  end

  % -----------------------------------------------------------------------
  % Cancel button, no action
  % -----------------------------------------------------------------------
  function cancelCallback(obj, event)
    
    % return error code (no change)
    % -----------------------------
    error = -1;

    % close windows
    % -------------
    close(hParamFig);
    
    % flushes the event queue and updates the figure window
    % -----------------------------------------------------
    drawnow;
    
%    return
  end
end
