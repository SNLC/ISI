function sh = shadow(x,y,M,N)

%x is the horizontal index
%y is the vertical index

y = reshape(y,prod(size(y)),1);
x = reshape(x,prod(size(x)),1);

sh = zeros(M*N,1);
sh(y+M*(x-1)) = 1;
sh = reshape(sh,M,N);
sh(1,1) = 0;