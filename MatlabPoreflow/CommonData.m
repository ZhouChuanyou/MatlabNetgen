classdef CommonData<handle
    %UNTITLED9 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_injectant;
        m_maxCappPress;
        m_maxPcLastCycle;
        m_minCappPress;
        m_minPcLastCycle;
        m_cappPress;
        m_circWatCondMultFact;
        m_gravConstX;
        m_gravConstY;
        m_gravConstZ;
        m_numPores;
        m_numThroats;
        m_drainagePhase;
        m_numSquares;
        m_numTriangles;
        m_numCircles;
        m_drainageCycle;
        m_imbibitionCycle;
        m_radiiWeights;
        m_poreFillAlg;
        m_trappedRegionsOil;
        m_trappedRegionsWat;
    end
    
    methods
        function obj = CommonData(weights,poreFillAlg,...
                circWatCondMultFact,input,gravX,gravY,gravZ)
            %UNTITLED9 构造此类的实例
            %   此处显示详细说明
            if (nargin==7)
                obj.m_gravConstX = gravX;
                obj.m_gravConstY = gravY;
                obj.m_gravConstZ = gravZ;
                obj.m_drainageCycle = 0;
                obj.m_imbibitionCycle = 1;
                obj.m_poreFillAlg = poreFillAlg;
                obj.m_radiiWeights = weights;
                obj.m_circWatCondMultFact = circWatCondMultFact;
                obj.m_maxCappPress = 0.0;
                obj.m_minCappPress = 0.0;
                obj.m_maxPcLastCycle = 0.0;
                obj.m_minPcLastCycle = 0.0;
                obj.m_numSquares = 0;
                obj.m_numTriangles = 0;
                obj.m_numCircles = 0;
                obj.m_injectant = 0;
                obj.m_cappPress = 0;
                obj.m_drainagePhase = false;
                % dbgOut.open("debug.out");   // delete me
            else  % weights实际上为data的意思，这是CommonData的第二个构造函数
                obj.m_numPores = weights.m_numPores;
                obj.m_numThroats = weights.m_numThroats; 
                obj.m_gravConstX = weights.m_gravConstX;
                obj.m_gravConstY = weights.m_gravConstY;
                obj.m_gravConstZ = weights.m_gravConstZ;
                obj.m_injectant = weights.m_injectant;
                obj.m_maxCappPress = weights.m_maxCappPress;
                obj.m_minCappPress = weights.m_minCappPress;
                obj.m_maxPcLastCycle = weights.m_maxPcLastCycle;
                obj.m_minPcLastCycle = weights.m_minPcLastCycle;
                obj.m_numSquares = weights.m_numSquares;
                obj.m_numTriangles = weights.m_numTriangles;
                obj.m_numCircles = weights.m_numCircles;
                obj.m_radiiWeights = weights.m_radiiWeights;
                obj.m_poreFillAlg = weights.m_poreFillAlg; 
                obj.m_circWatCondMultFact = weights.m_circWatCondMultFact; 
                obj.m_cappPress = weights.m_cappPress;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

