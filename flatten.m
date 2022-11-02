function flat = flatten(a)
    flat = reshape(a, [numel(a) 1]);
end