function hp = bilinear_func(hrtfData,sourcePosition,desiredPosition)
    sourcePosition_copy = sourcePosition;
    EL_des = desiredPosition(2);
    AZ_des = desiredPosition(1);
    sourcePosition_dis = sourcePosition_copy(:,2) - EL_des;
    [EL1_dis, EL1_idx] = min(abs(sourcePosition_dis));
    sourcePosition_dis(abs(sourcePosition_dis) ==  abs(sourcePosition_dis(EL1_idx))) = 999;
    [~, EL2_idx] = min(abs(sourcePosition_dis));
    sourcePosition_dis(sourcePosition_dis == 999) = EL1_dis;
    sourcePosition_1 = sourcePosition_copy;
    sourcePosition_2 = sourcePosition_copy;
    for i = 1 : length(sourcePosition_copy)
        if(~(abs(sourcePosition_dis(i)) == abs(sourcePosition_dis(EL1_idx))))
            sourcePosition_1(i,:) = nan;
        end
        if(~(abs(sourcePosition_dis(i)) == abs(sourcePosition_dis(EL2_idx))))
            sourcePosition_2(i,:) = nan;
        end
    end
    
    [distance, indx_ab] = nearPosition(sourcePosition_1, desiredPosition, 2);
    interpolatedPos = sourcePosition_copy(indx_ab, :);
    
    [distance, indx_c] = nearPosition(sourcePosition_2, desiredPosition, 1);
    interpolatedPos = [interpolatedPos; sourcePosition_copy(indx_c, :)];
    
    
    A = interpolatedPos(1,:);
    B = interpolatedPos(2,:);
    C = interpolatedPos(3, :);
    phi_grid = C(2) - A(2);
    theta_grid = B(1) - A(1);
    phi = EL_des - A(2);
    theta_a = AZ_des - A(1);
    theta_ac = C(1) - A(1);

     
    wc = phi/phi_grid;
    wb = 1/theta_grid*(theta_a - wc*theta_ac);
    wa = 1 - wb - wc;
    ha = squeeze(hrtfData(indx_ab(1) , : , :));
    hb = squeeze(hrtfData(indx_ab(2), : , :));
    hc = squeeze(hrtfData(indx_c, : , :));
    
    hp = wa.*ha +wb.*hb + wc.*hc;
end

