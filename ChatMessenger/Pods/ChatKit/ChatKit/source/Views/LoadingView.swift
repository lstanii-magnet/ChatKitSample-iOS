/*
* Copyright (c) 2016 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit

public class LoadingView : UIView {
    
    
    public internal(set) var indicator : UIActivityIndicatorView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.frame = frame
        indicator.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(indicator)
        self.indicator = indicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}