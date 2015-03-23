function [v_tmp] = rhs_state_value_bellman(na,nb,ntrans,useEmp,V,gamma,Ra,Pa,Rb,Pb,max_num_cars_can_transfer,max_cars_can_store)
% RHS_STATE_VALUE_BELLMAN - computes the right hand side of the bellman equation
%
% We have to consider the possible number of rentals at sites A/B
%                 and the possible number of returns at sites A/B
%-----

% the maximum number of cars at each site (assume equal): 
max_n_cars = size(V,1)-1; 

% restrict this action: 
ntrans_total = ntrans+useEmp; %net transfer based on policy - number to transfer + whether Jack's employee needs to transfer a car i.e. useEmp is either 0 and 1
ntrans_total = max(-nb,min(ntrans_total,na)); %finding out the max number of transfer depending on station B and A
ntrans_total = max(-max_num_cars_can_transfer,min(+max_num_cars_can_transfer,ntrans_total));

% the number of cars at each site after transport: 
na_morn = na-ntrans_total;
nb_morn = nb+ntrans_total;

% assemble all costs:
% --fixed transport cost: 
% She is happy to shuttle one car to the second location for free. 
% Each additional car still costs $2 i.e. ntrans*2 dollars, as do all cars moved in the other direction.
v_tmp   = -2*abs(ntrans);

% --overnight storage cost: 
if( na_morn > max_cars_can_store ) v_tmp = v_tmp - 4; end     % if n?_morn > 10 we had to store extra cars that night
if( nb_morn > max_cars_can_store ) v_tmp = v_tmp - 4; end

%from current state evaluate the 
for nna=0:max_n_cars, 
  for nnb=0:max_n_cars,
    pa = Pa(na_morn+1,nna+1); %probability of going to state na_norm from various start states
    pb = Pb(nb_morn+1,nnb+1); %probability of going to state nb_norm from various start states
    %value = old value + probability of getting from state a to state b * reward for going from state a to b + gamma*value from state a to b
    v_tmp = v_tmp + pa*pb* ( Ra(na_morn+1) + Rb(nb_morn+1) + gamma*V(nna+1,nnb+1) ); 
  end
end
