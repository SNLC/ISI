function [B] = phi(A)

for idx = 1:numel(A)
    if A(idx) < 0;
        A(idx) = 0;
    end
end

B = double(A);

