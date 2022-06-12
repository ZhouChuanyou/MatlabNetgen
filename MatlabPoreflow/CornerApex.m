classdef CornerApex<handle & Apex
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_initConAng;
    	m_trappedInside;
    	m_initApexDist;
    	m_initPinningPc;
    	m_pinnedCalled;
    end
    
    methods
        function obj = CornerApex(initConAng, parent,flag)
            %UNTITLED 构造此类的实例
            %   此处显示详细说明
            obj = obj@Apex(parent);
            if flag==1
                obj.m_initConAng = initConAng;
                obj.m_trappedInside = containers.Map(false, 0.0);
                obj.m_pinnedCalled = false;
                obj.m_initPinningPc = 0.0;
            else
%对 'Apex' 的超类构造函数调用不能为有条件调用，也不能为另一个表达式的一部分。
%               obj = obj@Apex(cornerCp, parent); 
                obj.m_initConAng = cornerCp.m_initConAng;
                obj.m_trappedInside = cornerCp.m_trappedInside;
                obj.m_initApexDist = cornerCp.m_initApexDist;
                obj.m_initPinningPc = cornerCp.m_initPinningPc;
                obj.m_pinnedCalled = cornerCp.m_pinnedCalled;
            end            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

