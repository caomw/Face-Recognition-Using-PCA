function Recognition (Name_Im_Test)

% Loading of the databases

load('Names_Train_Images.mat', 'Names_Train_Images')
load('Names_Test_Images.mat', 'Names_Test_Images')

load('Features_Train.mat', 'Features_Train')
load('Features_Test.mat', 'Features_Test')

load('PCA_Train_Dataset.mat', 'PCA_Train_Dataset')
load('PCA_Test_Dataset.mat', 'PCA_Test_Dataset')

% Find the index of the input image into the database

Indice_Test_Im = 1;
while (strcmp(Name_Im_Test, Names_Test_Images{Indice_Test_Im}) == 0)

    Indice_Test_Im = Indice_Test_Im + 1;
end

% Compute the distance between the feature vector of the input image and
% all the training images

for i1 = 1 : length(PCA_Train_Dataset)
    
    Matches(i1, 1) = norm(PCA_Test_Dataset{Indice_Test_Im} - PCA_Train_Dataset{i1});
    Matches(i1, 2) = i1;
end

% Sort the matrix in function of the distance

Matches = sortrows(Matches, 1);

Label_Name_Train = [   ];

% Get the 3 first character of the label of the input image

Name_Test = Names_Test_Images{Indice_Test_Im};
Label_Name_Test = Name_Test(1 : 3)

% Get the 3 first character of the label of the first element of the sorted
% training images

Name_Train = Names_Train_Images{Matches(1, 2)};
Label_Name_Train = Name_Train(1 : 3);

Err = 0; Indice = 1;

% While the 2 previously extracted labels are not similar

while(strcmp(Label_Name_Test, Label_Name_Train) == 0)
    
Indice = Indice + 1;

% Go to the next training image and get the first character of its  label

Name_Train = Names_Train_Images{Matches(Indice, 2)};
Label_Name_Train = Name_Train(1 : 3);    

Err = Err + 1;

end

% Compute the accuracy for the first correct match

Accuracy = (1 - (Err / size(PCA_Train_Dataset, 1))) * 100;

% Display successively the input image, the closest match, and the first
% correct match

subplot(1,3,1)
imshow(imread([Names_Test_Images{Indice_Test_Im}, '.jpg']));
title('Input image for face recognition')

subplot(1,3,2)
imshow(imread([Names_Train_Images{Matches(1, 2)}, '.jpg']));
title(strcat('Closest match from the input image'))

subplot(1,3,3)
imshow(imread([Names_Train_Images{Matches(Indice, 2)}, '.jpg']));
title(['Closest correct match with an accuracy of', num2str(Accuracy)])


end
