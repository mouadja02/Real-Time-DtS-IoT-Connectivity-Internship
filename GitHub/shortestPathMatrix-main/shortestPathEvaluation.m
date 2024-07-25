% parameters to test
N = 8;
p_connected = 0.2;
max_val = 10;

n_trials = 1000;
correct_result = zeros(n_trials, 1);
for trial = 1:n_trials

% Set up Adjacency Matrix

R_rand = round(rand(N) .* max_val ./ p_connected) + 1;
inverse_I = ones(N) - diag(repmat(1, [1, N]));

R_zero_diag = R_rand .* inverse_I;

R_disconnected = R_zero_diag;
R_disconnected(R_zero_diag > max_val) = Inf;

R_symmetric = triu(R_disconnected) + triu(R_disconnected).';

A = R_symmetric;

% Eykamp Matrix
p = 14;

B = exp(-p .* A);
D = -log(B^N) ./ p;

D_int = round(D);

% Create Graph and find shortest paths
G = graph(A);

correct = zeros(N, N);
for ii = 1:N
    for jj = 1:N
        [path, d] = shortestpath(G, ii, jj);
        correct(ii, jj) = d;
    end
end

result = all(D_int == correct, 'all');
if result ~= 1
    A
    D_int
    correct
    x = 1;
end
correct_result(trial) = result;

end

accuracy = mean(correct_result)