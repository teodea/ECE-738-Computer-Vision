addpath("../task3_disparity/");

f = 1277;
B = 259.3; 
cx = 623.2; % using CAMleft
cy = 490.4;

[all_left_matches, all_right_matches] = task3();

for i = 1:numel(all_left_matches)
    disparities = all_left_matches{i}(:,1) - all_right_matches{i}(:,1);
    depths = f * B ./ disparities;  % depth Z in mm

    points_x = all_left_matches{i}(:,1);
    points_y = all_left_matches{i}(:,2);

    X_mm = (points_x - cx) .* depths / f;
    Y_mm = (points_y - cy) .* depths / f;
    Z_mm = depths;

    figure;
    scatter(X_mm, Y_mm, 10, Z_mm, 'filled'); % Size 10 for better visibility
    xlabel('X (mm)');
    ylabel('Y (mm)');
    title(['2D Depth Map - Image Pair ', num2str(i)]);
    axis equal; 
    colorbar;
    colormap jet;
    grid on;

    figure;
    scatter3(Z_mm, X_mm, Y_mm, 5, Z_mm, 'filled');
    xlabel('Depth (mm)');
    ylabel('X (mm)');
    zlabel('Y (mm)');
    title(['3D Reconstruction Image Pair ', num2str(i)]);
    axis equal; colorbar;
    grid on; view(3);
end
