function X = rlh(N, k, Edges)
%% Generates a random Latin hypercube within the [0,1]^k hypercube.
% Code written by Bach Do, Kyoto University.

% Note: X is transformed from its physical space into the normalized space of [0,1]^k
% by (X-Xmin)/(Xmax-Xmin).

% INPUTS:
% N – desired number of data points.
% k – number of design variables (dimension of design variable vector X)
% Edges – if Edges = 1 the extreme bins will have their centres
% on the edges of the domain, otherwise the bins will
% be entirely contained within the domain (default setting).
%
% OUTPUT:
% X – Latin hypercube sampling plan of N points in k dimensions.

if nargin<3
Edges=0;
end

% Pre – allocate memory.
X=zeros (N,k);

for i=1:k
X(:,i)=randperm(N)';
end

if Edges==1
X=(X-1)/(N-1);
else
X=(X-0.5)/N;
end