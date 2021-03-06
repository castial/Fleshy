//
//  PlanInsertViewController.swift
//  Getty
//
//  Created by Hyyy on 2017/12/13.
//  Copyright © 2017年 Getty. All rights reserved.
//

import UIKit

class PlanInsertViewController: UIViewController {

    let insertView: PlanInsertView = {
        
        let view = PlanInsertView (frame: CGRect (x: 0,
                                                  y: 64,
                                                  width: Constant.Size.kScreenWidth,
                                                  height: Constant.Size.kScreenHeight - 64))
        
        return view
    }()
    
    let plan: Plan = Plan()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "添加"
        navigationItem.leftBarButtonItem = UIBarButtonItem (image: UIImage (named: "close"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(handleCloseButtonEvent))
        navigationItem.rightBarButtonItem = UIBarButtonItem (title: "完成",
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(handleFinishButtonEvent))
        
        insertView.delegate = self
        
        view.addSubview(insertView)
    }
    
    @objc func handleCloseButtonEvent() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleFinishButtonEvent() {
        // 校验相关参数
        if plan.planName.count == 0 {
            TipUtil.showDangerTip(title: "计划名称不能为空")
            return
        }
        if plan.startDate == nil {
            TipUtil.showDangerTip(title: "开始时间不能为空")
            return
        }
        if plan.endDate == nil {
            TipUtil.showDangerTip(title: "结束时间不能为空")
            return
        }
        if plan.durationTimes == 0 {
            TipUtil.showDangerTip(title: "计划次数不能为空")
        }
        
        // TODO: 相关数据操作
        
        dismiss(animated: true, completion: nil)
    }
}

extension PlanInsertViewController: InsertPlanViewDelegate {
    
    func handleSelectedRow(indexPath: IndexPath) {
        if indexPath.section == 1 {
            let datePicker = DatePickerAlertView ()
            datePicker.tag = 1001
            datePicker.delegate = self
            
            datePicker.show()
        } else if indexPath.section == 2 {
            // 如果开始时间未选择，直接return
            if plan.startDate == nil {
                TipUtil.showDangerTip(title: "开始时间不能为空")
                return
            }
            let datePicker = DatePickerAlertView ()
            datePicker.tag = 1002
            datePicker.delegate = self
            
            datePicker.show()
        } else if indexPath.section == 3 {
            let listPicker = ListAlertView()
            listPicker.delegate = self
            listPicker.show()
        } else if indexPath.section == 4 {
            let chooseTimeVC = PlanChooseWeeksViewController()
            chooseTimeVC.weeksString = plan.notificationWeeks
            chooseTimeVC.delegate = self
            navigationController?.pushViewController(chooseTimeVC, animated: true)
        }
    }
    
    func handlePlanNameDidSelected(planName: String) {
        plan.planName = planName
    }
}

extension PlanInsertViewController: DatePickerAlertViewDelegate {
    
    func datePickerDidSelected(pickerView: DatePickerAlertView, date: Date) {
        if pickerView.tag == 1001 {
            // 开始时间
            plan.startDate = date
        } else {
            // FIXME: 这里需要优化，如果开始时间和结束时间的时、分相等的话，也是要给出警告提示的。
            
            // 如果开始时间大于等于结束时间，给出提示
            if plan.startDate! > date {
                TipUtil.showDangerTip(title: "结束时间必须大于开始时间")
                return
            }
            plan.endDate = date
            
            // 提示计划共持续时间
            let minutes = Date.minutesInterval(startDate: plan.startDate!, endDate: plan.endDate!)
            TipUtil.showInfoTip(title: String (format: "本计划每次执行%d分钟", minutes))
        }
        
        insertView.reloadData(plan: plan)
    }
}

extension PlanInsertViewController: ListAlertViewDelegate {
    
    func listViewDidSelected(title: String, value: Int) {
        plan.durationTimes = value
        insertView.reloadData(plan: plan)
    }
}

extension PlanInsertViewController: PlanChooseWeeksViewControllerDelegate {
    
    func chooseWeeksDidCompleted(weekString: String) {
        plan.notificationWeeks = weekString
        insertView.reloadData(plan: plan)
    }
}
