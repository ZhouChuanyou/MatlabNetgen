classdef RockElem<handle
    %UNTITLED5 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_shapeFactor;
        m_radius;
        m_volume;
    	m_clayVolume;
    	m_length;
    end
    
    methods
        function obj = RockElem(shapefactorR)
            %UNTITLED5 构造此类的实例
            %   此处显示详细说明
%             if nargin<1
%                 return;
%             else
                obj.m_shapeFactor = shapefactorR;
%             end
        end
        
        function radius = radius(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            radius = obj.m_radius;
        end
        
        function length = Length(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            length = obj.m_length;
        end
        
        function totVolume = totVolume(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            totVolume = obj.m_volume+obj.m_clayVolume;
        end
        
    end
end

