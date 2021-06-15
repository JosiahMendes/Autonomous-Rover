% Points in XY Coords

XY    = [-13.4, 41.2;
         -11.2, 69.7;
         -6.7, 52.4;
         5.2, 61.1;
         10.9, 43.6;
         
         -21, 71.4;
         -5.2, 54.26;
         4.6, 46.8;
         11.5, 69.9;
         10.3, 37.4;
         
         -12.9, 55.5;
         -8.2, 33.6;
         -3.3, 62.0;
         12.4, 51.0;
         9.5, 32.7;
         
         %-14.3, 44.9;
         %-9.8, 72.6;
         %6.6, 36.2;
         %14.9, 62.3;
         %16.3, 46.4;
         
         ];
         
         
         

% Points in Pixel Coords

Pixels = [-203.2,424.8; %Pic2 Grey
         -99.008, 351.824; %Pic2 Pink
         -60.904, 387.248; %Pic2 Orange
         67.096, 367.984; %Pic2 Green
         178.2, 421.328; %Pic2 Blue
         
         -179.216, 361.048; %Pic3 Blue
         -47.64, 393.168; %Pic3 Green
         84.8, 417.352; %Pic3 Grey
         134.4, 364.584;%Pic3 Pink
         260.12, 462.84; %Pic3 Orange

         -153.136, 367.6; %Pic1 Blue;
         -166.704, 456.232; %Pic1 Pink;
         -40.39, 354.832; %Pic1 Grey;
         171.688, 384.216; %Pic1 Green
         213.6, 469.664; %Pic1 Orange
         
         %-234.296, 404.64; %Pic 0 Black
         %-94.72, 334.936; %Pic 0 Blue
         %150.568, 442.72; %Pic 0 Green
         %183.952, 355.72; %Pic 0 Pink
         %201.36, 393.448; %Pic 0 Orange
  ];  


M = [Pixels(:,[1]).* Pixels(:,[1]), Pixels(:,[2]).* Pixels(:,[2]), Pixels(:,[1]).* Pixels(:,[2]), Pixels(:,[1]), Pixels(:,[2]) ones(15,1)]


%N = [Pixels(:,[1]).* Pixels(:,[1]) .* Pixels(:,[1]), Pixels(:,[2]).* Pixels(:,[2]) .* Pixels(:,[2]), Pixels(:,[1]).* Pixels(:,[1]) .* Pixels(:,[2]), Pixels(:,[2]).* Pixels(:,[2]) .* Pixels(:,[1]),Pixels(:,[1]).* Pixels(:,[1]), Pixels(:,[2]).* Pixels(:,[2]), Pixels(:,[1]).* Pixels(:,[2]), Pixels(:,[1]),  Pixels(:,[2]), ones(15,1)]
         
    

U1 = inv(transpose(M) * M) * transpose(M) * XY

%U2 = inv(transpose(N) * N) * transpose(N) * XY

