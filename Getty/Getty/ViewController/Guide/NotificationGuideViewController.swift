//
//  NotificationGuideViewController.swift
//  Getty
//
//  Created by Hyyy on 2017/12/12.
//  Copyright © 2017年 Hyyy. All rights reserved.
//

import UIKit

class NotificationGuideViewController: UIViewController {

    let titleLabel: UILabel = {
        
        let label = UILabel ()
        label.textAlignment = .center
        label.font = Constant.Font.kFontBig
        label.textColor = Constant.Color.kTitleColor
        label.text = "开启推送，享受更好地体验"
        
        return label
    }()
    
    let descLabel: UILabel = {
        
        let label = UILabel ()
        label.textAlignment = .center
        label.font = Constant.Font.kFontMedium
        label.textColor = Constant.Color.kDescColor
        label.text = "由于App需要获取推送权限才能更好地服务于用户，再次声明，开启推送并不会收集个人信息和广告推送，请放心使用！"
        label.numberOfLines = 0
        
        return label
    }()
    
    let notificationButton: UIButton = {
        
        let button = UIButton (type: .custom)
        button.setTitle("开启推送", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = Constant.Color.kMainColor
        
        button.layer.cornerRadius = 60
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(handleNotificationButtonTouchDownEvent), for: .touchDown)
        button.addTarget(self, action: #selector(handleNotificationButtonTouchUpEvent), for: [.touchUpInside, .touchUpOutside])
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(notificationButton)
        
        subViewLayout()
    }

    func subViewLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(80)
            make.left.equalTo(view.snp.left).offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
            make.height.equalTo(35)
        }
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalTo(view.snp.left).offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
        }
        notificationButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-50)
            make.size.equalTo(CGSize (width: 120, height: 120))
        }
    }
    
    @objc func handleNotificationButtonTouchDownEvent() {
        let scale: CGFloat = 0.9
        UIView.animate(withDuration: 0.15) {
            self.notificationButton.transform = CGAffineTransform (scaleX: scale, y: scale)
        }
    }
    
    @objc func handleNotificationButtonTouchUpEvent() {
        UIView.animate(withDuration: 0.15, animations: {
            self.notificationButton.transform = .identity
        }) { (finished) in
            // 注册通知
        }
    }

}