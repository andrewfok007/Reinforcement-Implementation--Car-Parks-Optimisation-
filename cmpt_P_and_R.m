function [R,P] = cmpt_P_and_R(lambdaRequests,lambdaReturns,max_n_cars,max_num_cars_can_transfer)

if( nargin==0 ) %nargin counts the number of inputs when the function is used
  lambdaRequests=4; 
  lambdaReturns=2; 
  max_n_cars=20; 
  max_n_cars_can_transfer=5; 
end

PLOT_FIGS=0; 

% the number of possible cars at any site first thing in the morning: 
nCM = 0:(max_n_cars + max_num_cars_can_transfer); %e.g. 20+5

% return the average rewards: 
R = zeros(1,length(nCM));

for n = nCM, %loop through different states i.e. number of cars present, from 0 to 25
  tmp = 0.0;
  
  %Loop (below) goes through different number of requests, and calculate
  %the reward value for each number of cars present. 
  %Amount of Reward value tmp is calculated by:
  %for different no. requests:
  %     10*min(no. cars available, no. requests)*PoissonProb(no. requests,mean_requests)
  %More reward for getting rid of cars when there are lots of cars!
  %Make PLOT_FIGS = 1 to see no. cars present against reward values!
  
  for nr = 0:(10*lambdaRequests), %lambdaRequests*10 is a value where the probability of request is very small 
    tmp = tmp + 10*min(n,nr) * poisspdf( nr, lambdaRequests );
  end
  R(n+1) = tmp; 
end

if( PLOT_FIGS ) 
  figure; plot( nCM, R, 'x-' ); grid on; axis tight; 
  xlabel(''); ylabel(''); drawnow; 
end

% return the probabilities: 

P = zeros(length(nCM),max_n_cars+1); 

for nreq = 0:(10*lambdaRequests),  %lambdaRequests*10 is a value where the probability of request is very small
  reqP = poisspdf( nreq, lambdaRequests ); 
  % for all possible returns:
  for nret = 0:(10*lambdaReturns), % <- a value where the probability of returns is very small. 
    retP = poisspdf( nret, lambdaReturns ); 
    
    % for all possible morning states: 
    for n = nCM, %loop through different states i.e. number of cars present, from 0 to 25
      sat_requests = min(n,nreq); %never exceeds n, which is 20
      new_n = max( 0, min(max_n_cars, n + nret - sat_requests ) );
      %Probability update to the next state from orignal state n = 1, 2, 3...
      %based on the the number of requests nreq and returns nret
      P(n+1,new_n+1) = P(n+1,new_n+1) + reqP*retP;
    end
    
  end
end

if( PLOT_FIGS ) 
  figure; imagesc( 0:max_n_cars, nCM, P ); colorbar; 
  xlabel('num at the end of the day'); ylabel('num in morning'); axis xy; drawnow; 
end






