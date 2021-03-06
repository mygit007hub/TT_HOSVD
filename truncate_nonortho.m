function A_star = truncate_nonortho(A, r, dir)
%   TRUNCATE algorithm from TTeMPS Toolbox without orthogonalization step
%   Michael Steinlechner, 2013-2016
%   Davide Pradovera, 2017
    if ~exist('dir', 'var')
        dir = 'right';
    end
    if ~strcmpi(dir, 'right') && ~strcmpi(dir, 'left') 
        error('Unknown direction specified. Choose either LEFT or RIGHT') 
    end
    
    d = A.order;
    if numel(r) == 1
        r = [1, repmat(r, 1, d-1), 1];
    elseif numel(r) == d + 1
        r([1,end]) = 1;
    else
        error('Wrong format for the target TT-ranks. It must either be a scalar or a vector of length (A.order + 1)') 
    end
    A_star = A;
    
    if strcmpi(dir, 'right')
        for i = d:-1:2
            [U,S,V] = svd(unfold(A_star.U{i}, 'right'), 'econ');
            rEff = min(r(i), length(S));
            U = U(:,1:rEff);
            V = V(:,1:rEff);
            S = S(1:rEff,1:rEff);
            A_star.U{i} = reshape(V', [rEff, A_star.size(i), A_star.rank(i+1)]);
            A_star.U{i-1} = tensorprod(A_star.U{i-1}, (U*S)', 3);
        end
    else %if strcmpi(dir, 'left') 
        for i = 1:d-1
            [U,S,V] = svd(unfold(A_star.U{i}, 'left'), 'econ');
            rEff = min(r(i + 1), length(S));
            U = U(:,1:rEff);
            V = V(:,1:rEff);
            S = S(1:rEff,1:rEff);
            A_star.U{i} = reshape(U, [A_star.rank(i), A_star.size(i), rEff]);
            A_star.U{i+1} = tensorprod(A_star.U{i+1}, S*V', 1);
        end
    end
end
