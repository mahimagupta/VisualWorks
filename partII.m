a = imaqhwinfo;
% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
vid = videoinput('winvideo',1);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

%start the video aquisition here
start(vid)

x = surf(peaks);
        axis vis3d

% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired<=200)
    
    % Get the snapshot of the current frame
    data = getsnapshot(vid);
    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    diff_im_2 = imsubtract(data(:,:,3), rgb2gray(data));

    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);
    diff_im_2 = medfilt2(diff_im_2, [3 3]);

    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.18);
    diff_im_2 = im2bw(diff_im_2,0.18);
    
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,300);
    diff_im_2 = bwareaopen(diff_im_2,300);
    
    % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8);
    bw_2 = bwlabel(diff_im_2, 8);
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    stats_2 = regionprops(bw_2, 'BoundingBox', 'Centroid'); %#ok<*MRPBW>
    
    % Display the image
    %imshow(diff_im)
    
    hold on
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        camroll(-50)
        pause(1)
        %rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        %plot(bc(1),bc(2), '-m+')
        %a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        %set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
    
    for object = 1:length(stats_2)
        bb = stats_2(object).BoundingBox;
        bc = stats_2(object).Centroid;
        [ny,nx] = size(x) ;
        hroot = groot;
        %sprintf(bc);
        set(hroot,'PointerLocation',bc)
        %hold on
        % Center 
        C = round([nx ny]/2) ;
        %zoom(1);
        %pause(6);
        %rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        %plot(bc(1),bc(2), '-m+')
        %a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        %set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
    
    hold off
end
% Both the loops end here.

% Stop the video aquisition.
stop(vid);

% Flush all the image data stored in the memory buffer.
flushdata(vid);

% Clear all variables
clear all
sprintf('%s','That was all about Image tracking, Guess that was pretty easy :) ')


