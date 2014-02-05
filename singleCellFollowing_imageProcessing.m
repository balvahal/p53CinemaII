function [finalSegmentation, localMaxima] = singleCellFollowing_imageProcessing(IM)
BlurredImage = imfilter(IM, fspecial('gaussian', 10, 4));
edgeImage = imfill(edge(BlurredImage, 'canny'), 'holes');
threshold = quantile(BlurredImage(edgeImage), 0.05);
thresholdedImage = edgeImage + logical(BlurredImage > threshold);
thresholdedImage = imopen(thresholdedImage, strel('disk',3));

thresholdedImage = bwlabel(thresholdedImage);
props = regionprops(thresholdedImage, 'Solidity');
firstPassSegmentation = ismember(thresholdedImage, find([props.Solidity] > 0.97));
thresholdedImage = logical(thresholdedImage) & ~firstPassSegmentation;

BlurredImage(~thresholdedImage) = 0;
localMaxima = imregionalmax(BlurredImage);
secondPassSegmentation = double(watershed(imimposemin(-BlurredImage, localMaxima))) .* thresholdedImage;
% 
% DistanceTransformedImage = bwdist(~thresholdedImage);
% localMaxima = imregionalmax(DistanceTransformedImage);
% secondPassSegmentation = double(watershed(imimposemin(-DistanceTransformedImage, localMaxima))) .* thresholdedImage;

finalSegmentation = firstPassSegmentation | secondPassSegmentation;
finalSegmentation = bwlabel(finalSegmentation);
end