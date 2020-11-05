
% AKSHAY GORE
% https://www.codewrk.com/
% admin@codewrk.com; mycodeworklab.gmail.com #WSN #matlab 
%#leach # image processing




function iqa_result = adaptivepooling(mitras, miters)
% This function is used to pooling the distortion from mitras and miters
% into a single result.


%% Integration of mitras and miters
%miters.* % if the difference of the distortions is lese than epsilon, we assume no masking between two component distortion
if isempty(mitras) && isempty(miters) % both mitras and miters are 
    error('No distortion data to pool!!!');
end
if isempty(miters) && ~isempty(mitras) % only mitras is avaiable
    integration = mitras;
end
if isempty(mitras) && ~isempty(miters) % only miters is avaiable
    integration = miters;
end
if ~isempty(miters) && ~isempty(mitras) % both mitras and miters are avaiable
     alph = 0.85;  % 0.85 for TID 2008 
                  % 0.86 for cSIQ
                  % 0.85 for LIVE
     integration = miters./(1+alph.*(miters-mitras)); 

end
if numel(find(integration<0-1e-4)) || numel(find(integration>1+1e-4)) 
    error('Something wrong in the intergrating of structural similarities of intra and inter patches!!!');
end
%% pixel-wise pooling by distortion level

r = 1;  % r=0.2 for TID 2008
          % r=0.04 for CISQ
          % r=0.2 for LIVE
          % r=0.75 for IVC
num = round(r*numel(integration(:)));
B = sort(integration(:));
B = B(1:num);
% pww = abs(1- w*B); 
% iqa_result = sum(B(:).*pww(:))/sum(pww(:));
iqa_result = mean(B);
% iqa_result = mean(integration(:));
