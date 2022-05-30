classdef RockElem<handle
    %UNTITLED13 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        ERROR_STATE;    
        USE_GRAV_IN_KR; 
        COND_CUT_OFF;   
        PI;             

        m_randomNum;    
        m_iAmAPore;     
        m_commonData;   
        m_netVolume;    
        m_clayVolume;   
        m_connectionNum;

        m_connections;  
        m_elemShape;    
        m_volumeWater;
        m_waterSaturation;
        m_averageAspectRatio;          
        m_minAspectRatio;              
        m_maxAspectRatio;              
        m_isInsideSolverBox;           
        m_isInsideSatBox;              
        m_isOnInletSlvrBdr;            
        m_isOnOutletSlvrBdr;           
        m_isExitRes;                   
        m_isEntryRes;                  
        m_isInWatFloodVec;             
        m_isInOilFloodVec;             
        m_connectedToNetwork;          
        m_isTrappingExit;              
        m_isTrappingEntry;             
        m_connectedToEntryOrExit;      
        m_canBePassedToSolver;         
        m_touchedInSearch;             
        m_poreToPoreCond;              
        m_trappingIndexOil;            
        m_trappingIndexWatBulk;        
        m_trappingIndexWatFilm;        
        m_numOilNeighbours;            
        m_fillingEvent; 
    end
    
    methods
        function obj = RockElem(common,oil,water,radius,volume,volClay,...
                shapeFact,initConAng,connNum,amPore)
            %UNTITLED13 构造此类的实例
            %   此处显示详细说明
            if nargin==10
                obj.m_commonData = common;
                obj.m_netVolume = volume;
                obj.m_clayVolume = volClay;
                obj.m_connectionNum = connNum;
                obj.m_iAmAPore = amPore;
                obj.m_randomNum = randi(2000000000);
                obj.m_volumeWater = obj.m_netVolume + obj.m_clayVolume;
                obj.m_waterSaturation = 1.0;
                obj.m_isInsideSolverBox = false;
                obj.m_isInsideSatBox = false;
                obj.m_isInWatFloodVec = false;
                obj.m_isInOilFloodVec = false;
                obj.m_isOnInletSlvrBdr = false;
                obj.m_isOnOutletSlvrBdr = false;
                obj.m_isExitRes = false;
                obj.m_isEntryRes = false;
                obj.m_isInWatFloodVec = false;
                obj.m_isInOilFloodVec = false;
                obj.m_connectedToNetwork = false;
                obj.m_isTrappingExit = false;
                obj.m_isTrappingEntry = false;
                obj.m_connectedToEntryOrExit = false;
                obj.m_canBePassedToSolver.first = false;
                obj.m_canBePassedToSolver.second = false;
                obj.m_touchedInSearch.first = false;
                obj.m_touchedInSearch.second = false;
                obj.m_trappingIndexOil.first = -1;
                obj.m_trappingIndexOil.second = 0.0;
                obj.m_trappingIndexWatBulk.first = -1;
                obj.m_trappingIndexWatBulk.second = 0.0;
                obj.m_trappingIndexWatFilm.first = -1;
                obj.m_trappingIndexWatFilm.second = 0.0;
                obj.m_poreToPoreCond = 0.0;
                obj.m_numOilNeighbours = 0;
                obj.m_fillingEvent = -2;
                if shapeFact <= sqrt(3.0)/36.0  % Triangular:  0 >= G >= sqrt(3.0)/36.0
                    obj.m_elemShape = Triangle(obj,obj.m_commonData, oil,...
                        water, radius, shapeFact, initConAng, obj.m_connectionNum);
                elseif shapeFact < 0.07  % Square:      G == 1.0/16/0 
                    obj.m_elemShape = Square(obj,obj.m_commonData,oil,water,...
                        radius,initConAng, obj.m_connectionNum);
                else   %  Circular:    G == 1.0/4.0*PI
                    obj.m_elemShape = Circle(obj, obj.m_commonData,oil,...
                        water, radius, initConAng, obj.m_connectionNum);
                end
            else  % radius实际上是rockelem,这是第二个构造函数
                obj.m_commonData = common;
                obj.m_netVolume = radius.m_netVolume; 
                obj.m_clayVolume = radius.m_clayVolume;
                obj.m_connectionNum = radius.m_connectionNum;
                obj.m_iAmAPore = radius.m_iAmAPore;
                obj.m_randomNum = radius.m_iAmAPore;
                obj.m_volumeWater = radius.m_volumeWater; 
                obj.m_waterSaturation = radius.m_waterSaturation;
                obj.m_isInsideSolverBox = radius.m_isInsideSolverBox;
                obj.m_isInsideSatBox = radius.m_isInsideSatBox;
                obj.m_isOnInletSlvrBdr = radius.m_isOnInletSlvrBdr;
                obj.m_isOnOutletSlvrBdr = radius.m_isOnOutletSlvrBdr;
                obj.m_isExitRes = radius.m_isExitRes;
                obj.m_isEntryRes = radius.m_isEntryRes;
                obj.m_isInWatFloodVec = radius.m_isInWatFloodVec;
                obj.m_isInOilFloodVec = radius.m_isInOilFloodVec;
                obj.m_connectedToNetwork = radius.m_connectedToNetwork;
                obj.m_isTrappingExit = radius.m_isTrappingExit;
                obj.m_isTrappingEntry = radius.m_isTrappingEntry;
                obj.m_connectedToEntryOrExit = radius.m_connectedToEntryOrExit;
                obj.m_canBePassedToSolver = radius.m_canBePassedToSolver;
                obj.m_touchedInSearch = radius.m_touchedInSearch;
                obj.m_trappingIndexOil = radius.m_trappingIndexOil;
                obj.m_trappingIndexWatBulk = radius.m_trappingIndexWatBulk;
                obj.m_trappingIndexWatFilm = radius.m_trappingIndexWatFilm;
                obj.m_numOilNeighbours = radius.m_numOilNeighbours;
                obj.m_fillingEvent = radius.m_fillingEvent;
                obj.m_averageAspectRatio = radius.m_averageAspectRatio;
                obj.m_minAspectRatio = radius.m_minAspectRatio;
                obj.m_maxAspectRatio = radius.m_maxAspectRatio;
                if ~isempty(radius.m_elemShape)
                    obj.m_elemShape = Triangle(obj,obj.m_commonData,oil,...
                        water, radius.m_elemShape);
                elseif ~isempty(radius.m_elemShape)
                    obj.m_elemShape = Square(obj,obj.m_commonData,oil,...
                        water,radius.m_elemShape);
                else
                    obj.m_elemShape = Circle(obj,obj.m_commonData,oil,...
                        water,radius.m_elemShape);
                end
                
            end
        end
    end
    
    methods(Static)
        function USE_GRAV_IN_KR = useGravInKr(soAreWe)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            % global USE_GRAV_IN_KR;
            USE_GRAV_IN_KR = soAreWe;
        end
        
        function COND_CUT_OFF = conductanceCutOff(cutOffVal)
            COND_CUT_OFF = cutOffVal;
        end
    end
    
end

