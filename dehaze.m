function J = dehaze(img_path)
    % used parameters
    img = imread(img_path);
    img = im2double(img);
    [rows, cols, c] = size(img);
    w = 15; % window size
    
    %% Estimate dark channel prior
    img_padded = padarray(img, [floor((w-1)/2), floor((w-1)/2)], 'replicate', 'both');
    
    J_dark = zeros(rows, cols);
   
    for i=1:rows
        for j=1:cols
            patch = img_padded(i:i+w-1, j:j+w-1, 1:c);
            y_min = min(patch, [], [1,2]); % minimum in each color channel
            J_dark(i, j) = min(y_min);
        end
    end
    
    %% Get atmospheric light
    J_dark_vector = J_dark(:);
    img_vector = reshape(img, rows*cols, c);
    
    [~, I] = sort(J_dark_vector, 'descend');
    
    % number of pixels to consider
    n = ceil(rows*cols * (0.1/100));
    
    % 0.1 % brightest pixels in the dark channel seletec from the image
    img_sub = img_vector(I(1:n), :, :);
    
    [~, max_I] = max(vecnorm(img_sub, 2, 3));
    A = img_sub(max_I, :);
    A = [A(1,1) A(1,2) A(1,3)];
    
    %% Estimate transmission map
    p = 0.08;
    A = reshape(A, 1, 1, 3);
    
    % Normalize each color channel
    img_norm = img ./ A;
    img_norm_padded = padarray(img_norm, [floor((w-1)/2), floor((w-1)/2)], 'replicate', 'both');
    
    % calculate dark channel for normalized image  
    J_dark_norm = zeros(rows, cols);
    for i=1:rows
        for j=1:cols
            patch = img_norm_padded(i:i+w-1, j:j+w-1, 1:c);
            y_min = min(patch, [], [1,2]); % minimum in each color channel
            J_dark_norm(i, j) = min(y_min);
        end
    end
    
    t = 1 - J_dark_norm + p;
    %% Refine transmission estimate with bilateral filter
    w = 90;
    sigma_s = 3.5*w;
    sigma_r = 0.02;
   
    img_gray = mat2gray(img); % input image in grayscale
    
    % Gaussian spatial weights
    [X,Y] = meshgrid(-w:w,-w:w);
    g_s = exp(-(X.^2+Y.^2)/(2*sigma_s^2));
    
    h = waitbar(0,'Applying bilateral filter...');
    set(h,'Name','Bilateral Filter Progress');
    
    t_refined = zeros(rows, cols);
    for i=1:rows
        for j=1:cols
            % local patch
            i_min = max(i-w, 1);
            i_max = min(i+w, rows);
            j_min = max(j-w, 1);
            j_max = min(j+w, cols);
            
            patch = img_gray(i_min:i_max, j_min:j_max);
            t_patch = t(i_min:i_max, j_min:j_max);
            % Gaussian intensity weights
            g_r = exp(-(patch-img_gray(i,j)).^2/(2*sigma_r^2));
            
            % filter response
            f = g_r .* g_s((i_min-i+w+1:i_max-i+w+1),(j_min-j+w+1:j_max-j+w+1));
            t_refined(i,j) = (sum(f(:) .* t_patch(:))) / sum(f(:));
        end
        waitbar(i/rows);
    end
    close(h)
  
    %% Recover radiance    
    K = 50; % used to distinguish between bright and dark channel areas, change manually
    t0 = 0.1; % transmission lower bound
    J = zeros(rows,cols, c);
    for i=1:rows
        for j=1:cols
            if all(abs(img(i,j) - A)*255 <= K)
                J(i,j,1) = img(i,j,1);
                J(i,j,2) = img(i,j,2);
                J(i,j,3) = img(i,j,3);
            else
                J(i,j,1) = ((img(i,j,1) - A(1,1,1)) ./ max([t_refined(i,j), t0])) + A(1,1,1);
                J(i,j,2) = ((img(i,j, 2) - A(1,1,2)) ./ max([t_refined(i,j), t0])) + A(1,1,2);
                J(i,j,3) = ((img(i,j, 3) - A(1,1,2)) ./ max([t_refined(i,j), t0])) + A(1,1,3);
            end
        end
    end
    %J = (img - A) ./ max(t_refined, t0) + A;
    imwrite(J, 'dehazed.png')
    
    %% plots
    subplot(2,2,1)
    imshow(img)
    title('Input image')
    
    subplot(2,2,2)
    imshow(t)
    title('Estimated transmission map')
          
    subplot(2,2,3)
    imshow(t_refined)
    title('Refined transmission map') 
        
    subplot(2,2,4)
    imshow(J)
    title('Dehazed image')