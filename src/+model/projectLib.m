classdef projectLib < dynamicprops

    % Copiar approach adotado nos outros apps... módulo de relatório atende
    % não apenas winAppAnalise:REPORT, mas todo e qualquer módulo p/ o qual
    % faça sentido um report, como auxApp.winRFDataHub, auxApp.winSignalAnalysis 
    % etc...

    properties
        %-----------------------------------------------------------------%
        name  (1,:) char   = ''
        file  (1,:) char   = ''
        issue (1,1) double = -1
        unit  (1,:) char   = ''

        documentType {mustBeMember(documentType, {'Relatório de Atividades', 'Relatório de Fiscalização', 'Informe'})} = 'Relatório de Atividades'
        documentModel  = ''
        documentScript = []
        generatedFiles = []
        externalFiles  = table( ...
            'Size', [0, 4], ...
            'VariableTypes', {'cell', 'cell', 'cell', 'int8'}, ...
            'VariableNames', {'Type', 'Tag', 'Filename', 'ID'} ...
        );
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
    end


    methods
        %-----------------------------------------------------------------%
        function obj = projectLib(mainApp, rootFolder)            
            obj.mainApp    = mainApp;
            obj.rootFolder = rootFolder;
        end


        %-----------------------------------------------------------------%
        function Restart(obj)
            obj.name           = '';
            obj.file           = '';
            obj.issue          = -1;
            obj.unit           = '';

            obj.documentType   = 'Relatório de Atividades';
            obj.documentModel  = '';
            obj.documentScript = [];
            obj.generatedFiles = [];

            customPropertiesList = obj.customProperties;
            for ii = 1:numel(customPropertiesList)
                propertyName = customPropertiesList{ii};

                switch class(obj.(propertyName))
                    case 'table'
                        obj.(propertyName)(:,:) = [];
                    case 'struct'
                        obj.(propertyName)(:)   = [];
                    case 'cell'
                        obj.(propertyName)      = {};
                    case 'char'
                        obj.(propertyName)      = '';
                    otherwise
                        obj.(propertyName)      = [];
                end
            end
        end
    end
end