function IM_normalized = imnormalize(IM)
    IM = double(IM);
    % Kyle: I when the max of the image is 0 the image returned is all
    % NaN.
    if max(IM(:)) == 0
        IM_normalized = ones(size(IM));
    else
        IM_normalized = (IM - min(IM(:))) / (max(IM(:)) - min(IM(:)));
        IM_normalized = (IM - min(IM(:))) / (max(IM(:)));
    end
end