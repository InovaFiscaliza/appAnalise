classdef dockFlowMerge_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        OkButton            matlab.ui.control.Button
        MergeAnalysis       matlab.ui.control.Label
        MergeAnalysisLabel  matlab.ui.control.Label
        FlowTree            matlab.ui.container.Tree
        FlowTreeLabel       matlab.ui.control.Label
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
        jsBackDoor
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            drawnow

            elToModify = {
                app.MergeAnalysis
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);
    
            try
                appName = class.Constants.appName;
                ui.TextView.startup(app.jsBackDoor, app.MergeAnalysis, appName, struct('class', {{'textview--wordbreak'}}));
            catch
            end
        end

        %-----------------------------------------------------------------%
        function buildTree(app)
            if ~isempty(app.FlowTree.Children)
                delete(app.FlowTree.Children)
            end

            if ~isempty(app.mainApp.specData)
                [receiverList, ~, receiverListIdxs] = unique({app.mainApp.specData.Receiver});
    
                for ii = 1:numel(receiverList)
                    receiverIdxs  = find(receiverListIdxs == ii)';
                    occupancyIdxs = arrayfun(@(x) ismember(x.MetaData.DataType, class.Constants.occDataTypes), app.mainApp.specData(receiverIdxs));
                    receiverIdxs(occupancyIdxs) = [];

                    if isempty(receiverIdxs)
                        continue
                    end

                    receiverNode = uitreenode(app.FlowTree, 'Text',  util.layoutTreeNodeText(receiverList{ii}, 'play_TreeBuilding'), ...
                                                            'NodeData', receiverIdxs, 'Icon', util.layoutTreeNodeIcon(receiverList{ii}), 'Tag', 'RECEIVER');

                    for jj = receiverIdxs
                        uitreenode(receiverNode, 'Text', util.HtmlTextGenerator.createTag('Flow', app.mainApp.specData(jj)), ...
                                                 'NodeData', jj, 'Tag', 'BAND');
                    end
                end

                expand(app.FlowTree, 'all')
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context)

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context);
                applyJSCustomizations(app)
                buildTree(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Selection changed function: FlowTree
        function onFlowTreeSelectionChanged(app, event)
            
            selectedNodes = app.FlowTree.SelectedNodes;
            flowIdxs = [];
            if ~isempty(selectedNodes)
                flowIdxs = unique([selectedNodes.NodeData]);
            end

            [status, msg] = validateFlowMergeRequest(app.mainApp.specData, flowIdxs);
            
            app.OkButton.Enable = status;
            app.MergeAnalysis.Text = sprintf('<p style="margin: 10px; word-break: normal;">%s</p>', msg);
            
        end

        % Button pushed function: OkButton
        function onOkButtonClicked(app, event)
            
            selectedNodes = app.FlowTree.SelectedNodes;
            if isempty(selectedNodes)
                return
            end

            requestVisibilityChange(app.progressDialog, 'visible', 'unlocked')
            
            flowIdxs = unique([selectedNodes.NodeData]);
            for ii = flowIdxs
                specData = app.mainApp.specData(ii);

                if ~isempty(specData) && (isempty(specData.Data) || (numel(specData.Data{1}) ~= sum(specData.RelatedFiles.NumSweeps)))    
                    try
                        populateSpectrum(specData, app.mainApp.metaData, app.mainApp.projectData, app.mainApp.channelObj, app.mainApp.General)
                        
                        relatedHases = specData.UserData.OccupancyComputationMode.RelatedHashes;
                        if ~isempty(relatedHases)
                            relatedHashIdxs = find(ismember({app.mainApp.specData.Hash}, relatedHases));
                            populateSpectrum(app.mainApp.specData(relatedHashIdxs), app.mainApp.metaData, app.mainApp.projectData, app.mainApp.channelObj, app.mainApp.General)
                        end
    
                    catch ME
                        ui.Dialog(app.UIFigure, 'warning', ME.message);
                        requestVisibilityChange(app.progressDialog, 'hidden', 'unlocked')
                        return
                    end
                end
            end
            
            requestVisibilityChange(app.progressDialog, 'hidden', 'unlocked')

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onFlowMergeRequested', flowIdxs)

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
                app.UIFigure.Position = [100 100 880 480];
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
            app.GridLayout.ColumnWidth = {320, 10, '1x', 110};
            app.GridLayout.RowHeight = {22, 5, '1x', 10, 24};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create FlowTreeLabel
            app.FlowTreeLabel = uilabel(app.GridLayout);
            app.FlowTreeLabel.VerticalAlignment = 'bottom';
            app.FlowTreeLabel.FontSize = 10;
            app.FlowTreeLabel.Layout.Row = 1;
            app.FlowTreeLabel.Layout.Column = 1;
            app.FlowTreeLabel.Text = 'FLUXOS ESPECTRAIS';

            % Create FlowTree
            app.FlowTree = uitree(app.GridLayout);
            app.FlowTree.Multiselect = 'on';
            app.FlowTree.SelectionChangedFcn = createCallbackFcn(app, @onFlowTreeSelectionChanged, true);
            app.FlowTree.FontSize = 11;
            app.FlowTree.Layout.Row = 3;
            app.FlowTree.Layout.Column = 1;

            % Create MergeAnalysisLabel
            app.MergeAnalysisLabel = uilabel(app.GridLayout);
            app.MergeAnalysisLabel.VerticalAlignment = 'bottom';
            app.MergeAnalysisLabel.FontSize = 10;
            app.MergeAnalysisLabel.Layout.Row = 1;
            app.MergeAnalysisLabel.Layout.Column = 3;
            app.MergeAnalysisLabel.Text = 'ANÁLISE ACERCA DE POSSÍVEL MESCLAGEM';

            % Create MergeAnalysis
            app.MergeAnalysis = uilabel(app.GridLayout);
            app.MergeAnalysis.VerticalAlignment = 'top';
            app.MergeAnalysis.WordWrap = 'on';
            app.MergeAnalysis.FontSize = 11;
            app.MergeAnalysis.Layout.Row = 3;
            app.MergeAnalysis.Layout.Column = [3 4];
            app.MergeAnalysis.Interpreter = 'html';
            app.MergeAnalysis.Text = '<p style="margin: 10px; word-break: normal;">O processo de mesclagem requer ao menos dois fluxos espectrais.</p>';

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onOkButtonClicked, true);
            app.OkButton.Icon = 'Merge_18.png';
            app.OkButton.FontSize = 11;
            app.OkButton.Enable = 'off';
            app.OkButton.Layout.Row = 5;
            app.OkButton.Layout.Column = 4;
            app.OkButton.Text = 'Mesclar fluxos';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockFlowMerge_exported(Container, varargin)

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
