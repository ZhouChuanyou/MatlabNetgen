classdef LayerApex<handle & Apex
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_innerApex;
    	m_trappedOutside;
    	m_advConAng;
    	m_stable;
    	m_stateChangePc;
    	m_gravityCorrection;
    	m_collapsePc;
    	m_isInCollapseVec;
    	m_isInReformVec;
    end
    
    methods
        function obj = LayerApex(innerApex,layerCp, parent)
            %UNTITLED3 构造此类的实例
            %   此处显示详细说明
            obj = obj@Apex(layerCp);
            if nargin ==3
                obj = Apex(layerCp, parent);
                obj.m_innerApex = innerApex;
                obj.m_collapsePc = layerCp.m_collapsePc; 
                obj.m_trappedOutside = layerCp.m_trappedOutside; 
                obj.m_stable = layerCp.m_stable;
                obj.m_isInCollapseVec = false;
                obj.m_isInReformVec = false;
            else%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %obj = Apex(layerCp);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.m_innerApex = innerApex;
                obj.m_gravityCorrection = 0.0;
                obj.m_trappedOutside = containers.Map(false, 0.0);
                obj.m_advConAng = 0.0;
                obj.m_stable = false;
                obj.m_stateChangePc = 0.0;
            end            
        end
        
        function isInCollapseVec=isInCollapseVec(obj,isIt)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            if nargin ==2
                obj.m_isInCollapseVec = isIt;
                isInCollapseVec = obj.m_isInCollapseVec;
            else
                isInCollapseVec=obj.m_isInCollapseVec;
            end            
        end
    
        function isInReformVec = isInReformVec(obj,isIt)
            if nargin == 2
                obj.m_isInReformVec = isIt;
                isInReformVec = obj.m_isInReformVec;
            else
                isInReformVec = obj.m_isInReformVec;
            end
        end
    end
end

