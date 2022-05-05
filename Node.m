% All connection are aligned in an right handed coord syst, with 
% connections going from 0 to 5 (0:i+, 1:j+, 2:k+, 3:i-, 4:j-, 5:k- 
% 
%                    2   1
%                    | /
%                3 --|--  0
%                   /|
%                 4  5
% 
classdef Node<handle
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        %The node position in physical space
        m_xLoc;
        m_yLoc;
        m_zLoc;
        % The node coordinate
        m_i;
        m_j;
        m_k;
        %The size of the lattice
        m_nX;
        m_nY;
        m_nZ;
        % Is the node inlet or outlet node
        m_isInlet;
        m_isOutlet;
        %Is the node at inlet or outlet
        m_isAtInlet;
        m_isAtOutlet;
        % Is node outside lattice
        m_isOutsideLattice;
        % Single consecutive index
        m_index;
    end
    
    methods
        
        % Various constructors for the node class. The node class does make an 
        % assumption about the cubic structure of the network when determening
        % if a node is within the network or not.        
        function obj = Node(i,j,k,nX,nY,nZ)
            if (nargin<6)
                obj.m_nX=j;
                obj.m_nY=k;
                obj.m_nZ=nX;
                if i==0
                    obj.m_i = 0;
                    obj.m_j = 1;
                    obj.m_k = 1;
                elseif i==obj.m_nX*obj.m_nY*objm_nZ + 1+1 % +1 !!!!! 
                    obj.m_i = obj.m_nX+1;
                    obj.m_j = 1;
                    obj.m_k = 1;
                else
                    obj.m_k = (i-1)/(obj.m_nX*obj.m_nY) + 1;
                    obj.m_j = ((i-1) - (obj.m_k-1)*(obj.m_nX*obj.m_nY))/...
                        obj.m_nX + 1;
                    obj.m_i = i - (obj.m_k-1)*(obj.m_nX*obj.m_nY) - ...
                        (obj.m_j-1)*obj.m_nX;
                end
            else
                obj.m_i=i;
                obj.m_j=j;
                obj.m_k=k;
                obj.m_nX=nX;
                obj.m_nY=nY;
                obj.m_nZ=nZ;
            end
            obj.initNode();
        end
        
        % The node is initialized by determening if it is inside the network,
        % outside or an in/outlet.        
        function initNode(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            % We are inside lattice
            if obj.m_i>0 && obj.m_i<=obj.m_nX && ...
                    obj.m_j>0 && obj.m_j<= obj.m_nY &&...
                    obj.m_k>0 && obj.m_k<=obj.m_nZ
                obj.m_isOutsideLattice=false;
                obj.m_isInlet = false;
                obj.m_isOutlet = false;
                obj.m_isAtInlet = (obj.m_i == 1);
                obj.m_isAtOutlet = (obj.m_i == obj.m_nX);
                
                obj.m_index = (obj.m_k-1)*(obj.m_nX*obj.m_nY) + ...
                    (obj.m_j-1)*obj.m_nX + obj.m_i+1; % +1
            
            % Inlet node
            elseif obj.m_i == 0 && ...
                    obj.m_j > 0 && obj.m_j <= obj.m_nY &&...
                    obj.m_k > 0 && obj.m_k <= obj.m_nZ
                obj.m_isOutsideLattice=false;
                obj.m_isInlet = true;
                obj.m_isOutlet = false;
                obj.m_isAtInlet = false;
                obj.m_isAtOutlet = false;
                
                obj.m_index = 0+1; % +1
                
            %Outlet node    
            elseif obj.m_i == (obj.m_nX + 1) &&...
                    obj.m_j > 0 && obj.m_j <= obj.m_nY &&...
                    obj.m_k > 0 && obj.m_k <= obj.m_nZ
                obj.m_isOutsideLattice = false;  % Outlet node
                obj.m_isInlet = false;
                obj.m_isOutlet = true;
                obj.m_isAtInlet = false;
                obj.m_isAtOutlet = false;
                
                obj.m_index = obj.m_nX * obj.m_nY * obj.m_nZ + 1+1; % +1
            else
                % We are outside lattice
                obj.m_isOutsideLattice=true;
                obj.m_isInlet = false;
                obj.m_isOutlet = false;
                obj.m_isAtInlet = false;
                obj.m_isAtOutlet = false;
                
                obj.m_index = obj.m_nX * obj.m_nY * obj.m_nZ + 1+1+1; % 
            end
            
        end
        
        function isInOrOutlet = isInOrOutlet(obj)
            isInOrOutlet = obj.m_isInlet || obj.m_isOutlet;
        end
        
        function index = index(obj)
            index = obj.m_index;
        end
        
        % Return the next node index given a node and a direction. If the next
        % node is outside the lattice an index of -1 is returned. If a pores is
        % on a boundary (not in/outlet) the index on the other side is returned
        % ie periodic boundary conditions.
        function nextIndex = nextIndex(obj,conn,pbcConn)  % 鉴定正确
            nextIndex = -1;
            pbcConn = false;
            assignin('base','pbcConn',false);
            switch conn
                case 0
                    if obj.m_i == obj.m_nX  %// iPluss
                        nextIndex = obj.m_nX * obj.m_nY * obj.m_nZ + 1+1;% Outlet +1
                    elseif obj.m_i>=1 && obj.m_i < obj.m_nX
                        nextIndex = obj.m_index + 1; 
                    end
                    % assignin('base','pbcConn',false);
                    return;
                case 1
                    if obj.m_j == obj.m_nY
                        pbcConn = true;
                        assignin('base','pbcConn',true);
                        nextIndex = obj.m_index - obj.m_nX * (obj.m_nY-1);
                    elseif obj.m_j >= 1 && obj.m_j < obj.m_nY
                        nextIndex = obj.m_index + obj.m_nX;
                        % assignin('base','pbcConn',false);
                    end
                    return;
                case 2
                    if obj.m_k == obj.m_nZ
                        pbcConn = true;
                        assignin('base','pbcConn',true);
                        nextIndex = obj.m_index - obj.m_nX * obj.m_nY *...
                            (obj.m_nZ-1);
                    elseif obj.m_k >= 1 && obj.m_k < obj.m_nZ
                        nextIndex = obj.m_index + obj.m_nX * obj.m_nY;                        
                        % assignin('base','pbcConn',false);
                    end
                    return;
                case 3
                    if obj.m_i == 1
                        nextIndex = 0+1; % +1 !!!!!
                    elseif obj.m_i > 1 && obj.m_i <= obj.m_nX
                        nextIndex = obj.m_index - 1;
                    end
                    % assignin('base','pbcConn',false);
                    return;
                case 4
                    if obj.m_j == 1
                        pbcConn = true;
                        assignin('base','pbcConn',true);
                        nextIndex = obj.m_index + obj.m_nX * (obj.m_nY-1);
                    elseif obj.m_j > 1 && obj.m_j <= obj.m_nY
                        nextIndex = obj.m_index - obj.m_nX;
                        % assignin('base','pbcConn',false);
                    end
                    return;
                case 5
                    if obj.m_k == 1
                        pbcConn = true;
                        assignin('base','pbcConn',true);
                        nextIndex = obj.m_index + obj.m_nX * obj.m_nY *...
                            (obj.m_nZ-1);
                    elseif obj.m_k > 1 && obj.m_k <= obj.m_nZ
                        nextIndex = obj.m_index - obj.m_nX * obj.m_nY;
                        % assignin('base','pbcConn',false);
                    end
                    return;
                otherwise
                    error('Error: Crap programmer...');
            end
        end
        
        function mi = mi(obj)
            mi = obj.m_i;
        end
        
        function mj = mj(obj)
            mj = obj.m_j;
        end
        
        function mk = mk(obj)
            mk = obj.m_k;
        end
        
        function setLocation(obj,xDim, yDim, zDim, avrThroatLen)
            intXDim=xDim-avrThroatLen;
            intYDim=yDim-avrThroatLen;
            intZDim=zDim-avrThroatLen;
            if obj.m_nX > 1
                obj.m_xLoc = (intXDim/(obj.m_nX-1))*(obj.m_i-1)+...
                    avrThroatLen/2.0;
            else
                obj.m_xLoc = xDim/2.0;
            end
            if obj.m_nY > 1
                obj.m_yLoc = (intYDim/(obj.m_nY-1))*(obj.m_j-1)+...
                    avrThroatLen/2.0;
            else
                obj.m_yLoc = yDim/2.0;
            end
            if obj.m_nZ > 1
                obj.m_zLoc = (intZDim/(obj.m_nZ-1))*(obj.m_k-1)+...
                    avrThroatLen/2.0;
            else
                obj.m_zLoc = zDim/2.0;
            end
        end
        
        % In/outlet internally has indecies 0 and numPores+1. However when
        % writing the data to file this has to be changed to -1 and 0 to
        % be compatible with Oren's data format
        function indexOren = indexOren(obj)
            if obj.m_isInlet
                indexOren = -1;
            elseif obj.m_isOutlet
                indexOren = 0;
            else
                indexOren = obj.m_index-1; % 这个-1完全是为了和作者node结构形式保持一致，其实这个在MATLAB中是不能-1的
            end
            
        end
        
        function isAtInlet = isAtInlet(obj)
            isAtInlet = obj.m_isAtInlet;            
        end
        
        function isAtOutlet = isAtOutlet(obj)
            isAtOutlet = obj.m_isAtOutlet;            
        end
        
    end
end
