classdef Shape<handle
    %UNTITLED16 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        MAX_NEWT_ITR;                  
        EPSILON;                       
        PI;                            
        INF_NEG_NUM;                   

        m_parent;                      
        m_commonData;                  
        m_oil;                         
        m_water;                       
        m_radius;                      
        m_shapeFactor;                 
        m_bulkFluid;                   
        m_numNeighbours;               

        m_anyOilLayers;                
        m_allOilLayers;                
        m_containsWater;               
        m_containsOil;                 
        m_virginState;                 
        m_wettingCluster;              
        m_conAngleInit;                
        m_conAngEquil;                 
        m_conAngleAdv;                 
        m_conAngleRec;                 
        m_maxConAngSpont;              
        m_area;                        
        m_areaWater;                   
        m_entryPress;                  
        m_gravityCorrection;           
        m_watCondMultFactWhenOilFilled;
        m_conductanceOil;              
        m_conductanceWater; 
        m_pistonTypeCurveRad;
        m_waterSatHistory; 
    end
    
    methods
        function obj = Shape(parent,common,oil,water,radius,shapeFactor,...
                initConAng,connNum)
            %UNTITLED16 构造此类的实例
            %   此处显示详细说明
            if nargin==8
                obj.m_parent = parent;
                obj.m_oil = oil;
                obj.m_water = water;
                obj.m_radius = radius;
                obj.m_shapeFactor = shapeFactor;
                obj.m_conAngleInit = initConAng; 
                obj.m_bulkFluid = water;
                obj.m_numNeighbours = connNum;
                obj.m_commonData = common;
                obj.m_watCondMultFactWhenOilFilled = obj.m_commonData.circWatCondMultFact();
                obj.m_containsWater = true; 
                obj.m_containsOil = false;
                obj.m_anyOilLayers = false;
                obj.m_allOilLayers = false;
                obj.m_virginState = true;
                obj.m_wettingCluster = 0;
                obj.m_conAngleAdv = 0.0;
                obj.m_conAngleRec = 0.0;
                obj.m_conAngEquil = 0.0;
                obj.m_area = power(obj.m_radius, 2.0) / ...
                    (4.0 * obj.m_shapeFactor); % From Oren; This is ~correct for all shape
                obj.m_areaWater = obj.m_area;
                assure(m_area > 0.0, "1");                
            else
                obj.m_parent = parent;
                obj.m_oil = oil;
                obj.m_water = water; 
                obj.m_radius = radius.m_radius;
                obj.m_shapeFactor = radius.m_shapeFactor;
                obj.m_conAngleInit = radius.m_conAngleInit; 
                obj.m_bulkFluid = water; 
                obj.m_numNeighbours = radius.m_numNeighbours;
                obj.m_commonData = common;    
                obj.m_conAngleRec = radius.m_conAngleRec;
                obj.m_conAngleAdv = radius.m_conAngleAdv;
                obj.m_containsWater = radius.m_containsWater;
                obj.m_containsOil = radius.m_containsOil;
                obj.m_area = radius.m_area;
                obj.m_areaWater = radius.m_areaWater;    
                obj.m_conductanceOil = radius.m_conductanceOil;
                obj.m_conductanceWater = radius.m_conductanceWater;
                obj.m_entryPress = radius.m_entryPress;
                obj.m_maxConAngSpont = radius.m_maxConAngSpont;
                obj.m_pistonTypeCurveRad = radius.m_pistonTypeCurveRad;    
                obj.m_waterSatHistory = radius.m_waterSatHistory;
                obj.m_anyOilLayers = radius.m_anyOilLayers;
                obj.m_allOilLayers = radius.m_allOilLayers;
                obj.m_watCondMultFactWhenOilFilled = radius.m_watCondMultFactWhenOilFilled;
            end            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

