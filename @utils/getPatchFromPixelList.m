function [patch_img, patch_bw] = getPatchFromPixelList(img, pixelIdxList, padding)
% Get image patches (with padding) from pixel indices. ex) cc.PixelIdxList
%
% first wrote by Dongsoo Lee (19-04-29)
%
% single patch version 19-05-06 Juyoung Kim

    if isempty(img)
        
        patch_img = [];
        patch_bw = [];
        
    else

        [N, M] = size(img);          % ex)[N, M] = [512 380]
        P = padding;

        flatten = reshape(zeros(N, M), [N * M, 1]); % zero image
        flatten(pixelIdxList) = 1;
        bw = reshape(flatten, [N, M]);

        s = regionprops(bw, 'BoundingBox');
        ymin = ceil(s.BoundingBox(2));
        ymax = ymin + ceil(s.BoundingBox(4)) - 1;
        xmin = ceil(s.BoundingBox(1));
        xmax = xmin + s.BoundingBox(3) - 1;

        if ymin - P < 1
            ymin = P + 1;
        end
        if ymax + P > N
            ymax = N - P;
        end
        if xmin - P < 1
            xmin = P + 1;
        end
        if xmax + P > M
            xmax = M - P;
        end

        patch_img = img(ymin-P:ymax+P, xmin-P:xmax+P);
        patch_bw = bw(ymin-P:ymax+P, xmin-P:xmax+P);
        
    end

end


% function patches = getPatchFromPixelList(img, pixelIdxList, padding)
% % Get image patches (with padding) from pixel indices. ex) cc.PixelIdxList
% % patches(cell arr{R}) = getPatchFromPixelList(img(N, M),
% %                                   pixelIdxList(cell arr{R}), padding(int))
% % by Dongsoo Lee (19-04-29)
% 
% [N, M] = size(img);          % ex)[N, M] = [512 380]
% P = padding;
% R = max(size(pixelIdxList)); % ROI number
% 
% %patches = {};
% patches = cell(1, R); % 19-05-06 Juyoung 
% 
% for r = 1:R
%     flatten = reshape(zeros(N, M), [N * M, 1]);
%     flatten(pixelIdxList{r}) = 1;
%     s = regionprops(reshape(flatten, [N, M]), 'BoundingBox');
%     ymin = ceil(s.BoundingBox(2));
%     ymax = ymin + ceil(s.BoundingBox(4)) - 1;
%     xmin = ceil(s.BoundingBox(1));
%     xmax = xmin + s.BoundingBox(3) - 1;
%     padded = padarray(img, [P, P], 0);
%     patches{r} = padded(ymin:ymax + 2*P, xmin:xmax + 2*P);
% end
% end

