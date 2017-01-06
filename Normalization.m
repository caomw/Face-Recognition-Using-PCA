function Normalization

%% Read Excel File

Filename_Excel = 'Dataset_Face_Recognition.xlsx';

[~ , Names_Faces] = xlsread(Filename_Excel, 1, 'A:A');
Names_Faces = Names_Faces(2 : end, :);


xlRange = ['B:B'; 'C:C'; 'D:D'; 'E:E'; 'F:F'; 'G:G'; 'H:H'; 'I:I'; 'J:J'; 'K:K'];

xlRange =  num2str(xlRange);

for i = 1 : 10

    Features_Faces(:, i) = xlsread(Filename_Excel, 1, xlRange(i, :));

end

save('Names_Faces.mat', 'Names_Faces');
save('Features_Faces.mat', 'Features_Faces');

%% Load Matrix Files From Excel

load('Names_Faces.mat');
load('Features_Faces.mat');

%% Normalization

%% Compute coefficeint of affine transformation

% Conversion vector(Nbr x 10) to matrix F (5 x 2 x Nbr)

for i1 = 1:size(Features_Faces, 1)
    
    for i2 = 1 : 5
        F(i2, 1, i1) = Features_Faces(i1, i2 * 2 - 1);
        F(i2, 2, i1) = Features_Faces(i1, i2 * 2);
    end
    
    F(:,3, i1) = ones(5,1);
    
end

FF = [13, 20; 50, 20; 34, 34; 16, 50; 48, 50];

FF_Previous = ones(5, 2) ;

Threshold = 0.5;

while(max (max (abs (FF_Previous - FF))) > Threshold)
    
    for i1 = 1 : size(F, 3)
        
        Coefficients(:, :, i1) = F(:, :, i1) \ FF;
        
        Norm_Coordinates(:, :, i1) = F(:, :, i1) * Coefficients(:, :, i1);
        
    end
    
    FF_Previous = FF;
    
    FF = zeros(5, 2);
    
    for i1 = 1 : size(F, 3)
        
        FF = FF + Norm_Coordinates(:, :, i1);
        
    end
    
    FF = FF ./ size(F, 3);
    
end

%% Resizing images to 64x64

Size_W = 64;

for i1 = 1:size(Names_Faces, 1)
    
    Name_Im = strcat(Names_Faces{i1}, '.jpg');
    
    Im= (rgb2gray(imread(Name_Im)));
    
    [SizeX, SizeY] = size(Im);
    
    A = Coefficients(1:2, 1:2, i1)';
    B = Coefficients(3, :, i1)';
    
    for i2 = 1 : Size_W
        for i3 = 1 : Size_W
            
            Norm_Pixel = round(A \ ([i3; i2] - B));
            Y = Norm_Pixel(1);
            X = Norm_Pixel(2);
            
            if(X > SizeX)
                X = SizeX;
            elseif(X < 1)
                X = 1;
            end
            
            if(Y > SizeY)
                Y = SizeY;
            elseif(Y < 1)
                Y = 1;
            end
            
            Norm_Im(i2, i3, i1) = Im(X, Y);
            
        end
    end
end


%% Train / Test Data Bases

mkdir('Set_Train_Images_64');
mkdir('Set_Test_Images_64');

Features_Train = [];
Features_Test = [];

Names_Train_Images = [];
Names_Test_Images = [];

Ind_Name_Bis = ['   '];

Ind = 1;

while (Ind <= size(Names_Faces, 1))
    
    Name = Names_Faces{Ind};
    Ind_Name = Name(1 : 3);

    
    if (strcmp(Ind_Name,Ind_Name_Bis) == 0)
        
        Folder = 'Set_Train_Images_64/';
        
        for i = 1 : 3
            Features_Train = [Features_Train; Features_Faces(Ind, :)];
            
            str = [Folder,Names_Faces{Ind},'_64.jpg'];
            imwrite(Norm_Im(:,:,Ind),str);
            
            Names_Train_Images = [Names_Train_Images; strcat(Names_Faces(Ind), '_64')];
            Ind = Ind + 1;
        end
        Ind_Name_Bis = Ind_Name;
        Folder = 'Set_Test_Images_64/';
        
    else
        
        Features_Test = [Features_Test; Features_Faces(Ind, :)];
        
        str = [Folder,Names_Faces{Ind},'_64.jpg'];
        imwrite(Norm_Im(:,:,Ind),str);
        
        Names_Test_Images = [Names_Test_Images; strcat(Names_Faces(Ind), '_64')];
        Ind = Ind + 1;
        Ind_Name_Bis = Ind_Name;
        
    end
    
    
end

save('Features_Train.mat', 'Features_Train')
save('Features_Test.mat', 'Features_Test')

save('Names_Train_Images.mat', 'Names_Train_Images')
save('Names_Test_Images.mat', 'Names_Test_Images')

end



