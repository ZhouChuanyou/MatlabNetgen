classdef ThreeSome<handle
    % A little storage class for three eleemnts
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_first;
        m_second;
        m_third;
    end
    
    methods
        function obj = ThreeSome(one,two,three)
            %UNTITLED 构造此类的实例
            %   此处显示详细说明
            obj.m_first = one;
            obj.m_second= two;
            obj.m_third = three;
        end
        
        function first = first(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            if nargin==1
                obj.m_first = entry;
            else
                first = obj.m_first;
            end
            
        end
        
        function second = second(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            if nargin==1
                obj.m_second = entry;
            else
                second = obj.m_second;
            end
        end
        
        function third = third(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            if nargin==1
                obj.m_third = entry;
            else
                third = obj.m_third;
            end
        end
    end
end

