function [output] = BrainSegment(input)
RGB = imread(input);

if size(RGB,3)==3       %Determine whether image is RGB or not
    RGB = rgb2gray(RGB);    %If image is RGB, grayscale the RGB image
end

bw1 = medfilt2(RGB,[20 20]);    %Median Filter
bw = imbinarize(bw1,'adaptive','ForegroundPolarity','bright','Sensitivity',0.5);    %Binarize image
bw2 = edge(bw,"zerocross")      %To observe the edges (Observation purposes only)
bw = bwareaopen(bw,500);    %Remove any white blob with less than 500 pixel

[B,L] = bwboundaries(bw,'noholes');

imshow(label2rgb(L,@jet,[.1 .1 .1]))
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
end

%subplot(1,2,1), imshow(bw2)
%subplot(1,2,2), imshow(RGB)
imshow(RGB)

stats = regionprops(L,'Area','Centroid');

threshold = 0.5;       %Threshold to determine the roundness of the object

% loop over the boundaries
for k = 1:length(B)

  %Obtain the boundaries's coordinates (x,y)
  boundary = B{k};

  % calculate the boundary perimeter
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % obtain the boundary area
  area = stats(k).Area;
  
  % calculate the roundness metric
  metric = 4*pi*area/perimeter^2;
  
  % display the results
  metric_string = sprintf('%2.2f',metric);

  % mark objects above the threshold with a black circle
  if (metric > threshold) && (metric <= 1)
    centroid = stats(k).Centroid;
    text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',14,'FontWeight','bold')
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
  end

  %text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',14,'FontWeight','bold')

end

title(['The Brain Tumor with Roundness Value'])