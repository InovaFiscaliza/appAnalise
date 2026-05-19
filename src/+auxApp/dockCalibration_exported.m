classdef dockCalibration_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        OkButton               matlab.ui.control.Button
        CalibrationPanel       matlab.ui.container.Panel
        CalibrationGrid        matlab.ui.container.GridLayout
        CurveNames             matlab.ui.control.DropDown
        CurveNamesLabel        matlab.ui.control.Label
        InitialLevelUnit       matlab.ui.control.EditField
        InitialLevelUnitLabel  matlab.ui.control.Label
        Title                  matlab.ui.control.Label
        TitleIcon              matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true
        mainApp
        callingApp
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
        refCalibrationData
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAppProperties(app, context, flowIdx)
            % inputArgs
            app.inputArgs = struct('context', context, 'flowIdx', flowIdx);

            % refCalibrationData
            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);

            try
                refCalibrationFileContent = jsondecode(fileread(fullfile(programDataFolder, 'Calibration.json')));
            catch
                refCalibrationFileContent = jsondecode(fileread(fullfile(projectFolder,     'Calibration.json')));
            end

            app.refCalibrationData = refCalibrationFileContent;
        end

        %-----------------------------------------------------------------%
        function updatePanel(app)
            flowIdx = app.inputArgs.flowIdx;
            specData = aoo.mainApp.specData(flowIdx);

            if isempty(specData.UserData.CalibrationCurve)
                app.InitialLevelUnit.Value = specData.MetaData.LevelUnit;
            else
                app.InitialLevelUnit.Value = specData.UserData.CalibrationCurve.PreviousLevelUnit{1};
            end

            app.CurveNames.Items = [{''}; {app.refCalibrationData.Name}'];
        end

        %-----------------------------------------------------------------%
        function msgError = applyCalibration(app, operationType, idxThread, idxCalibration, kFactorName)
            msgError = '';

            try
                util.measCalibration(app.specData, app.rootFolder, operationType, idxThread, idxCalibration, kFactorName)
            catch ME
                msgError = ME.message;
                ui.Dialog(app.UIFigure, 'warning', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function calibrationCurve = computeCalibrationCurve(refCalibrationData, freqStart, freqStop, dataPoints, levelUnit)

        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                initializeAppProperties(app, context, flowIdx)
                updatePanel(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Button pushed function: OkButton
        function onOkButtonClicked(app, event)
        
            % DADOS DA CALIBRAÇÃO A SER APLICADA
            selectedCurveName = app.CurveNames.Value;
            [~, selectedCurveNameIdx] = ismember(selectedCurveName, {app.refCalibrationData.Name});

            if ~selectedCurveNameIdx
                return
            end

            calibrationData = app.refCalibrationData(selectedCurveNameIdx);

            % DADOS DO FLUXO ESPECTRAL SOB ANÁLISE
            flowIdx = app.inputArgs.flowIdx;
            specData = aoo.mainApp.specData(flowIdx);

            freqStart = specData.MetaData.FreqStart / 1e+6;
            freqStop = specData.MetaData.FreqStop  / 1e+6;
            dataPoints = specData.MetaData.DataPoints;

            try
                % VALIDAÇÃO
                if contains(specData.UserData.CalibrationCurve.Name, calibrationData.Name)
                    error('Curva de correção já incluída!')
            
                elseif strcmp(calibrationData.Type, 'Antenna k-Factor')
                    if any(contains(specData.UserData.CalibrationCurve.Type, 'Antenna k-Factor'))
                        error([ ...
                            'Já incluída uma curva de correção do tipo "Antenna k-Factor", ' ...
                            'a qual deve ser previamente excluída antes da inclusão de uma nova.' ...
                        ])
            
                    elseif ~ismember(specData.MetaData.LevelUnit, {'dBm', 'dBµV'})
                        error([ ...
                            'Para inclusão de uma curva de correção do tipo "Antenna k-Factor", ' ...
                            'a unidade de medida da faixa monitorada precisa ser "dBm" ou "dBµV".' ...
                        ])
                    end
                end
            
                if ~((calibrationData.xData(1) <= freqStart) && (calibrationData.xData(end) >= freqStop))
                    error('A curva de correção não engloba a faixa monitorada.')
                end

                 update(specData, 'UserData:CalibrationCurve', calibrationData)

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

        end

        % Value changed function: CurveNames
        function CurveNamesValueChanged(app, event)
            
            app.OkButton.Enable = ~isempty(app.CurveNames.Value);

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, Container)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            if isempty(Container)
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.AutoResizeChildren = 'off';
                app.UIFigure.Position = [100 100 452 170];
                app.UIFigure.Name = 'appAnalise';
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                if ~isempty(Container.Children)
                    delete(Container.Children)
                end

                app.UIFigure  = ancestor(Container, 'figure');
                app.Container = Container;
                if ~isprop(Container, 'RunningAppInstance')
                    addprop(app.Container, 'RunningAppInstance');
                end
                app.Container.RunningAppInstance = app;
                app.isDocked  = true;
            end

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Container);
            app.GridLayout.ColumnWidth = {18, 274, 110};
            app.GridLayout.RowHeight = {17, 5, 74, 10, 24};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TitleIcon
            app.TitleIcon = uiimage(app.GridLayout);
            app.TitleIcon.ScaleMethod = 'none';
            app.TitleIcon.Layout.Row = 1;
            app.TitleIcon.Layout.Column = 1;
            app.TitleIcon.ImageSource = 'symbol-operator.svg';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 2;
            app.Title.Text = 'CURVA DE CORREÇÃO';

            % Create CalibrationPanel
            app.CalibrationPanel = uipanel(app.GridLayout);
            app.CalibrationPanel.AutoResizeChildren = 'off';
            app.CalibrationPanel.Layout.Row = 3;
            app.CalibrationPanel.Layout.Column = [1 3];

            % Create CalibrationGrid
            app.CalibrationGrid = uigridlayout(app.CalibrationPanel);
            app.CalibrationGrid.ColumnWidth = {110, 270};
            app.CalibrationGrid.RowHeight = {28, 22};
            app.CalibrationGrid.RowSpacing = 5;
            app.CalibrationGrid.Padding = [10 10 10 5];
            app.CalibrationGrid.BackgroundColor = [1 1 1];

            % Create InitialLevelUnitLabel
            app.InitialLevelUnitLabel = uilabel(app.CalibrationGrid);
            app.InitialLevelUnitLabel.VerticalAlignment = 'bottom';
            app.InitialLevelUnitLabel.WordWrap = 'on';
            app.InitialLevelUnitLabel.FontSize = 11;
            app.InitialLevelUnitLabel.Layout.Row = 1;
            app.InitialLevelUnitLabel.Layout.Column = 1;
            app.InitialLevelUnitLabel.Interpreter = 'html';
            app.InitialLevelUnitLabel.Text = {'Unidade original:'; '<p style="line-height:10px; font-size:9px; color:gray;">(coleta)</p>'};

            % Create InitialLevelUnit
            app.InitialLevelUnit = uieditfield(app.CalibrationGrid, 'text');
            app.InitialLevelUnit.Editable = 'off';
            app.InitialLevelUnit.FontSize = 11;
            app.InitialLevelUnit.Layout.Row = 2;
            app.InitialLevelUnit.Layout.Column = 1;

            % Create CurveNamesLabel
            app.CurveNamesLabel = uilabel(app.CalibrationGrid);
            app.CurveNamesLabel.VerticalAlignment = 'bottom';
            app.CurveNamesLabel.FontSize = 11;
            app.CurveNamesLabel.Layout.Row = 1;
            app.CurveNamesLabel.Layout.Column = 2;
            app.CurveNamesLabel.Interpreter = 'html';
            app.CurveNamesLabel.Text = {'Curva de correção:'; '<p style="line-height:10px; font-size:9px; color:gray;">(calibração, fator-k)</p>'};

            % Create CurveNames
            app.CurveNames = uidropdown(app.CalibrationGrid);
            app.CurveNames.Items = {'', 'CRFS Low Band (10 MHz - 1.2 GHz)', 'CRFS High Band (750 MHz - 6 GHz)', 'Rohde & Schwarz ADDx07 (Argus)', 'Rohde & Schwarz ADD107 (20 MHz - 1.3 GHz)', 'Rohde & Schwarz ADD207 (690 MHz - 6 GHz)'};
            app.CurveNames.ValueChangedFcn = createCallbackFcn(app, @CurveNamesValueChanged, true);
            app.CurveNames.FontSize = 11;
            app.CurveNames.BackgroundColor = [1 1 1];
            app.CurveNames.Layout.Row = 2;
            app.CurveNames.Layout.Column = 2;
            app.CurveNames.Value = '';

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onOkButtonClicked, true);
            app.OkButton.Tag = 'OK';
            app.OkButton.Icon = 'Add_16.png';
            app.OkButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.OkButton.Enable = 'off';
            app.OkButton.Layout.Row = 5;
            app.OkButton.Layout.Column = 3;
            app.OkButton.Text = 'Aplicar curva';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockCalibration_exported(Container, varargin)

            % Create UIFigure and components
            createComponents(app, Container)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            if app.isDocked
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
