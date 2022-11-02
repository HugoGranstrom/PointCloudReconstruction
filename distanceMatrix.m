function D = distanceMatrix(points1, points2) 
    len1 = size(points1);
    len1 = len1(1);
    len2 = size(points2);
    len2 = len2(1);
    D = zeros(len2, len1);
    for i = 1:len1
        D(:,i) = sqrt(sum((points1(i,:) - points2) .^ 2, 2));
    end
end