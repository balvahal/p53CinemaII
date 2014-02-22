function [finalSegmentation, localMaxima] = singleCellFollowing_imageProcessing(IM)
IM = double(imnormalize(IM));
BlurredImage = imfilter(IM, fspecial('gaussian', 10, 4), 'replicate');
edgeImage = imfill(edge(BlurredImage, 'canny'), 'holes');
threshold = quantile(BlurredImage(edgeImage), 0.2);
thresholdedImage = imfill(edgeImage + logical(BlurredImage > threshold), 'holes');
thresholdedImage = imopen(thresholdedImage, strel('disk',1));

thresholdedImage = bwlabel(thresholdedImage);
props = regionprops(thresholdedImage, 'Solidity');
firstPassSegmentation = ismember(thresholdedImage, find([props.Solidity] > 0.97));
thresholdedImage = logical(thresholdedImage) & ~firstPassSegmentation;

if(sum(sum(thresholdedImage))>0)
    IM(~thresholdedImage) = 0;
    BlurredImage(~thresholdedImage) = 0;
    
    secondPassSegmentation = SEGMENTATION_identifyPrimaryObjectsGeneral(IM, ...
        'LocalMaximaType', 'Shape', 'WatershedTransformImageType', 'Distance', ...
        'MaximaSuppressionSize', 3, 'ImageResizeFactor', 0.75);
    
    % localMaxima = imregionalmax(BlurredImage);
    % secondPassSegmentation = double(watershed(imimposemin(-BlurredImage, localMaxima))) .* thresholdedImage;
    %
    % DistanceTransformedImage = bwdist(~thresholdedImage);
    % localMaxima = imregionalmax(DistanceTransformedImage);
    % secondPassSegmentation = double(watershed(imimposemin(-DistanceTransformedImage, localMaxima))) .* thresholdedImage;
    
    finalSegmentation = firstPassSegmentation | secondPassSegmentation;
    finalSegmentation = bwlabel(finalSegmentation);
else
    finalSegmentation = bwlabel(firstPassSegmentation);
end
props = regionprops(finalSegmentation, 'Area');
finalSegmentation = ismember(finalSegmentation, find([props.Area] > 250));
finalSegmentation = bwlabel(finalSegmentation);
end