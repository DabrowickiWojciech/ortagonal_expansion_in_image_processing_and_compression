%% Ideal sampling
%importing the image
Image = imread("images/cat.jpg");
imshow(Image)

% Convert the image to grayscale if necessary
if size(Image, 3) == 3
    Image= rgb2gray(Image);
end
figure;imshow(Image)
...imwrite(DSimage_1,"images/grayed.jpg")

%downsampling by how many times
DS = 3;

%obtaining the size of the image using:
%size(rows/column/page)
%Row - number of rows in the image / height
%Column - number of columns / width
%Page - encodes the three color channels RGB
[Height, Width, RGB] = size(Image);

%sampling calculations
%DS - downsampling
DSimage_1 = Image(1:DS:Height, 1:DS:Width);
figure; imshow(DSimage_1); title(["Downsampled by" num2str(DS)])
...imwrite(DSimage_1,"images/DSimage_1.jpg")

%downsampling and resizing up
%RU - resizing up
DSRUimage_1 = imresize(DSimage_1,[Height,Width]);
figure;imshow(DSRUimage_1); title("Downsampling and resizing up")
...imwrite(DSRUimage_1,"images/DSRUimage_1.jpg")

%downsampling and resizing up with filter
%RUF - resizing up + filter
RUFimage_1 = imfilter(DSRUimage_1, fspecial("laplacian"));
figure
subplot(2,1,1);imshow(RUFimage_1); title("Downsampling and resizing up with laplacian filter")

RUFimage_2 = imfilter(DSRUimage_1, fspecial("gaussian",6,2));
subplot(2,1,2);imshow(RUFimage_2); title("Downsampling and resizing up with gaussian filter")
...imwrite(RUFimage_2,"images/RUFimage_2.jpg")

%% Lloyd-Max Quantizer
% desired number of bits for quantization
LMQ_bits = 7;

% Convert the image to double precision for calculations
LMQvalues = double(Image);

% Flatten the image into a 1D array
LMQ_input_values = LMQvalues(:);

% Initialize centroids based on the desired number of quantization levels
LMQ_min_value = min(LMQ_input_values);
LMQ_max_value = max(LMQ_input_values);
centroids = linspace(LMQ_min_value, LMQ_max_value, 2^LMQ_bits);

% Iterative refinement (Lloyd-Max algorithm)
max_iterations = 100;
for iter = 1:max_iterations
    % Assign each input value to the nearest centroid
    [~, index] = min(abs(LMQ_input_values - centroids), [], 2);
    
    % Update centroids to be the mean of their assigned values
    for i = 1:length(centroids)
        centroids(i) = mean(LMQ_input_values(index == i));
    end
    
    % Check for convergence
    if iter > 1 && isequal(centroids, prev_centroids)
        break;
    end
    prev_centroids = centroids;
end

% Assign each input value to its nearest centroid
[~, quantized_values] = min(abs(LMQ_input_values - centroids), [], 2);

% Quantized image
LMQimage = reshape(centroids(quantized_values), size(Image));

% Display the original and quantized images
figure; subplot(1, 2, 1); imshow(uint8(LMQvalues)); title('Original Image');
subplot(1, 2, 2); imshow(uint8(LMQimage)); title(['Quantized Image (' num2str(LMQ_bits) ' bits)']);
imwrite(uint8(LMQimage),"images/LMQimage.jpg")



