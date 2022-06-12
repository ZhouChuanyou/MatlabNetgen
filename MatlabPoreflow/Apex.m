classdef Apex<handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        INF_NEG_NUM;
    	INF_POS_NUM;
    	EPSILON;
    	SMALL_NUM;
    	NEG_ALMOST_ZERO;
    	POS_ALMOST_ZERO;
    	MAX_ITR; 

    	m_parentShape;
    	m_pinnedApexDist;
    	m_hingingPcRange;
    	m_pinned;
    	m_exists;
    end
    
    methods
        function obj = Apex(apexCp,parent)
            %UNTITLED2 构造此类的实例
            %   此处显示详细说明
            if nargin ==1
                obj.m_pinned = false;
                obj.m_exists = false;
                obj.m_parentShape = apexCp;
            else
                obj.m_parentShape = parent;
                obj.m_pinnedApexDist = apexCp.m_pinnedApexDist;
                obj.m_hingingPcRange = apexCp.m_hingingPcRange;
                obj.m_pinned = apexCp.m_pinned;
                obj.m_exists = apexCp.m_exists;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

