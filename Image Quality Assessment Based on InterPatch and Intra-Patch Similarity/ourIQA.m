% AKSHAY GORE
% https://www.codewrk.com/
% admin@codewrk.com; mycodeworklab.gmail.com #WSN #matlab #leach # image processing




function iqa_result = ourIQA(image1, image2, ssm)
% This function is used to assess image quality of image1, given image2 as
% a reference image
% ssm---selected sub-method, it can be 'intra', 'inter', or 'both'

%% Select sub method(s)
image1 = double(image1);
image2 = double(image2);
switch ssm
    case 'intra'
        mitras = intrasimilarity(image1,image2); % map of intra-patch similarity
        miters = []; % map of inter-patch similarity is null
    case 'inter'
        mitras = []; % map of intra-patch similarity is null
        miters = intersimilarityfast_2(image1,image2); % map of inter-patch similarity
    case 'both'
        mitras = intrasimilarity(image1,image2); % map of intra-patch similarity
        miters = intersimilarityfast_2(image1,image2); % map of inter-patch similarity
    otherwise
        error('Incompatible parameter in function ourIQA!!!');
end

%% error pooling
iqa_result = adaptivepooling(mitras, miters); % pooling two similarity into a scalar score
