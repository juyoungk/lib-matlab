function shiftedPixelIdxList = getShiftedPixelList(r, roi_id, offset)
    
    cc = r.roi_cc;
    
    numRows = cc.ImageSize(1);
    numCols = cc.ImageSize(2);

    shiftedPixelIdxList = utils.getShiftedPixelList(cc.PixelIdxList{roi_id}, offset, numRows, numCols);
    
end