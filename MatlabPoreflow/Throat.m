classdef Throat<handle & RockElem
    %UNTITLED19 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_latticeIndex;
        m_originalPoreLengths;
        m_poreLength;
        m_length;
    end
    
    methods
        function obj = Throat(common,oil,water,radius,volume,volumeClay,...
                shapeFactor,initConAng,length,lengthPore1,lengthPore2,index)
            %UNTITLED19 构造此类的实例
            %   此处显示详细说明
            obj = obj@RockElem(common,oil,water,radius,volume,volumeClay,...
                shapeFactor,initConAng,2,false);
            if nargin==12
                %                 obj = RockElem(common,oil,water,radius,volume,...
                %                 volumeClay,shapeFactor,initConAng,2,false);
                
                obj.m_latticeIndex = index;
                obj.m_length = length;
                obj.m_poreLength{end+1} = lengthPore1;
                obj.m_poreLength{end+1} = lengthPore2;
                obj.m_originalPoreLengths = 0;
            else  % 这里radius代表的是throat，这是Throat的第二个构造函数
                obj = RockElem(common,oil,water,radius);
                obj.m_latticeIndex = radius.m_latticeIndex;
                obj.m_connectedToEntryOrExit = radius.m_connectedToEntryOrExit;
                obj.m_poreLength = radius.m_poreLength;
                obj.m_length = radius.m_length;
            end
        end
        
        % The connecting pores are added to the throat. From the pores it is also
        % possible to determine if the throat is inside the calculation box. If part of
        % the connection (pore-throat-pore) is outside the calculation box that lenght
        % is set to zero. This has the effect when solving the pressure field, no
        % pressure loss occurs outside the box. However if the pore inside the box itself
        % is on the boundary, pressure losses do occur within that pore. This constraint
        % is needed in the case we're using the whole network for rel perm calculations.
        % The first pores are usually located at x position 0.0. These are still within
        % the box. There has to be some length to the outlet to make the problem
        % solveable, hence we allow pressure drop to occur within that pore.
        function addConnections(obj,first,second,inletBdr,outletBdr,moveBoundary)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            if first.isEntryRes() || first.isExitRes()
                obj.m_elemShape.setGravityCorrection(second.node());
            elseif second.isEntryRes() || second.isExitRes()
                obj.m_elemShape.setGravityCorrection(first.node());
            else
                obj.m_elemShape.setGravityCorrection(first.node(),second.node());
            end
            if first.isEntryRes() || second.isEntryRes()
                obj.m_isTrappingEntry = true;
                first.isTrappingEntry(first.isEntryRes());
                second.isTrappingEntry(second.isEntryRes());
            elseif first.isExitRes() || second.isExitRes()
                obj.m_isTrappingExit = true;
                first.isTrappingExit(first.isExitRes());
                second.isTrappingExit(second.isExitRes());
            end
            obj.m_isInsideSolverBox=first.isInsideSolverBox()||second.isInsideSolverBox();
            obj.m_isInsideSatBox=first.isInsideSatBox()||second.isInsideSatBox();
            obj.m_connectedToEntryOrExit=first.isExitOrEntryRes()||second.isExitOrEntryRes();
            oldPOneLen = obj.m_poreLength{1};
            oldPTwoLen = obj.m_poreLength{2};
            oldThrLen = obj.m_length;
            if obj.m_isInsideSolverBox && ~second.isInsideSolverBox()
                second.isOnInletSlvrBdr(second.node().xPos() < inletBdr);
                second.isOnOutletSlvrBdr(second.node().xPos() > outletBdr);
                if moveBoundary
                    scaleFact=(second.node().xPos()-first.node().xPos())/...
                        (obj.m_length+obj.m_poreLength{1}+obj.m_poreLength{2});
                    if second.isExitOrEntryRes()% We don't know position of exit and entry res.
                        scaleFact=(second.node().xPos()-first.node().xPos())...
                            /abs(second.node().xPos()-first.node().xPos());
                    end
                    if second.node().xPos() < inletBdr
                        bdr = inletBdr;
                    else
                        bdr = outletBdr;
                    end
                    throatStart=first.node().xPos()+obj.m_poreLength{1}*scaleFact;
                    throatEnd = throatStart + obj.m_length*scaleFact;
                    obj.m_originalPoreLengths = cell(1,3);
                    obj.m_originalPoreLengths{1} = obj.m_poreLength{1};
                    obj.m_originalPoreLengths{2} = obj.m_length;
                    obj.m_originalPoreLengths{3} = obj.m_poreLength{2};
                    % Keep throat lengths if whole model is being used
                    % for calculations. Both pore1 and throat are within the box
                    % Onle pore 1 is fully within box.Pore 1 is only partially within box
                    if second.isExitOrEntryRes()
                        obj.m_poreLength{1+1} = 0.0;
                    elseif throatEnd > inletBdr && throatEnd < outletBdr
                        obj.m_poreLength{1+1} =obj.m_poreLength{1+1}*...
                            (bdr - throatEnd)/(obj.m_poreLength{1+1}*scaleFact);
                    elseif throatStart > inletBdr && throatStart < outletBdr
                        obj.m_poreLength{1+1} = 0.0;
                        obj.m_length =obj.m_length*(bdr - throatStart)/...
                            (obj.m_length*scaleFact);
                    else
                        obj.m_poreLength{1+1} = 0.0;
                        obj.m_length = 0.0;
                    end
                end
                % Pore 1 is outside box
            elseif obj.m_isInsideSolverBox && ~first.isInsideSolverBox()
                first.isOnInletSlvrBdr(first.node().xPos() < inletBdr);
                first.isOnOutletSlvrBdr(first.node().xPos() > outletBdr);
                if moveBoundary
                    scaleFact=(first.node().xPos()-second.node().xPos())/...
                        (obj.m_length+obj.m_poreLength{0+1}+obj.m_poreLength{1+1});
                    % We don't know position of exit and entry res.
                    if first.isExitOrEntryRes()
                        scaleFact=(first.node().xPos()-second.node().xPos())/...
                            abs(first.node().xPos()-second.node().xPos());
                    end
                    if first.node().xPos() < inletBdr
                        bdr = inletBdr;
                    else
                        bdr = outletBdr;
                    end
                    throatStart=second.node().xPos()+obj.m_poreLength{1+1}*scaleFact;
                    throatEnd = throatStart + obj.m_length*scaleFact;
                    obj.m_originalPoreLengths = cell(1,3);
                    obj.m_originalPoreLengths{0+1} = obj.m_poreLength{0+1};
                    obj.m_originalPoreLengths{1+1} = obj.m_length;
                    obj.m_originalPoreLengths{2+1} = obj.m_poreLength{1+1};
                    if first.isExitOrEntryRes()
                        obj.m_poreLength{0+1} = 0.0;
                        % Both pore 2 and throat are within the box
                    elseif throatEnd > inletBdr && throatEnd < outletBdr
                        obj.m_poreLength{0+1}=obj.m_poreLength{0+1}*...
                            (bdr-throatEnd)/(obj.m_poreLength{0+1}*scaleFact);
                        % Only pore 2 is fully within box
                    elseif throatStart>inletBdr && throatStart<outletBdr
                        obj.m_poreLength{0+1} = 0.0;
                        obj.m_length=obj.m_length*(bdr - throatStart)/...
                            (obj.m_length*scaleFact);
                    else
                        obj.m_poreLength{0+1} = 0.0;
                        obj.m_length = 0.0;
                    end
                end
            end
            if obj.m_poreLength{0+1}>1.1*oldPOneLen || ...
                    obj.m_poreLength{1+1}>1.1*oldPTwoLen || ...
                    obj.m_length > 1.1*oldThrLen
                fprintf('\r\nWarning: The new lengths for elements connected\r\n');
                fprintf('to the pressure boundary are larger than the\r\n');
                fprintf('original ones. The lengths should be smaller\r\n');
                fprintf('since we do not want pressure drops occuring\r\n');
                fprintf('outside the box across which we are calculating\r\n');
                fprintf('relative permeability.\r\n');
            end
            obj.m_connections{end+1} = first;  % Add pore connections
            obj.m_connections{end+1} = second;
            minRad =100;
            maxRad =0.0;
            radSum = 0.0;
            for i = 1:size(obj.m_connections,2)
                rad = obj.m_connections{i}.shape().radius();
                minRad = min(minRad, rad);
                maxRad = max(minRad, rad);
                radSum =radSum+rad;
            end
            obj.m_averageAspectRatio = obj.m_elemShape.radius()*...
                size(obj.m_connections,2)/radSum;
            obj.m_maxAspectRatio = obj.m_elemShape.radius()/maxRad;
            obj.m_minAspectRatio = obj.m_elemShape.radius()/minRad;
        end
        
        function node = node(obj)
            fprintf('No node associated with throats\r\n');
            node = obj.m_connections{1}.node();  % 调换了和exit位置
            exit;
        end
    end
end

