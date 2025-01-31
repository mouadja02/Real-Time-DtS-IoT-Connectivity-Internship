function [dist,pos_in_M]=gridmatrixshortestpath(GridMatrix,start,stop,wf)
%--------------------------------------------------------------------------
%This function solves the shortest-path problem for a 2D lattice grids graph
%which can be represented by a matrix. For example, a 4-by-4 lattice graph
%can be represented by a 4-by-4 matrix. (One entry corresponds to one grid point)
%At every grid point, one can travel
%to its up/down/left/right side grid point, the arc-length (weight) between
%the neightboring grids is calculated by a function of the entry values in 
%the corresponding matrix. Assume the matrix is 
%Matrix = [1 4 7 6;
%          6 5 4 3;
%          1 5 2 2;
%          1 4 6 1]; 
%Also assume the traveling cost from entry i to entry j is only determined 
%by the entry value j,(wf = @(i,j)(0.*i + 1.*j)). 
%We can quickly find out that the shortest-path traveling from node(1,1) to
%node(4,4) is (1,1)-->(2,1)-->(3,1)-->(3,2)-->(3,3)-->(3,4)-->(4,4), the
%total distance is 6+1+5+2+2+1=17. (validated in Main.m). 
%This kind of problems can be solved by this function. 
%--------------------------------------------------------------------------
%Input: 
%      GridMatrix: A matrix representing the lattice graph (m-by-n)
%      wf:         Weight fucntion to calculate the arc length traveling
%                  between neighboring grids
%      start/stop: the indexes of start and target grid points
%                  e.g.,start = [1 2](p-by-2); stop = [7 9](p-by-2)
%--------------------------------------------------------------------------
%Output:
%     dist:     the shortet distance between start and stop (p-by-1)
%     pos_in_M: the shortest-path (q-by-2-by-p)
%-------------------------------------------------------------------------- 
if nargin < 4
    error('Not enough input arguments.');
end 

w = size(GridMatrix, 1); l = size(GridMatrix, 2);
if w < 2|| l < 2
    error('size of the (lattice graph) matrix is too small. Need to be bigger than 2.');
end

if size(start,1)~=size(stop,1)||size(start,2)~=size(stop,2)
    error('start and stop need to be equal size.');
end

algorithm = 'Dijkstra';% default shortest-path algorithm, only allow positive weights.
%there arae in toal w*l entries in the matrix; 
%entry at i-th row and j-th column is represented by No. l*(i-1)+j;
%No. k-th entry is located at ceil(k/l)-th row, k-l*(ceil(k/l)-1)-th column;  
%the nodes in this grid are connected with only its neighbors at...
%up,down,left and right;
%the total number of pairs is 2*(2*(w-1)*(l-1)+w-1+l-1)
pair_start = zeros(1, 2*(2*(w-1)*(l-1)+w-1+l-1));
pair_stop = zeros(1, 2*(2*(w-1)*(l-1)+w-1+l-1));
weight = zeros(1, 2*(2*(w-1)*(l-1)+w-1+l-1));
num = 1;
for m = 1:w
    for n = 1:l
        if m<=w-1&&n<=l-1
            a = l*(m-1)+n; b = l*(m-1)+n+1; c = l*m+n;
            pair_start(num:(num+3)) = [a a b c];
            pair_stop(num:(num+3)) = [b c a a];
            ks = pair_start(num:(num+3)); kb = pair_stop(num:(num+3));
            tmpweight = wf(GridMatrix(ceil(ks/l),ks-l*(ceil(ks/l)-1)), GridMatrix(ceil(kb/l),kb-l*(ceil(kb/l)-1)));
            if length(ks)~=length(tmpweight)
                error('Invalid weight function. Try using dot expression.');
            end
            weight(num:(num+3)) = diag(tmpweight);
            num = num+4;
        else if n==l&&m~=w
                a = l*m; b = l*(m+1);
                pair_start(num:(num+1)) = [a b];
                pair_stop(num:(num+1)) = [b a];
                ks = pair_start(num:(num+1)); kb = pair_stop(num:(num+1));
                tmpweight = wf(GridMatrix(ceil(ks/l),ks-l*(ceil(ks/l)-1)), GridMatrix(ceil(kb/l),kb-l*(ceil(kb/l)-1))); 
                if length(ks)~=length(tmpweight)
                    error('Invalid weight function. Try using dot expression.');
                end
                weight(num:(num+1)) = diag(tmpweight);
                num = num+2;
            else if m==w&&n~=l
                    a = l*(m-1)+n;b = l*(m-1)+n+1;
                    pair_start(num:(num+1)) = [a b];
                    pair_stop(num:(num+1)) = [b a];
                    ks = pair_start(num:(num+1)); kb = pair_stop(num:(num+1));
                    tmpweight = wf(GridMatrix(ceil(ks/l),ks-l*(ceil(ks/l)-1)), GridMatrix(ceil(kb/l),kb-l*(ceil(kb/l)-1))); 
                    if length(ks)~=length(tmpweight)
                        error('Invalid weight function. Try using dot expression.');
                    end
                    weight(num:(num+1)) = diag(tmpweight);
                    num = num+2;
                else
                end
            end
        end
    end
end

if any(isnan(weight))
    warning('NaN generated by weight function. Modify wf or specify NaN weights. NaNs are set to 1e-6 by default.');
end
weight(isnan(weight)) = 1e-06;% set NaN weight to a small value;(subjective to change upon required)

if any(weight == 0)
    warning('zero weights generated. Arc with zero weights will be eliminated. Modify wf or specify zero weights. Zeros are set to 1e-6 by default.');
end
weight(weight == 0) = 1e-06;% set zero weight to a small value;(subjective to change upon required)

if any(weight < 0)
    warning('negative weights generated. shortest-path algorithm is set to Bellman-Ford.');
    algorithm = 'Bellman-Ford';
end

DG = sparse(pair_start,pair_stop, weight,w*l,w*l);
pos_in_M = struc([]);
start1 = start(:,1); start2 = start(:,2);
stop1 = stop(:,1);stop2 = stop(:,2);
parfor i = 1:size(start,1)%parellel computing to improve speed when the number of start/stop pairs are big. 
    nodestart = l*(start1(i)-1) + start2(i);
    nodestop = l*(stop1(i)-1) + stop2(i);
    [dist(i),path,~] = graphshortestpath(DG,nodestart,nodestop,'method',algorithm);
    pos_in_M(i).path = [ceil(path/l)',(path-l*(ceil(path/l)-1))'];
end


