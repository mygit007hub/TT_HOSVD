function [Z, r] = round_hada_TT_randomized(X, Y, ep, step, dir, tolR, rbase)
    if ~exist('step', 'var')
        step = 1;
    end
    if ~exist('dir', 'var')
        dir = 'left';
    end
    if ~exist('tolR', 'var')
        tolR = 2;
    end
    
    d = X.order;
    if ~isequal(d, Y.order)
        error('The order of the two matrices must coincide')
    end
    if ~isequal(X.size, Y.size)
        error('The size of the two matrices must coincide')
    end
        
    if ~exist('rbase', 'var')
        rbase = [1, repmat(step, 1, d-1), 1];
    elseif numel(rbase) == 1
        rbase = [1, repmat(rbase, 1, d-1), 1];
    elseif numel(rbase) == d + 1
        rbase([1,end]) = 1;
    else
        error('Wrong format for rbase. It must either be a scalar or a vector of length (X.order + 1)') 
    end
    
    r0 = X.rank;
    
    Z = X;
    Rs = cell(1, d);

    rold = 0;
    r = rbase;
    
    if strcmpi(dir, 'right')
        diropp = 'left';
    elseif strcmpi(dir, 'left') 
        diropp = 'right';
    else
        error('Unknown direction specified. Choose either LEFT or RIGHT') 
    end
    while ~isequal(rold, r)
        [Z0, Rs] = truncate_hada_TT_randomized(X, Y, r, 0, dir, false, Rs);
        Z = round_nonortho(Z0, ep * (d - 1)^-.5, diropp);
        posupdate = find(Z.rank >= r - tolR);
        posupdate = posupdate(2:end-1);
        if isempty(posupdate)
            break;
        end
        rold = r;
        r(posupdate) = r(posupdate) + step;
        posexceed = find(r > r0); 
        if ~isempty(posexceed)
            r(posexceed) = r0(posexceed);
        end
    end
end