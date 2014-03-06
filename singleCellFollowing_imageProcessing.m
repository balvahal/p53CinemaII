function [finalSegmentation, localMaxima] = singleCellFollowing_imageProcessing(IM)
IM = double(imnormalize(IM));

BlurredImage = imfilter(IM, fspecial('gaussian', 10, 4), 'replicate');
edgeImage = edge(BlurredImage, 'canny');
%edgeImage = imdilate(edgeImage, strel('disk',3));
edgeImage = imfill(edgeImage, 'holes');
%edgeImage = imerode(edgeImage, strel('disk', 3));
threshold = quantile(BlurredImage(edgeImage), 0.4);
thresholdedImage = imfill(edgeImage + logical(BlurredImage > threshold), 'holes');

%thresholdedImage = im2bw(BlurredImage, graythresh(BlurredImage)*0.5);
thresholdedImage = imopen(thresholdedImage, strel('disk',1));

thresholdedImage = bwlabel(thresholdedImage);
props = regionprops(thresholdedImage, 'Solidity');
firstPassSegmentation = ismember(thresholdedImage, find([props.Solidity] > 0.90));
thresholdedImage = logical(thresholdedImage) & ~firstPassSegmentation;

if(sum(sum(thresholdedImage))>0)
    IM(~thresholdedImage) = 0;
    BlurredImage(~thresholdedImage) = 0;
    
    secondPassSegmentation = SEGMENTATION_identifyPrimaryObjectsGeneral(IM, ...
        'LocalMaximaType', 'Intensity', 'WatershedTransformImageType', 'Distance', ...
        'MaximaSuppressionSize', 10, 'ImageResizeFactor', 0.5);
    
    localMaxima = imregionalmax(BlurredImage);
    secondPassSegmentation = double(watershed(imimposemin(-BlurredImage, localMaxima))) .* thresholdedImage;
    
    DistanceTransformedImage = bwdist(~thresholdedImage);
    localMaxima = imregionalmax(DistanceTransformedImage);
    secondPassSegmentation = double(watershed(imimposemin(-DistanceTransformedImage, localMaxima))) .* thresholdedImage;
    
    finalSegmentation = firstPassSegmentation | secondPassSegmentation;
    finalSegmentation = bwlabel(finalSegmentation);
else
    finalSegmentation = bwlabel(firstPassSegmentation);
end
props = regionprops(finalSegmentation, 'Area');
finalSegmentation = ismember(finalSegmentation, find([props.Area] > 250));
finalSegmentation = bwlabel(finalSegmentation);
end