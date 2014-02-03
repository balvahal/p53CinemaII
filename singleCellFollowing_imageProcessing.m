function [thresholdedImage, localMaxima] = singleCellFollowing_imageProcessing(IM)
BlurredImage = imfilter(IM, fspecial('gaussian', 10, 4));
edgeImage = imfill(edge(BlurredImage, 'canny'), 'holes');
threshold = quantile(BlurredImage(edgeImage), 0.05);
thresholdedImage = edgeImage + logical(BlurredImage > threshold);
thresholdedImage = imopen(thresholdedImage, strel('disk',3));
BlurredImage(~thresholdedImage) = 0;
localMaxima = imregionalmax(BlurredImage);
%localMaxima = ind2sub(size(IM), find(localMaxima));
thresholdedImage = bwlabel(thresholdedImage);
props = regionprops(thresholdedImage, 'Area');
thresholdedImage = ismember(thresholdedImage, find([props.Area] > 100));
thresholdedImage = double(watershed(imimposemin(-BlurredImage, localMaxima))) .* thresholdedImage;
end