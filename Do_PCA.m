function Do_PCA ()

Nbr_EigenValues = 10;

% Loading of the databases

load('Names_Train_Images.mat', 'Names_Train_Images')
load('Names_Test_Images.mat', 'Names_Test_Images')

load('Features_Train.mat', 'Features_Train')
load('Features_Test.mat', 'Features_Test')

% Compute and store the features vectors for each normalized image of the
% training set

for Ind_Face = 1 : length(Names_Train_Images)
    
    Name_Im = strcat(Names_Train_Images{Ind_Face}, '.jpg');
    
    PCA_Array{Ind_Face} = Get_PCA (Name_Im, Nbr_EigenValues);
    
end

PCA_Train_Dataset = PCA_Array';

save('PCA_Train_Dataset.mat', 'PCA_Train_Dataset')
disp('PCA Train Dataset Completed')

% Compute and store the features vectors for each normalized image of the
% training set

for Ind_Face1 = 1 : length(Names_Test_Images)
    

    Name_Im = strcat(Names_Test_Images{Ind_Face1}, '.jpg');
    
    PCA_Array1{Ind_Face1} = Get_PCA (Name_Im, Nbr_EigenValues);
    
end

PCA_Test_Dataset = PCA_Array1';

save('PCA_Test_Dataset.mat', 'PCA_Test_Dataset')
disp('PCA Test Dataset Completed')

end

function Projection = Get_PCA (Input_Image, Nbr_EigenValues)

% Convert the image to a vector

Im = double(reshape(Input_Image, 1, []));

Im = Im';

% Compute the mean of the original image

Mean_Im = mean(Im);
I = Im;

% Substract the mean to the original image


for i2 = 1 : size(Im, 2)
    
    I(:, i2) = I(:, i2) - Mean_Im;
    
end

% Determine the eigenvectors and eigenvalues

Image_cov = (1 / (size(I, 2)) * I * (I'));
[Eigenvectors ~] = eigs(Image_cov,[],Nbr_EigenValues);

% Compute the projection

Projection = Eigenvectors' * Im;

end

function Im_Final = Redimension(Names_Faces, TForm_Array, Ind_Face)

% Reading of the image from the database

Name_Im = strcat(Names_Faces{Ind_Face}, '.jpg');
Im= ((imread(Name_Im)));

% Generation of the vector x and y

Vx = [];
Vy = [];

for i1 = 1 : 64
    
    Vx = [Vx (ones(1, 64) * i1)];
    Vy = [Vy (1 : 64)];
    
end

% Apply consecutives inverse spatial transformations to the vectors x and y

for i2 = 1 : length(TForm_Array)
    
    TForm = TForm_Array{i2};
    [Vx Vy] = tforminv(TForm, Vx, Vy);
    
end

% Round to the nearest integer to avoid float values

Vx = round(Vx);
Vy = round(Vy);

% Set the vector x and y to the dimensions of the image
% Contain the vectors x and y into a cell vector

for i3 = 1 : length(Vx)
    
    if (Vx(i3) < 1)
        Vx(i3) = 1;
    end
    
    if (Vx(i3) > size(Im, 2))
        Vx(i3) = size(Im, 2);
    end
    
    if (Vy(i3) < 1)
        Vy(i3) = 1;
    end
    
    if (Vy(i3) > size(Im, 1))
        Vy(i3) = size(Im, 1);
    end
    
    Grid{i3} = [Vy(i3) Vx(i3)];
end

% Convert the cell vector to cell array

Grid = reshape(Grid, 64, 64);

for i5 = 1 : 64
    for i4 = 1 : 64
        
        XY = Grid{i4, i5};
        Im_Final(i4, i5) = Im(XY(1), XY(2));
        
    end
end

end

function TForm_Array = LeastMeanSquare (Coordinates_Faces, Ind_Face)

% Transformation of the coordinates faces vector to matrix

Indice = 0;
for i2 = 1 : 5
    for i2 = 1 : 2
        Indice = Indice + 1;
        Features(i2, i2) = Coordinates_Faces(Ind_Face, Indice);
    end
end

Features_Init = Features;
FPerfect = ([13 20 ; 50 20 ; 34 34 ; 16 50 ; 48 50 ;]);

Err = 1;
Indice = 1;

while((Indice < 100) && (Err > 0.01))
    
    F = Features;
    
    % Add a row equal to 1 to represent b in the equation y = A x + b
    
    for i1= 1 : 5 
        
        F(i1, 3) = 1;
        
    end
    
    % Compute the SVD
    
    [U S D] = svd (F' * F); %Calcul the SVD
    
    % Compute the LMS transform from the SVD
    
    TForm =D *(S ^(-1))* U' * (F' * FPerfect);
    
    % Store into a 2-D affine geometric transformation
    
    %     TForm_Array{ Indice } = affine2d(TForm);
    TForm_Array{ Indice } = maketform('affine', TForm);
    
    % Determine the error to check the condition
    
    Features = Features * TForm(1 : 2, :);
    
    for i2 = 1 : length(Features);
        
        Features(i2, : ) = Features(i2, : ) + TForm(3, : );
        
    end
    
    Err = sum( sum( abs(Features_Init- round(Features))));
    
    % Store the new set of features
    
    Features_Init = Features;
    
    % Increment the count of indice to check the condition
    
    Indice = Indice + 1;
end


end
