classdef Fluid<handle
    %UNTITLED7 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_viscosity;
        m_interPhaseTen;
        m_resistivity;
        m_density;
    end
    
    methods
        function obj = Fluid(viscosity, interPhaseTen, resistivity,density)
            %UNTITLED7 构造此类的实例
            %   此处显示详细说明
            if (nargin==4)
                obj.m_viscosity = viscosity;
                obj.m_interPhaseTen = interPhaseTen;
                obj.m_resistivity = resistivity;
                obj.m_density = density;                
            else % 这是Fluid的第二个构造方法，viscosity实际上为fluid
                obj.m_viscosity = viscosity.m_viscosity;
                obj.m_interPhaseTen = viscosity.m_interPhaseTen;
                obj.m_resistivity = viscosity.m_resistivity;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

