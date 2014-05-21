% CELL2NUM Convert a cell into a matrix
%   OUTPUT = CELL2NUM(INPUT) convert a cell INPUT to a matrix OUTPUT.
%   Given DIMCELL = size(INPUT) and DIMEL = size(INPUT{1}) the size of 
%   OUTPUT will be [DIMCELL x DIMEL].
%
%   OUTPUT = CELL2NUM(INPUT,PARAMETERS) accept the structure PARAMETERS 
%   that can optionally be used to override the default parameters.
%
%	PARAMETERS:
%   	cell_el_singleton:      If enabled eliminates singleton dimensions
%                               of DIMCELL from the OUTPUT.   
%                               [Default = 'true']
%   	cell_linearize:         If enabled squeeze all the dimensions of
%                               DIMCELL to a vector.    
%                               NOTE: cell_el_singleton became irrelevant!    
%                               [Default = 'false']
%   	el_el_singleton:        If enabled eliminates singleton dimensions
%                               of DIMEL from the OUTPUT.   
%                               [Default = 'true']
%   	el_linearize:        	If enabled squeeze all the dimensions of
%                               DIMEL to a vector.   
%                               NOTE: el_el_singleton became irrelevant!  
%                               [Default = 'false']
%
%   EXAMPLES:
%       p.cell_el_singleton     = true;
%       p.cell_linearize       	= false;
%       p.el_el_singleton       = true;
%       p.el_linearize        	= false;
%       DIMCELL => [1 3]
%       DIMEL   => [1 3]
%       OUTPUT  => [3 3]
%
%       p.cell_el_singleton     = false;
%       p.cell_linearize       	= false;
%       p.el_el_singleton       = false;
%       p.el_linearize        	= false;
%       DIMCELL => [1 3]
%       DIMEL   => [1 3]
%       OUTPUT  => [1 3 1 3]
%
%       p.cell_el_singleton     = true;
%       p.cell_linearize       	= false;
%       p.el_el_singleton       = false;
%       p.el_linearize        	= false;
%       DIMCELL => [1 3]
%       DIMEL   => [1 3]
%       OUTPUT  => [3 1 3]
%
%       p.cell_linearize       	= true;
%       p.el_el_singleton       = true;
%       p.el_linearize        	= false;
%       DIMCELL => [2 3]
%       DIMEL   => [4 3]
%       OUTPUT  => [6 4 3]
%
%       p.cell_linearize       	= true;
%       p.el_linearize        	= true;
%       DIMCELL => [2 3]
%       DIMEL   => [4 3]
%       OUTPUT  => [6 12]
%
%

%   Copyright (c) 2012 Roberto Calandra
%   $Revision: 0.61 $


function output = cell2num(input,parameters)
%% Input validation

assert(iscell(input),'INPUT is not a cell')
if exist('parameters','var')
    assert(isstruct(parameters),'PARAMETERS is not a structure')
end


%% Parameters

% Default Parameters
p.cell_el_singleton     = true;     % Eliminate every singleton dimension
p.cell_linearize       	= false;    % Convert matrix cells to linear
p.el_el_singleton       = true;     % Eliminate every singleton dimension
p.el_linearize        	= false;    % Convert matrix cells to linear

% Override default parameters with eventual passed ones
if exist('parameters','var')
    t_p = fieldnames(parameters);
    for i = 1:size(t_p,1)
        if isfield(p,t_p{i})
            p.(t_p{i}) = parameters.(t_p{i});
        else
            fprintf(2,'%s: unknown parameter passed: %s\n',mfilename,t_p{i})
        end
    end
end


%% Compute dimension cell

ncell = numel(input);

if p.cell_linearize
    dimcell = ncell;
else
    dimcell = size(input);
    if p.cell_el_singleton
        dimcell = dimcell(dimcell~=1);
    end
end


%% Compute dimension elements of cell

nel     = numel(input{1});
dimel   = size(input{1});

for i=2:ncell
    assert(isequal(size(input{i}),dimel),...
        ['size(INPUT{' num2str(i) '}) ~= size(INPUT{1})'])
end

if p.el_linearize
    dimel = nel;
else
    dimel = size(input{1});
    if p.el_el_singleton
        dimel = dimel(dimel~=1);
    end
end


%% Init output

dim = [dimcell dimel];
if numel(dim)==1
    output = zeros([1 dim]);
else
    output = zeros(dim);
end


%% Convert data

n_dim_el    = numel(dimel);
n_dim_cell  = numel(dimcell);

for i=1:ncell
    
    % Determine indeces for the cell
    if p.el_linearize
        indeces{1} = i;
        for x=2:1+n_dim_el
            indeces{x} = ':';
        end
    else
        if p.el_el_singleton 
            i_sub = cell(n_dim_cell,1);
            [i_sub{:}] = ind2sub(dimcell,i);
            for ix=1:n_dim_cell
                indeces{ix} = i_sub{ix};
            end
            for x=n_dim_cell+1:n_dim_cell+n_dim_el
                indeces{x} = ':';
            end
        else % FIXME ?
            i_sub = cell(n_dim_cell,1);
            [i_sub{:}] = ind2sub(dimcell,i);
            for ix=1:n_dim_cell
                indeces{ix} = i_sub{ix};
            end
            for x=n_dim_cell+1:n_dim_cell+n_dim_el
                indeces{x} = ':';
            end
        end
    end
    
    % Transfer the content of each cell
    if p.el_linearize
        output(indeces{:})      = Utils.linearize(input{i});
    else
        if p.el_el_singleton
            output(indeces{:})  = squeeze(input{i});
        else
            output(indeces{:})  = input{i};
        end
    end
    
end


end

