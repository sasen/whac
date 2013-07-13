function square = CenterSq(x,y,L)
% Return rect(s) for a square centered at x,y, with side length L
% L must be scalar
% x and y must have same size
% rect is size [4  numel(x)]

assert(sum(size(x)==size(y))==ndims(x),'CenterSq.m: ERROR--x and y have different dimensions!');
assert(prod(size(L))==1,'CenterSq.m: ERROR--L must be scalar!');

halfL = L/2;
for i = [1:numel(x)]
    xi = x(i); yi = y(i);
    square(:,i) = [xi-halfL yi-halfL xi+halfL yi+halfL];
end
