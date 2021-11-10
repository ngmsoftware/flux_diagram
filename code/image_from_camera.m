function I = image_from_camera()

    id = videoinput('macvideo');
    set(id,'FramesPerTrigger',1);

    preview(id);
    
    disp('press something to capture');
    pause();
    
    start(id);
    data = getdata(id);
    I = data(:,:,1);
    stop(id);
    
    delete(id);
end