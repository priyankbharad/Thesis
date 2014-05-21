% LINEARIZE Linearize a matrix to a vector
%   Y = LINEARIZE(X) Linearize a matrix X to a vector Y of dimensions
%   [numel(X) 1].
%

%   Copyright (c) 2011 Roberto Calandra
%   $Revision: 0.20 $


function Y = linearize(X)

Y = reshape(X,[numel(X) 1]);

end

