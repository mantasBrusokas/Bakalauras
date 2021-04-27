//
//  MostActiveViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-27.
//
import UIKit
import Charts

class MostActiveViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createChart()
    }
    
    private func createChart() {
        
        let barChart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        
        var entries = [BarChartDataEntry]()
        for x in 0..<10 {
            entries.append(BarChartDataEntry(x: Double(x), y: Double.random(in: 0...30)))
        }
        
        let set = BarChartDataSet(entries: entries, label: "Most active users")
        let data = BarChartData(dataSet: set)
        
        barChart.data = data
        
        view.addSubview(barChart)
        barChart.center = view.center
    }
    
}
