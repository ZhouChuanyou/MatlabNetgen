classdef Node<handle
    %UNTITLED12 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_index; % Single consecutive index
        m_numPores; % The size of the lattice
        m_xPos; % he node coordinate
        m_yPos;
        m_zPos; 
        m_exitSeparation;  % 
        m_isEntryRes;  % Is the node inlet or outlet node
        m_isExitRes;
        m_isOutsideLattice;  % Is node outside lattice
        m_optimizedIndex;  % In order to reduce bandwidth
        m_oldIndex;  
        
    end
    
    methods
        function obj = Node(index,numPores,xPos,yPos,zPos,exitSeparation)
            %UNTITLED12 构造此类的实例
            %   此处显示详细说明
            obj.m_index = index;
            obj.m_numPores = numPores;
            obj.m_xPos = xPos;
            obj.m_yPos = yPos;
            obj.m_zPos = zPos;
            obj.m_optimizedIndex = -1;
            obj.m_oldIndex = index;
            obj.m_exitSeparation = exitSeparation;
            if m_index == 0+1 % +1
                obj.m_isOutsideLattice = false;   % We are at inlet face
                obj.m_isEntryRes = true;
                obj.m_isExitRes = false;
            elseif obj.m_index == obj.m_numPores + 1 +1
                obj.m_isOutsideLattice = false;  % We are at outlet face
                obj.m_isEntryRes = false;
                obj.m_isExitRes = true;
            elseif obj.m_index > 0+1 && obj.m_index <= m_numPores+1
                obj.m_isOutsideLattice = false;  % We are inside network
                obj.m_isEntryRes = false;
                obj.m_isExitRes = false;
            else
                obj.m_isOutsideLattice = true;  %  We are outside lattice
                obj.m_isEntryRes = false;
                obj.m_isExitRes = false;
            end
        end
        
        % Constructor for the node class. Inlet node has index == 0 whereas outlet
        % has the index has index == numPores + 1 If node is recognised to be inlet 
        % or outlet reservoir the x location is moved outside the reservoir to prevent 
        % them having the same x coord as the first line of pores (which usually are 
        % at 0.0 or xSize. This is required for these to be recognised as in/outlet
        % if boxsize is set to be 1.0.
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

